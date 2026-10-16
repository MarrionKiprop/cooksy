"""Reconstruct only validated, request-local cooking graph state."""
import from graph.models {
    Recipe,
    CookingSession,
    HAS_STEP,
    SESSION_RECIPE,
    CURRENT_STEP,
    COMPLETED_STEP
}

def restore_session(
    recipe: Recipe, current_sequence: int, finished: bool
) -> CookingSession {
    steps = [recipe->:HAS_STEP:->];
    if not steps or current_sequence < 1 or current_sequence > len(steps) {
        raise ValueError("Saved step is outside this recipe.");
    }
    sequences: list[int] = [];
    for step in steps {
        for relation in [edge recipe->:HAS_STEP:->step] {
            sequences.append(relation.sequence);
        }
    }
    if sorted(sequences) != list(range(1, len(steps) + 1)) {
        raise ValueError("Recipe steps must have unique consecutive sequence numbers.");
    }
    if finished and current_sequence != len(steps) {
        raise ValueError("Finished progress must be on the final step.");
    }
    session = CookingSession(recipe_key=recipe.key, finished=finished);
    session +>:SESSION_RECIPE():+> recipe;
    for step in steps {
        for relation in [edge recipe->:HAS_STEP:->step] {
            if relation.sequence == current_sequence {
                session +>:CURRENT_STEP():+> step;
            }
            if relation.sequence < current_sequence or finished {
                session +>:COMPLETED_STEP():+> step;
            }
        }
    }
    return session;
}
