"""Bounded process cache of culinary graph content, never private request state.

Restarting the server clears generated content. Existing demo fixtures stay transient.
"""
import from hashlib { sha256 }
import from datetime { datetime, timezone }
import from threading { RLock }
import from math { isfinite }
import re;
import from graph.models {
    CulinaryCatalogue,
    Recipe,
    Ingredient,
    RecipeStep,
    CATALOGUE_RECIPE,
    CATALOGUE_TRADITION,
    REQUIRES,
    HAS_STEP,
    BELONGS_TO
}
import from graph.seed { build_demo_graph, add_region, add_tradition }
import from graph.projections { recipe_view }
import from pantry.normalisation { normalise_name }
import from .models { RecipeCandidate, HAS_CANDIDATE, CANDIDATE_REQUIRES, RESOLVES_TO }
import from .views { CandidateProposal, PreparedRecipe, CandidateView }

glob cache_lock = RLock();

glob memory: CulinaryCatalogue = CulinaryCatalogue();

def identity(name: str, tradition: str) -> str {
    text = " ".join(name.lower().split()) + "|" + " ".join(tradition.lower().split());
    return "ai-" + sha256(text.encode()).hexdigest()[:20];
}

def check_text(text: str, maximum: int) -> bool {
    return bool(text.strip())
        and len(text) <= maximum
        and not any([ord(c) < 32 for c in text]);
}

def valid_candidate(draft: CandidateProposal) -> bool {
    if not all(
        [
            check_text(draft.name, 100),
            check_text(draft.description, 500),
            check_text(draft.region, 80),
            check_text(draft.tradition, 80)
        ]
    ) {
        return False;
    }
    if draft.minutes < 1
        or draft.minutes > 240
        or not 1 <= len(draft.ingredients) <= 16 {
        return False;
    }
    names: set[str] = set();
    for item in draft.ingredients {
        name = normalise_name(item.name);
        if not name or name in names {
            return False;
        }
        names.add(name);
    }
    return any([item.essential for item in draft.ingredients]);
}

def insert_candidate(
    catalogue: CulinaryCatalogue, draft: CandidateProposal, provenance: str
) -> RecipeCandidate {
    candidate = RecipeCandidate(
        key=identity(draft.name, draft.tradition),
        name=draft.name.strip(),
        description=draft.description.strip(),
        region=draft.region.strip(),
        tradition=draft.tradition.strip(),
        minutes=draft.minutes,
        provenance=provenance + " · " + datetime.now(timezone.utc).isoformat()
    );
    catalogue +>:HAS_CANDIDATE():+> candidate;
    for item in draft.ingredients {
        candidate +>:CANDIDATE_REQUIRES(essential=item.essential):+> Ingredient(
            name=normalise_name(item.name)
        );
    }
    return candidate;
}

def candidate_view(candidate: RecipeCandidate, pantry: list[str]) -> CandidateView {
    missing: list[str] = [];
    essential: int = 0;
    for item in [candidate->:CANDIDATE_REQUIRES:->] {
        relation = [edge candidate->:CANDIDATE_REQUIRES:->item][0];
        if relation.essential {
            essential += 1;
            if item.name not in pantry {
                missing.append(item.name);
            }
        }
    }
    return CandidateView(
        key=candidate.key,
        name=candidate.name,
        description=candidate.description,
        region=candidate.region,
        tradition=candidate.tradition,
        minutes=candidate.minutes,
        score=(100 * (essential - len(missing))) // essential if essential else 100,
        missing=missing,
        provenance=candidate.provenance,
        verification=candidate.verification,
        prepared=bool([candidate->:RESOLVES_TO:->])
    );
}

