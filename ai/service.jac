"""Validated selected preparation and extractive assistance boundaries."""
import from graph.models { CulinaryCatalogue }
import from .models { HAS_CANDIDATE, CANDIDATE_REQUIRES, RESOLVES_TO }
import from .memory { resolve_candidate, request_catalogue, check_text }
import from .views { PreparationResult, AssistanceResult }
import ai.provider as provider;
import from walkers.recipe { RecipeWalker }
import from cooking.state { restore_session }
import from walkers.cooking { CookingWalker }

def prepare_selected(cache: CulinaryCatalogue, key: str) -> PreparationResult {
    for candidate in [cache->:HAS_CANDIDATE:->] {
        if candidate.key != key {
            continue;
        }
        if [candidate->:RESOLVES_TO:->] {
            return PreparationResult(
                key=key,
                ready=True,
                message="Reused prepared graph recipe. No model call."
            );
        }
        if not provider.enabled() {
            return PreparationResult(
                key=key,
                ready=False,
                message="AI preparation is unavailable. Your candidate is unchanged."
            );
        }
        try {
            names = [item.name for item in [candidate->:CANDIDATE_REQUIRES:->]];
            context = candidate.name
                + " | "
                + candidate.tradition
                + " | "
                + candidate.description
                + " | Ingredients: "
                + ", ".join(names);
            draft = provider.prepare(context);
            resolve_candidate(candidate, draft);
            return PreparationResult(
                key=key, ready=True, message="AI-generated recipe / needs verification."
            );
        } except Exception {
            return PreparationResult(
                key=key,
                ready=False,
                message="We could not validate the generated recipe. Nothing was changed; try again later."
            );
        }
    }
    found = request_catalogue() spawn RecipeWalker(recipe_key=key);
    return PreparationResult(
        key=key,
        ready=found.details is not None,
        message="Selected existing graph recipe."
            if found.details is not None
            else "Candidate expired or was not found. Search again."
    );
}

def assist(
    catalogue: CulinaryCatalogue,
    key: str,
    sequence: int,
    finished: bool,
    version: str,
    question: str
) -> AssistanceResult {
    if not check_text(question, 500) {
        raise ValueError("Invalid version or question; use 1–500 characters.");
    }
    selection = catalogue spawn RecipeWalker(recipe_key=key);
    recipe = selection.selected_node;
    if recipe is None {
        raise ValueError("Recipe not found or generated content expired.");
    }
    if version != recipe.version {
        raise ValueError("Recipe changed; start a new session.");
    }
    session = restore_session(recipe, sequence, finished);
    cooking = session spawn CookingWalker(action="resume");
    current = cooking.result;
    if current is None {
        raise ValueError("Invalid active step");
    }
    quotes: list[str] = [];
    status = "unavailable";
    message = "AI help is unavailable. The recipe step remains available above.";
    if finished {
        status = "complete";
        message = "Reopen a step to ask for help.";
    } elif provider.enabled() {
        try {
            response = provider.help_step(recipe.name, current.instruction, question);
            if len(response.quotes) > 3 {
                raise ValueError("Too many quotations");
            }
            for quote in response.quotes {
                if not check_text(quote, 800) or quote not in current.instruction {
                    raise ValueError("Ungrounded assistance");
                }
                if quote not in quotes {
                    quotes.append(quote);
                }
            }
            status = "grounded" if quotes else "insufficient_context";
            message = "Quoted from this recipe’s current step. AI-selected, not independently verified."
                if quotes
                else "This step does not contain enough information to answer that question.";
        } except Exception {
            quotes = [];
            message = "AI help failed validation or is unavailable. Read the current recipe step and try again later.";
        }
    }
    return AssistanceResult(
        quotes=quotes, status=status, message=message, recipe_key=key, sequence=sequence
    );
}
