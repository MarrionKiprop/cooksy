import from endpoints { recipe_nutrition }
import type from .views { NutritionView }

def:pub NutritionPanel(recipeKey: str, version: str) -> JsxElement {
    has state: NutritionView | None = None,
        busy: bool = True,
        error: str = "";
    async def load {
        busy = True;
        error = "";
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
    nutrition = state;
    return
        <section
            className="nutrition-panel"
            aria-labelledby="nutrition-title"
            aria-busy={busy}
        >
            <span className="eyebrow">FROM INGREDIENT REFERENCES</span>
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
                    {"Estimated recipe nutrition"
                        if nutrition.status == "estimate"
                        else (
                            "Known-ingredient subtotal only"
                                if nutrition.status == "partial"
                                else "Not enough supported data"
                        )}
                </h3>
                <p className="nutrition-coverage">
                    {str(nutrition.matched)
                        + " of "
                        + str(nutrition.total_items)
                        + " ingredient amounts supported · "
                        + str(nutrition.servings)
                        + " equal servings"}
                </p>
                {<p className="nutrition-gap">
                    Incomplete: these numbers exclude unsupported ingredients and are not the nutrition of the whole meal.
                </p>
                    if nutrition.status == "partial"
                    else None}
                {<table className="nutrition-table">
                    <caption>
                        {"Estimated values"
                            if nutrition.status == "estimate"
                            else "Subtotal for supported ingredients; whole-meal totals unavailable"}
                    </caption>
                    <thead>
                        <tr>
                            <th scope="col">Nutrient</th>
                            <th scope="col">
                                Recipe{" subtotal"
                                    if nutrition.status == "partial"
                                    else ""}
                            </th>
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
                <p className="fixture-note">{nutrition.disclosure}</p>
                <details className="nutrition-sources">
                    <summary>References, assumptions and missing amounts</summary>
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
                        Small USDA SR Legacy reference subset, per 100 g edible portion; not an exhaustive food database. Generic cooking oil is not assumed to be olive oil. Counts, cups and millilitres are not converted without food-specific evidence.
                    </p>
                </details>
            </div>
                if nutrition is not None and not busy and not error
                else None}
        </section>;
}