def resolve_candidate(candidate: RecipeCandidate, draft: PreparedRecipe) -> Recipe {
    existing = [candidate->:RESOLVES_TO:->];
    if existing {
        return existing[0];
    }
    names = [item.name for item in [candidate->:CANDIDATE_REQUIRES:->]];
    if draft.servings < 1 or draft.servings > 12 or not 2 <= len(draft.steps) <= 12 {
        raise ValueError("Invalid portions or step count");
    }
    if len(draft.quantities) != len(names)
        or set([q.name for q in draft.quantities]) != set(names) {
        raise ValueError("Recipe ingredients changed during preparation");
    }
    for quantity in draft.quantities {
        if not isfinite(quantity.quantity)
            or not 0 < quantity.quantity <= 10000
            or not check_text(quantity.unit, 20) {
            raise ValueError("Invalid ingredient quantity or unit");
        }
    }
    for instruction in draft.steps {
        if not check_text(instruction, 800) {
            raise ValueError("Invalid instruction");
        }
        if "water" not in names
            and re.search(
                r"\b\d+(?:[.,]\d+)?\s*(?:ml|l|milliliters?|millilitres?|liters?|litres?|cups?|tbsp|tsp|tablespoons?|teaspoons?)\s+(?:of\s+)?water\b",
                instruction.lower()
            ) {
            raise ValueError(
                "Measured cooking water must be declared as an ingredient"
            );
        }
    }
    recipe = Recipe(
        key=candidate.key,
        name=candidate.name,
        description=candidate.description,
        minutes=candidate.minutes,
        servings=draft.servings,
        provenance=candidate.provenance,
        verification="AI-generated recipe / needs verification",
        version="cooksy-ai-" + sha256(str(draft).encode()).hexdigest()[:20]
    );
    # Keep the recipe graph reachable from its owning candidate; no root writes.
    region = add_region(
        CulinaryCatalogue(),
        identity(candidate.region, "region"),
        candidate.region,
        "AI proposal",
        "◌",
        "olive"
    );
    tradition = add_tradition(
        region, identity(candidate.tradition, "tradition"), candidate.tradition
    );
    recipe +>:BELONGS_TO():+> tradition;
    for item in [candidate->:CANDIDATE_REQUIRES:->] {
        relation = [edge candidate->:CANDIDATE_REQUIRES:->item][0];
        for quantity in draft.quantities {
            if quantity.name == item.name {
                recipe +>:REQUIRES(
                    quantity=quantity.quantity,
                    unit=quantity.unit,
                    essential=relation.essential
                ):+> item;
            }
        }
    }
    for index in range(len(draft.steps)) {
        recipe +>:HAS_STEP(sequence=index + 1):+> RecipeStep(
            instruction=draft.steps[index]
        );
    }
    candidate +>:RESOLVES_TO():+> recipe;
    return recipe;
}

def request_catalogue() -> CulinaryCatalogue {
    catalogue = build_demo_graph();
    # Copy only complete generated culinary content. Never connect fixture nodes to cache.
    for candidate in [memory->:HAS_CANDIDATE:->] {
        for stored in [candidate->:RESOLVES_TO:->] {
            view = recipe_view(stored);
            region = add_region(
                catalogue,
                identity(view.region, "region"),
                view.region,
                "AI-generated / unverified",
                "◌",
                "olive"
            );
            tradition = add_tradition(
                region, identity(view.tradition, "tradition"), view.tradition
            );
            catalogue +>:CATALOGUE_TRADITION():+> tradition;
            recipe = Recipe(
                key=view.key,
                name=view.name,
                description=view.description,
                minutes=view.minutes,
                servings=view.servings,
                provenance=view.provenance,
                verification=view.verification,
                version=view.version
            );
            catalogue +>:CATALOGUE_RECIPE():+> recipe;
            recipe +>:BELONGS_TO():+> tradition;
            for item in view.requirements {
                recipe +>:REQUIRES(
                    quantity=item.quantity, unit=item.unit, essential=item.essential
                ):+> Ingredient(name=item.name);
            }
            for step in view.steps {
                recipe +>:HAS_STEP(sequence=step.sequence):+> RecipeStep(
                    instruction=step.instruction
                );
            }
        }
    }
    return catalogue;
}
