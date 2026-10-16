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
            message = received.message;
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
            <p>
                Optional illustration of this selected recipe. Generation uses the recipe’s ingredients and method. A configured hosted provider receives that recipe information only when you request a preview.
            </p>
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
                aria-label="Demo plate layout; no AI image generated"
            >
                <div className="preview-plate" aria-hidden="true">✳</div>
                <strong>{name}</strong>
                <p>DEMO layout · No SDXL image generated</p>
                <p>
                    AI-generated serving preview; illustrative, not an exact photograph.
                </p>
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
                    Try demo layout
                </button>
            </div>
            <p role="status">
                {message
                    if message
                    else (
                        preview.message
                            if preview is not None
                            else "Checking for a saved preview…"
                    )}
            </p>
            {<details>
                <summary>About this preview</summary>
                <p>
                    {preview.model
                        + " · "
                        + preview.provider
                        + (" · Reused cached result" if preview.cached else "")}
                </p>
                <p>
                    {"Created: " + preview.created_at + " · Seed: " + str(preview.seed)}
                </p>
                <p className="preview-prompt">{preview.prompt}</p>
            </details>
                if preview is not None and preview.status in ["ready", "demo"]
                else None}
            <p className="fixture-note">
                Illustrative appearance, not verification of portions, ingredients or cultural authenticity. Preview cache lasts for this server process; a restart expires it.
            </p>
        </section>;
}
