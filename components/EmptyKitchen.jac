import from "@jac/runtime" { Link }

def:pub EmptyKitchen(kind: str) -> JsxElement {
    pantry = kind == "pantry";
    return
        <div className="page-width workspace-page">
            <div className="page-intro">
                <span className="eyebrow">
                    {"THE BEST PLACE TO START"
                        if pantry
                        else "A LITTLE FOCUS. A DELICIOUS FINISH."}
                </span>
                <h1>
                    {"Your pantry," if pantry else "One step"}
                    <br/>
                    <em>{"full of possibility." if pantry else "at a time."}</em>
                </h1>
                <p>
                    {"Great meals begin with what’s already on your shelf."
                        if pantry
                        else "A calmer way to cook, with one clear task in front of you."}
                </p>
            </div>
            <section className="empty-kitchen">
                <div className="empty-art" aria-hidden="true">
                    {"⌑" if pantry else "◷"}
                </div>
                <span className="small-tag">
                    {"PANTRY · COMING SOON" if pantry else "COOK ALONG · COMING SOON"}
                </span>
                <h2>
                    {"A fresh start for your shelf"
                        if pantry
                        else "Your next cooking adventure awaits"}
                </h2>
                <p>
                    {"Ingredient entry, confirmed photo suggestions and pantry storage are coming in a later milestone. Nothing is stored in this shell preview."
                        if pantry
                        else "Choose a recipe when discovery is available to begin a session. Step progress and timers are not available in this preview."}
                </p>
                <Link to="/explore" className="button primary">
                    Explore the kitchens{" "}
                    <span aria-hidden="true">↗</span>
                </Link>
            </section>
            <div className="gentle-note">
                <span aria-hidden="true">✳</span>
                <p>
                    {"You’ll always be in control: image suggestions will need your confirmation before reaching your pantry."
                        if pantry
                        else "The planned cook-along will stay grounded in your selected recipe, with progress you can return to."}
                </p>
            </div>
        </div>;
}
