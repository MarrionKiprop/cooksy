import from graph.views { RecipeView }

def:pub RecipeSeedCard(recipe: RecipeView) -> JsxElement {
    return
        <article className="seed-card">
            <div className="seed-meta">
                <span>{recipe.tradition} · {recipe.region}</span>
                <span>{recipe.minutes} min · {recipe.servings} servings</span>
            </div>
            <span className="small-tag">DEMO ADAPTATION · UNVERIFIED</span>
            <h3>{recipe.name}</h3>
            <p>{recipe.description}</p>
            <details>
                <summary>Ingredients and sample steps</summary>
                <p className="fixture-note">
                    {recipe.verification}. These are sample quantities and steps, not a complete cooking guide.
                </p>
                <h4>Ingredients</h4>
                <ul className="requirement-list">
                    {[
                        <li key={item.name}>
                            <div>
                                <strong>{item.name}</strong>
                                <span>
                                    {item.quantity} {item.unit} · {"essential"
                                        if item.essential
                                        else "optional"}
                                </span>
                            </div>
                            <p>{item.preparation}</p>
                            <p>{item.substitution_notes}</p>
                        </li> for item in recipe.requirements
                    ]}
                </ul>
                <h4>Sample steps</h4>
                <ol>
                    {[
                        <li key={step.sequence}>{step.instruction}</li>
                        for step in recipe.steps
                    ]}
                </ol>
                <p className="fixture-note">
                    Source: {recipe.provenance}. Pantry matching and guided cooking are coming later.
                </p>
            </details>
        </article>;
}
