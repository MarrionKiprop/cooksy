"""Read-only connectivity and transient culinary demo discovery endpoints."""

def:pub shell_status() -> str {
    return "Connected to the Jac kitchen";
}

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
    catalogue = build_demo_graph();
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
    catalogue = build_demo_graph();
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
    catalogue = build_demo_graph();
    if version != catalogue.version {
        raise ValueError("Recipe fixture changed; start a new session.");
    }
    selection = catalogue spawn RecipeWalker(recipe_key=recipe_key);
    recipe = selection.selected_node;
    if recipe is None {
        raise ValueError("Recipe not found.");
    }
    session = restore_session(recipe, current_sequence, finished);
    cooking = session spawn CookingWalker(action=action);
    return cooking.result as CookingView;
}
