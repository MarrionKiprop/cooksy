import from endpoints { recipe_nutrition, estimate_recipe_nutrition }
import type from .views { NutritionView }

def:pub NutritionPanel(recipeKey: str, version: str) -> JsxElement {
    has state: NutritionView | None = None,
        busy: bool = True,
        error: str = "",
        ai_error: str = "",
        estimating: bool = False;
    async def load {
        busy = True;
        error = "";
        ai_error = "";
        try {
            state = await recipe_nutrition(recipeKey, version);
        } except Exception {
            error = "Nutrition estimates are unavailable. Your recipe and cook-along still work.";
        }
        busy = False;
    }
    async can with [recipeKey, version] entry {
        await load();
    }
    async def estimate {
        estimating = True;
        ai_error = "";
        try {
            state = await estimate_recipe_nutrition(recipeKey, version);
        } except Exception {
            ai_error = "AI estimates are unavailable. Your reference values and recipe are unchanged.";
        }
        estimating = False;
    }
    nutrition = state;
    ai = nutrition is not None and nutrition.status in ["ai_estimate", "ai_partial"];
    partial = nutrition is not None and nutrition.status in ["partial", "ai_partial"];
    return
        <section
            className="nutrition-panel"
            aria-labelledby="nutrition-title"
            aria-busy={busy or estimating}
        >
            <span className="eyebrow">NUTRITION INSIGHTS</span>
            <h2 id="nutrition-title">A little nourishment.</h2>
            {<p role="status">Calculating reference-based estimates…</p>
                if busy
                else None}
            {<div>
                <p role="status">{error}</p>
                <button
                    type="button"
                    className="button secondary"
                    disabled={busy}
                    onClick={load}
                >
                    Retry nutrition
                </button>
            </div>
                if error
                else None}
            {<div>
                <h3>
                    {"AI-assisted nutrition estimate"
                        if ai
                        else (
                            "Estimated recipe nutrition"
                                if nutrition.status == "estimate"
                                else (
                                    "Known-ingredient subtotal only"
                                        if partial
                                        else "Not enough supported data"
                                )
                        )}
                </h3>
                <p className="nutrition-coverage">
                    {str(nutrition.matched)
                        + " of "
                        + str(nutrition.total_items)
                        + (
                            " ingredient amounts included · "
                                if ai
                                else " ingredient amounts supported · "
                        )
                        + str(nutrition.servings)
                        + " equal servings"}
                </p>
                {<p className="nutrition-gap">
                    Incomplete: these numbers exclude unsupported ingredients and are not the nutrition of the whole meal.
                </p>
                    if partial
                    else None}
                {<p className="nutrition-gap">
                    Includes approximate AI nutrient or portion estimates, not verified USDA values or measured meal nutrition. Review the assumptions below.
                </p>
                    if ai
                    else None}
                {<table className="nutrition-table">
                    <caption>
                        {"AI-assisted approximate values"
                            if nutrition.status == "ai_estimate"
                            else (
                                "Estimated values"
                                    if nutrition.status == "estimate"
                                    else "Subtotal for supported ingredients; whole-meal totals unavailable"
                            )}
                    </caption>
                    <thead>
                        <tr>
                            <th scope="col">Nutrient</th>
                            <th scope="col">Recipe{" subtotal" if partial else ""}</th>
                            <th scope="col">Per serving</th>
                        </tr>
                    </thead>
                    <tbody>
                        {[
                            <tr key={value.name}>
                                <th scope="row">{value.name}</th>
                                <td>
                                    {str(value.total) + " " + value.unit
                                        if value.total is not None
                                        else "Unavailable"}
                                </td>
                                <td>
                                    {str(value.per_serving) + " " + value.unit
                                        if value.per_serving is not None
                                        else "Unavailable"}
                                </td>
                            </tr> for value in nutrition.values
                        ]}
                    </tbody>
                </table>
                    if nutrition.status != "unavailable"
                    else None}
                {<div className="nutrition-ai-action">
                    <p className="fixture-note">
                        Ask AI to estimate missing foods or portion masses. Sends recipe ingredients to OpenAI and may use API credits.
                    </p>
                    <button
                        type="button"
                        className="button secondary"
                        disabled={estimating}
                        onClick={estimate}
                    >
                        {"Estimating…"
                            if estimating
                            else "Estimate missing nutrition with AI"}
                    </button>
                </div>
                    if nutrition.status in ["partial", "unavailable"]
                    else None}
                {<p role="status">{ai_error}</p> if ai_error else None}
                <details className="nutrition-sources">
                    <summary>References, assumptions and missing amounts</summary>
                    <p className="fixture-note">{nutrition.disclosure}</p>
                    <ul>
                        {[
                            <li key={str(index)}>
                                <strong>{item.name}</strong>
                                {" · " + str(item.grams) + " g"
                                    if item.grams is not None
                                    else " · Mass unknown"}
                                {<p>
                                    <a
                                        href={item.source_url}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                    >
                                        {item.reference + " (USDA)"}
                                    </a>
                                </p>
                                    if item.source_url
                                    else None}
                                {<p>{item.reason}</p> if item.reason else None}
                            </li> for (index, item) in enumerate(nutrition.items)
                        ]}
                    </ul>
                    <p>
                        Reference-based values use a small USDA SR Legacy subset per 100 g edible portion. AI-assisted values or count/volume conversions use the stated assumptions and are not verified database measurements. Generic cooking oil is not silently replaced with olive oil.
                    </p>
                </details>
            </div>
                if nutrition is not None and not busy and not error
                else None}
        </section>;
}
