"""A single validated five-choice result contract for Explore and Discover."""
import from graph.models { CulinaryCatalogue, CATALOGUE_RECIPE }
import from graph.seed { build_demo_graph }
import from graph.projections { recipe_view }
import from ai.memory { memory, cache_lock, candidate_view }
import from ai.models { HAS_CANDIDATE, CANDIDATE_REQUIRES }
import from ai.views { CandidateView }
import from pantry.normalisation { normalise_name }
import from .taxonomy { build_taxonomy, validate_scope, in_scope, plain }
import from .views { MealPlan, MealChoice }
import from walkers.enrichment { EnrichmentWalker }

def confirmed_names(ingredients: list[str]) -> list[str] {
    if not 1 <= len(ingredients) <= 100 {
        raise ValueError("Confirm 1–100 ingredient names before discovery.");
    }
    names: set[str] = set();
    for raw in ingredients {
        name = normalise_name(raw);
        if not name {
            raise ValueError("Use confirmed ingredient names, not raw sentences.");
        }
        names.add(name);
    }
    return sorted(names);
}

def meal_choice(
    item: CandidateView, names: list[str], catalogue: CulinaryCatalogue
) -> MealChoice {
    available: list[str] = [];
    optional: list[str] = [];
    found: bool = False;
    for candidate in [memory->:HAS_CANDIDATE:->] {
        if candidate.key != item.key {
            continue;
        }
        found = True;
        for ingredient in [candidate->:CANDIDATE_REQUIRES:->] {
            relation = [edge candidate->:CANDIDATE_REQUIRES:->ingredient][0];
            if ingredient.name in names {
                available.append(ingredient.name);
            }
            if not relation.essential {
                optional.append(ingredient.name);
            }
        }
    }
    if not found {
        for recipe in [catalogue->:CATALOGUE_RECIPE:->] {
            if recipe.key != item.key {
                continue;
            }
            for ingredient in recipe_view(recipe).requirements {
                if ingredient.name in names {
                    available.append(ingredient.name);
                }
                if not ingredient.essential {
                    optional.append(ingredient.name);
                }
            }
        }
    }
    readiness = "Cook now"
        if len(item.missing) == 0
        else ("Almost ready" if len(item.missing) <= 2 else "Needs shopping");
    return MealChoice(
        candidate=item,
        available=sorted(available),
        optional=sorted(optional),
        readiness=readiness
    );
}

def plan(
    ingredients: list[str], mode: str, region_key: str, tradition_key: str, demo: bool
) -> MealPlan {
    names = confirmed_names(ingredients);
    validate_scope(mode, region_key, tradition_key);
    if demo and (region_key or tradition_key) {
        raise ValueError("Demo choices are worldwide; clear the region.");
    }
    catalogue = build_demo_graph() if demo else build_taxonomy();
    events: list[str] = [];
    choices: list[MealChoice] = [];
    status = "incomplete";
    message = "";
    with cache_lock {
        # One initial inference plus at most one repair. No invalid/duplicate padding.
        for attempt in range(2) {
            walking = catalogue spawn EnrichmentWalker(
                cache=CulinaryCatalogue() if demo else memory,
                pantry=names,
                cuisine="",
                coverage_score=100,
                scoped=True,
                region_key=region_key,
                tradition_key=tradition_key,
                varied=mode == "discover",
                allow_inference=not demo
            );
            result = walking.result;
            if result is None {
                raise ValueError("Discovery did not finish");
            }
            events += result.events;
            choices = [
                meal_choice(item, names, catalogue) for item in result.candidates
            ];
            status = result.status;
            message = result.message;
            if len(choices) == 5 or status in ["unavailable", "limited"] or demo {
                break;
            }
            if attempt == 0 {
                events.append(
                    "Fewer than five distinct validated dishes; making one bounded repair request."
                );
            }
        }
    }
    ready = len(choices) == 5;
    if ready {
        message = "Five distinct choices from your confirmed pantry. Amounts are not checked."
            + (" " + message if status == "unavailable" else "");
    } else {
        message = str(len(choices))
            + " of 5 valid choices. No recipe selection yet. Retry, broaden the region or use the labelled demo choices. "
            + message;
    }
    if demo {
        message = "DEMO: developer fixtures, not live AI discovery. " + message;
    }
    return MealPlan(
        choices=choices,
        ready=ready,
        status="ready" if ready else status,
        message=message,
        mode=mode,
        region_key=region_key,
        tradition_key=tradition_key,
        demo=demo,
        events=events
    );
}

def restore(
    ingredients: list[str],
    keys: list[str],
    mode: str,
    region_key: str,
    tradition_key: str,
    demo: bool
) -> MealPlan {
    names = confirmed_names(ingredients);
    validate_scope(mode, region_key, tradition_key);
    if len(keys) != 5 or len(set(keys)) != 5 {
        raise ValueError("Saved choices must contain five distinct keys.");
    }
    catalogue = build_demo_graph() if demo else build_taxonomy();
    views: list[CandidateView] = [];
    walking = catalogue spawn EnrichmentWalker(
        cache=CulinaryCatalogue() if demo else memory,
        pantry=names,
        cuisine="",
        coverage_score=0,
        scoped=False,
        region_key=region_key,
        tradition_key=tradition_key,
        varied=False,
        allow_inference=False
    );
    # Restore can refer to choices beyond the current top five: read exact graph identities.
    for key in keys {
        item: CandidateView | None = None;
        for candidate in [memory->:HAS_CANDIDATE:->] {
            if not demo
                and candidate.key == key
                and in_scope(
                    candidate.region, candidate.tradition, region_key, tradition_key
                ) {
                item = candidate_view(candidate, names);
            }
        }
        if item is None and demo {
            for view in walking.candidates {
                if view.key == key
                    and in_scope(
                        view.region, view.tradition, region_key, tradition_key
                    ) {
                    item = view;
                }
            }
        }
        if item is None {
            raise ValueError("Saved generated choices expired. Discover again.");
        }
        views.append(item);
    }
    if len(set([plain(item.name) for item in views])) != 5 {
        raise ValueError("Saved choices are not distinct dishes");
    }
    return MealPlan(
        choices=[meal_choice(item, names, catalogue) for item in views],
        ready=True,
        status="restored",
        message="Restored your five choices from graph memory. No model call.",
        mode=mode,
        region_key=region_key,
        tradition_key=tradition_key,
        demo=demo,
        events=["Restored exact candidate graph identities without inference."]
    );
}
