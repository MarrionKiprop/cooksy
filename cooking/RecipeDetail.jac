import from ..pantry.client_state { read_pantry }
import from "@jac/runtime" { Link, useNavigate }
import from endpoints { get_recipe, cook_session }
import from pantry.views { MatchView }
import from .client_state { save_session }

def:pub RecipeDetail(recipeKey: str) -> JsxElement {
    has detail: MatchView | None = None,
        busy: bool = True,
        error: str = "",
        starting: bool = False,
        pantry_note: str = "Ingredient names only; your amounts have not been checked.";
    navigate = useNavigate();

    async def loadRecipe {
        busy = True;
        error = "";
        names = read_pantry();
        try {
            detail = await get_recipe(recipeKey, names);
        } except Exception {
            error = "We couldn’t load this recipe. Please try again.";
        }
        busy = False;
    }
    async can with [recipeKey] entry {
        await loadRecipe();
    }

    async def startCooking {
        selected = detail;
        if selected is None {
            return;
        }
        starting = True;
        error = "";
        try {
            state = await cook_session(
                selected.recipe.key, 1, False, "start", selected.recipe.version
            );
            save_session(state);
            navigate("/cook-along");
        } except Exception {
            error = "We couldn’t start the session. Please try again.";
        }
        starting = False;
    }

    selected = detail;
    if busy {
        return
            <div className="page-width recipe-detail">
                <h1>Finding your recipe…</h1>
                <p role="status">Opening your recipe.</p>
            </div>;
    }
    if error {
        return
            <div className="page-width recipe-detail">
                <h1>A little pause.</h1>
                <p role="alert">{error}</p>
                <button type="button" className="button primary" onClick={loadRecipe}>
                    Retry recipe
                </button>
                <Link to="/explore" className="button secondary">Back to Explore</Link>
            </div>;
    }
    if selected is None {
        return
            <div className="page-width recipe-detail">
                <h1>Recipe not found.</h1>
                <p>
                    That recipe is unavailable or its server cache expired. Search again in Explore.
                </p>
                <Link to="/explore" className="button primary">
                    Explore the kitchens
                </Link>
            </div>;
    }
    available = [item.name for item in selected.available];
    return
        <div className="page-width recipe-detail">
            <Link to="/explore" className="inline-link">← Back to Explore</Link>
            <div className="page-intro">
                <span className="eyebrow">
                    {selected.recipe.tradition} · {selected.recipe.region}
                </span>
                <h1>{selected.recipe.name}</h1>
                <p>{selected.recipe.description}</p>
            </div>
            <div className="recipe-facts">
                <span>{selected.recipe.minutes} min</span>
                <span>{selected.recipe.servings} servings</span>
                <span>{selected.score}% essential coverage</span>
            </div>
            <p className="demo-disclosure">
                {selected.recipe.verification
                    + ". Demo recipes have abbreviated steps; AI recipes need independent verification."}
            </p>
            <div className="recipe-detail-grid">
                <section
                    className="recipe-ingredients"
                    aria-labelledby="ingredients-title"
                >
                    <h2 id="ingredients-title">What goes in.</h2>
                    <p className="fixture-note">{pantry_note}</p>
                    <ul className="detail-ingredients">
                        {[
                            <li key={item.name}>
                                <div>
                                    <strong>{item.name}</strong>
                                    <span>{item.quantity} {item.unit}</span>
                                </div>
                                <span
                                    className={"ingredient-state present"
                                        if item.name in available
                                        else "ingredient-state"}
                                >
                                    {"In pantry"
                                        if item.name in available
                                        else (
                                            "Essential · missing"
                                                if item.essential
                                                else "Optional · missing"
                                        )}
                                </span>
                                <p>{item.preparation}</p>
                                {<p>
                                    Demo swap options: {", ".join(
                                        item.substitutes
                                    )}. Confirm suitability; these do not count as available.
                                </p>
                                    if item.substitutes
                                    else None}
                                <p>{item.substitution_notes}</p>
                            </li> for item in selected.recipe.requirements
                        ]}
                    </ul>
                    <Link to="/pantry" className="inline-link">Update my pantry →</Link>
                </section>
                <section className="recipe-method" aria-labelledby="method-title">
                    <span className="eyebrow">YOUR RECIPE, ONE STEP AT A TIME</span>
                    <h2 id="method-title">How it comes together.</h2>
                    <ol className="method-list">
                        {[
                            <li key={step.sequence}>
                                <h3>Step {step.sequence}</h3>
                                <p>{step.instruction}</p>
                            </li> for step in selected.recipe.steps
                        ]}
                    </ol>
                    <button
                        type="button"
                        className="button primary"
                        onClick={startCooking}
                        disabled={starting}
                    >
                        {"Starting…" if starting else "Start cook-along"}{" "}
                        <span aria-hidden="true">→</span>
                    </button>
                    <p className="fixture-note">
                        Starting replaces this tab’s active cooking session. Progress can be resumed from Cook along.
                    </p>
                </section>
            </div>
            <section className="recipe-context">
                <h2>A little context.</h2>
                <p>
                    This recipe is associated with the {selected.recipe.tradition} kitchen in {selected.recipe.region}. The preparation is an illustrative adaptation; cultural authenticity and quantities have not been independently verified.
                </p>
                <p className="fixture-note">Source: {selected.recipe.provenance}.</p>
            </section>
            <div className="recipe-unavailable">
                <p>Nutrition estimates and serving previews are not available yet.</p>
                <p>
                    AI can quote relevant wording from the active cook-along step. Timers are not available.
                </p>
            </div>
        </div>;
}
