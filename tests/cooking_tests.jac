import from endpoints { get_recipe, cook_session as invoke_cooking }
import from cooking.views { CookingView }
import from graph.seed { build_demo_graph }
import from graph.models { Recipe, RecipeStep, HAS_STEP, CURRENT_STEP, COMPLETED_STEP }
import from walkers.recipe { RecipeWalker }
import from walkers.cooking { CookingWalker }
import from cooking.state { restore_session }

def cook_session(
    recipe_key: str,
    current_sequence: int = 1,
    finished: bool = False,
    action: str = "resume",
    version: str = "cooksy-demo-v1"
) -> CookingView {
    return invoke_cooking(recipe_key, current_sequence, finished, action, version);
}

test "recipe walker assembles selected graph details and unknown key is empty" {
    catalogue = build_demo_graph();
    found = catalogue spawn RecipeWalker(recipe_key="gamja-jeon-demo");
    details = found.details;
    assert details is not None;
    assert details.name == "Gamja-jeon";
    assert [step.sequence for step in details.steps] == [1, 2];
    assert details.requirements[0].name == "potato";
    assert details.requirements[0].quantity == 300.0;
    assert details.tradition == "Korean";
    selected = get_recipe("gamja-jeon-demo", ["potatoes", "oil"]);
    assert selected is not None;
    assert selected.score == 100;
    assert selected.missing_optional[0].name == "salt";
    assert get_recipe("unknown", []) is None;
}

test "cooking walker moves actual current and completed graph relationships" {
    catalogue = build_demo_graph();
    found = catalogue spawn RecipeWalker(recipe_key="gamja-jeon-demo");
    recipe = found.selected_node;
    assert recipe is not None;
    session = restore_session(recipe, 1, False);
    assert len([session->:CURRENT_STEP:->]) == 1;
    assert len([session->:COMPLETED_STEP:->]) == 0;
    next_step = session spawn CookingWalker(action="next");
    result = next_step.result;
    assert result is not None;
    assert result.current_sequence == 2;
    assert result.completed == [1];
    assert len([session->:COMPLETED_STEP:->]) == 1;
    assert [session->:CURRENT_STEP:->][0].instruction == result.instruction;
    finished = session spawn CookingWalker(action="next");
    assert session.finished;
    assert len([session->:COMPLETED_STEP:->]) == 2;
    assert len([session->:CURRENT_STEP:->]) == 1;
    previous = session spawn CookingWalker(action="back");
    assert not session.finished;
    assert len([session->:COMPLETED_STEP:->]) == 1;
    previous = session spawn CookingWalker(action="back");
    assert len([session->:COMPLETED_STEP:->]) == 0;
}

test "resume validates snapshot and back next restart remain bounded" {
    first = cook_session("tamagoyaki-demo", action="start");
    assert first.current_sequence == 1 and first.completed == [];
    back = cook_session(first.recipe_key, 1, False, "back");
    assert back.current_sequence == 1;
    second = cook_session(first.recipe_key, 1, False, "next");
    recovered = cook_session(
        first.recipe_key, second.current_sequence, second.finished
    );
    assert recovered.current_sequence == 2 and recovered.completed == [1];
    finished = cook_session(first.recipe_key, 2, False, "next");
    assert finished.finished and finished.completed == [1, 2];
    stable = cook_session(first.recipe_key, 2, True, "next");
    assert stable.finished and stable.current_sequence == 2;
    restarted = cook_session(first.recipe_key, 2, True, "restart");
    assert restarted.current_sequence == 1 and restarted.completed == [];
    with testraises(ValueError) {
        cook_session(first.recipe_key, 0);
    }
    with testraises(ValueError) {
        cook_session(first.recipe_key, 3);
    }
    with testraises(ValueError) {
        cook_session(first.recipe_key, 1, True);
    }
    with testraises(ValueError) {
        cook_session(first.recipe_key, action="invalid");
    }
    with testraises(ValueError) {
        cook_session("unknown");
    }
    with testraises(ValueError) {
        cook_session(first.recipe_key, version="old-version");
    }
}

test "sessions are independent and malformed recipe order is rejected" {
    first = cook_session("gamja-jeon-demo", 1, False, "next");
    second = cook_session("gamja-jeon-demo", 1, False, "resume");
    assert first.current_sequence == 2 and second.current_sequence == 1;
    catalogue = build_demo_graph();
    found = catalogue spawn RecipeWalker(recipe_key="gamja-jeon-demo");
    recipe = found.selected_node;
    assert recipe is not None;
    recipe +>:HAS_STEP(sequence=2):+> RecipeStep(instruction="duplicate");
    with testraises(ValueError) {
        restore_session(recipe, 1, False);
    }
}
