"""Read-only connectivity and transient culinary demo discovery endpoints."""

def:pub shell_status() -> str {
    return "Connected to the Jac kitchen";
}

import from ai.memory { request_catalogue }
import from graph.seed { build_demo_graph }
import from graph.views { DiscoveryResult }
import from walkers.discovery { DiscoveryWalker }

def:pub discover(region_key: str = "", tradition_key: str = "") -> DiscoveryResult {
    # Browse a transient demo graph without writing user state.
    catalogue = build_demo_graph();
    discovery = catalogue spawn DiscoveryWalker(
        region_key=region_key, tradition_key=tradition_key
    );
    return discovery.reports[0];
}

import from graph.models { Pantry, IntakeItem, PENDING_ITEM }
import from pantry.normalisation { split_names }
import from pantry.views { PantryMatches }
import from walkers.intake { IntakeWalker }
import from walkers.matching { MatchingWalker }

def:pub match_pantry(
    ingredients: list[str], region_key: str = "", tradition_key: str = ""
) -> PantryMatches {
    if len(ingredients) > 100 or sum([len(name) for name in ingredients]) > 8000 {
        raise ValueError("Use at most 100 ingredient entries and 8000 characters.");
    }
    catalogue = request_catalogue();
    pantry = Pantry();
    count: int = 0;
    for raw in ingredients {
        for token in split_names(raw) {
            if token.strip() {
                count += 1;
                if count > 100 {
                    raise ValueError("Use at most 100 ingredient entries.");
                }
                pantry +>:PENDING_ITEM():+> IntakeItem(name=token);
            }
        }
    }
    intake = pantry spawn IntakeWalker(pantry=pantry, catalogue=catalogue);
    matching = catalogue spawn MatchingWalker(
        pantry=pantry, region_key=region_key, tradition_key=tradition_key
    );
    return PantryMatches(
        intake=intake.reports[0], matches=matching.matches, events=matching.events
    );
}

import from walkers.recipe { RecipeWalker }
import from walkers.cooking { CookingWalker }
import from cooking.state { restore_session }
import from cooking.views { CookingView }
import from pantry.views { MatchView }

def:pub get_recipe(recipe_key: str, ingredients: list[str]) -> MatchView | None {
    catalogue = request_catalogue();
    selection = catalogue spawn RecipeWalker(recipe_key=recipe_key);
    if selection.details is None {
        return None;
    }
    matches = match_pantry(ingredients);
    for candidate in matches.matches {
        if candidate.recipe.key == recipe_key {
            return candidate;
        }
    }
    return None;
}

def:pub cook_session(
    recipe_key: str, current_sequence: int, finished: bool, action: str, version: str
) -> CookingView {
    catalogue = request_catalogue();
    selection = catalogue spawn RecipeWalker(recipe_key=recipe_key);
    recipe = selection.selected_node;
    if recipe is None {
        raise ValueError("Recipe not found.");
    }
    if version != recipe.version {
        raise ValueError("Recipe changed; start a new session.");
    }
    session = restore_session(recipe, current_sequence, finished);
    cooking = session spawn CookingWalker(action=action);
    return cooking.result as CookingView;
}

import from ai.memory { memory, cache_lock }
import from ai.views { EnrichmentResult, PreparationResult, AssistanceResult }
import from ai.service { prepare_selected, assist }
import from walkers.enrichment { EnrichmentWalker }
import from pantry.normalisation { normalise_name }

def run_enrichment(
    ingredients: list[str], cuisine: str, coverage_score: int
) -> EnrichmentResult {
    if len(ingredients) > 100
        or sum([len(raw) for raw in ingredients]) > 8000
        or len(cuisine) > 80 {
        raise ValueError("Request too large");
    }
    names: set[str] = set();
    for raw in ingredients {
        for token in split_names(raw) {
            name = normalise_name(token);
            if name {
                names.add(name);
            }
            if len(names) > 100 {
                raise ValueError("Too many ingredients");
            }
        }
    }
    with cache_lock {
        discovery = request_catalogue() spawn EnrichmentWalker(
            cache=memory,
            pantry=sorted(names),
            cuisine=cuisine.strip(),
            coverage_score=coverage_score
        );
        return discovery.reports[0];
    }
}


def:pub enrich(ingredients: list[str], cuisine: str) -> EnrichmentResult {
    return run_enrichment(ingredients, cuisine, 0);
}

def:pub discover_pantry(ingredients: list[str], cuisine: str) -> EnrichmentResult {
    return run_enrichment(ingredients, cuisine, 100);
}


def:pub prepare_candidate(recipe_key: str) -> PreparationResult {
    with cache_lock {
        return prepare_selected(memory, recipe_key);
    }
}

def:pub cooking_help(
    recipe_key: str, current_sequence: int, finished: bool, version: str, question: str
) -> AssistanceResult {
    return assist(
        request_catalogue(), recipe_key, current_sequence, finished, version, question
    );
}

import from discovery.views { NavigationCatalogue, IntakeReview, MealPlan }
import from discovery.taxonomy { navigation }
import from discovery.intake { review_text }
import from discovery.service { plan, restore }
import from pantry.views { IntakeResult }

def:pub culinary_regions() -> NavigationCatalogue {
    return navigation();
}

def:pub review_ingredients(text: str) -> IntakeReview {
    return review_text(text);
}

def:pub confirm_ingredients(ingredients: list[str]) -> IntakeResult {
    return match_pantry(ingredients, "", "").intake;
}

def:pub recommend_meals(
    ingredients: list[str], mode: str, region_key: str, tradition_key: str, demo: bool
) -> MealPlan {
    return plan(ingredients, mode, region_key, tradition_key, demo);
}

def:pub restore_meals(
    ingredients: list[str],
    keys: list[str],
    mode: str,
    region_key: str,
    tradition_key: str,
    demo: bool
) -> MealPlan {
    return restore(ingredients, keys, mode, region_key, tradition_key, demo);
}
