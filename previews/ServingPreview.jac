import from endpoints { serving_preview }
import type from .views { PreviewView }

def:pub ServingPreview(recipeKey: str, version: str, name: str) -> JsxElement {
    has state: PreviewView | None = None,
        busy: bool = False,
        loading: bool = True,
        message: str = "";
    async can with [recipeKey, version] entry {
        loading = True;
        try {
            restored = await serving_preview(recipeKey, version, False, False);
            if restored.status == "not_requested" {
                restored = await serving_preview(recipeKey, version, False, True);
            }
            state = restored;
        } except Exception {
            message = "Serving previews are unavailable. You can still view and cook this recipe.";
        }
        loading = False;
    }
    async def request(demo: bool) {
        busy = True;
        message = "";
        try {
            received = await serving_preview(recipeKey, version, True, demo);
            if received.status in ["ready", "demo"]
                or state is None
                or state.status == "not_requested" {
                state = received;
            }
            message = "Serving previews aren’t available right now."
                if received.status == "unavailable"
                else (
                    "We couldn’t create a preview. Try again later."
                        if received.status == "error"
                        else ""
                );
        } except Exception {
            message = "We couldn’t create that preview. Your recipe and cooking progress are unchanged; try again later.";
        }
        busy = False;
    }
    preview = state;
    return
        <section className="serving-preview" aria-labelledby="serving-preview-title">
            <div>
                <span className="eyebrow">A LITTLE INSPIRATION</span>
                <h2 id="serving-preview-title">Picture your plate.</h2>
            </div>
            <p>A serving illustration based on your recipe.</p>
            {<figure>
                <img
                    src={preview.image}
                    alt={"AI-generated serving illustration of " + name}
                />
                <figcaption>{preview.label}</figcaption>
            </figure>
                if preview is not None and preview.status == "ready"
                else None}
            {<div
                className="preview-demo"
                role="img"
                aria-label="Sample serving layout; no image generated"
            >
                <div className="preview-plate" aria-hidden="true">✳</div>
                <strong>{name}</strong>
                <p>Sample layout · No image generated</p>
            </div>
                if preview is not None and preview.status == "demo"
                else None}
            <div className="preview-actions">
                <button
                    type="button"
                    className="button secondary"
                    disabled={busy or loading}
                    onClick={lambda (e: MouseEvent) { request(False); }}
                >
                    {"Creating preview…" if busy else "Generate serving preview"}
                </button>
                <button
                    type="button"
                    className="text-button"
                    disabled={busy or loading}
                    onClick={lambda (e: MouseEvent) { request(True); }}
                >
                    View sample layout
                </button>
            </div>
            <p role="status">
                {message
                    if message
                    else (
                        "Sample layout only. No image generated."
                            if preview is not None and preview.status == "demo"
                            else (
                                "Create an illustration of your finished dish."
                                    if preview is not None
                                        and preview.status == "not_requested"
                                    else ""
                            )
                    )}
            </p>
            <details>
                <summary>About this preview</summary>
                <p>
                    Serving illustrations may differ from the finished meal. When image generation is available, recipe details are sent to the image provider only when you request a preview.
                </p>
            </details>
        </section>;
}
