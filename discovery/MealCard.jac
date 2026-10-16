import type from .views { MealChoice }

def:pub MealCard(
    choice: MealChoice,
    selectable: bool,
    busy: bool,
    onSelect: Callable[[MouseEvent], None]
) -> JsxElement {
    item = choice.candidate;
    return
        <article className="meal-card">
            <div className="seed-meta">
                <span>{item.region + " · " + item.tradition}</span>
                <span>{str(item.minutes) + " min"}</span>
            </div>
            <span
                className={"readiness "
                    + ("ready" if len(item.missing) == 0 else "shopping")}
            >
                {choice.readiness}
            </span>
            <h3>{item.name}</h3>
            <p>{item.description}</p>
            <p>{str(item.score) + "% ingredient match"}</p>
            <p>
                {"On hand: " + ", ".join(choice.available)
                    if len(choice.available) > 0
                    else "No listed ingredients on hand yet."}
            </p>
            <p>
                {"Missing essentials: " + ", ".join(item.missing)
                    if len(item.missing) > 0
                    else "You have the essential ingredients."}
            </p>
            {<p>{"Optional: " + ", ".join(choice.optional)}</p>
                if len(choice.optional) > 0
                else None}
            <span className="recipe-kind">
                {"Sample recipe" if item.key.endswith("-demo") else "AI-generated"}
            </span>
            <button
                type="button"
                className="button primary"
                disabled={busy or not selectable}
                onClick={onSelect}
            >
                {"View recipe" if item.prepared else "Choose this meal"}
            </button>
        </article>;
}
