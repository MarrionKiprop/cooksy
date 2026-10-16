import from endpoints { review_ingredients, confirm_ingredients }
import from .client_state { write_pantry }
import from vision.PhotoIntake { PhotoIntake }

def:pub PantryEditor(
    names: list[str], disabled: bool, onConfirmed: Callable[[list[str]], None]
) -> JsxElement {
    has draft: str = "",
        proposed: str = "",
        reviewing: bool = False,
        busy: bool = False,
        message: str = "",
        uncertainty: list[str] = [],
        storage_note: str = "Saved in this browser tab.";

    def notify(updated: list[str]) {
        callback = onConfirmed as any;
        callback.call(None, updated);
    }

    def photo_busy(value: bool) {
        busy = value;
    }

    def photo_confirmed(updated: list[str]) {
        if not write_pantry(updated) {
            storage_note = "Storage unavailable; shared pantry survives navigation, not refresh.";
        }
        notify(updated);
    }

    async def review(e: FormEvent) {
        e.preventDefault();
        if not draft.strip() {
            message = "Enter ingredients to review first.";
            return;
        }
        busy = True;
        try {
            result = await review_ingredients(draft);
            proposed = ", ".join(result.names);
            uncertainty = result.uncertain;
            reviewing = result.status == "review";
            message = "Check the names below, then add them to your pantry."
                if result.status == "review"
                else result.message;
        } except Exception {
            message = "We couldn’t review that text. Your confirmed pantry is unchanged. Try again.";
        }
        busy = False;
    }
    async def confirm {
        busy = True;
        try {
            result = await confirm_ingredients([proposed]);
            if len(result.rejected) > 0 {
                message = "Correct these entries before confirming: "
                    + ", ".join(result.rejected);
            } elif len(result.names) == 0 {
                message = "Confirm at least one ingredient name.";
            } else {
                combined = await confirm_ingredients(names + result.names);
                if not write_pantry(combined.names) {
                    storage_note = "Tab storage is unavailable. Your shared pantry survives navigation, but not refresh.";
                }
                notify(combined.names);
                reviewing = False;
                proposed = "";
                draft = "";
                uncertainty = [];
                message = "Pantry updated.";
            }
        } except Exception {
            message = "We couldn’t save these names. Your previous pantry and review are unchanged; try again.";
        }
        busy = False;
    }
    def remove(name: str) {
        remaining = [
            item
            for item in names
            if item != name
        ];
        if not write_pantry(remaining) {
            storage_note = "Storage unavailable; this pantry lasts while this app remains open.";
        }
        notify(remaining);
        message = "Pantry updated.";
    }
    def clear(e: MouseEvent) {
        write_pantry([]);
        notify([]);
        draft = "";
        proposed = "";
        reviewing = False;
        uncertainty = [];
        message = "Pantry cleared.";
    }
    return
        <section className="shared-pantry" aria-labelledby="pantry-title">
            <div className="pantry-editor-heading">
                <h2 id="pantry-title">What do you have?</h2>
                <span aria-hidden="true">✳</span>
            </div>
            <form onSubmit={review}>
                <label htmlFor="ingredient-input">Describe your ingredients</label>
                <textarea
                    id="ingredient-input"
                    rows={3}
                    maxLength={8000}
                    value={draft}
                    disabled={busy or disabled}
                    placeholder="I have potatoes, eggs, spinach and onions."
                    onChange={lambda (e: ChangeEvent) { draft = e.target.value; }}
                />
                <p className="fixture-note">
                    Write a sentence or list ingredients separated by commas. Review the names before adding them.
                </p>
                <button
                    type="submit"
                    className="button secondary"
                    disabled={busy or disabled}
                >
                    {"Reviewing…" if busy else "Review ingredients"}
                </button>
            </form>
            {<div className="intake-review">
                <h3>Review before adding</h3>
                <label htmlFor="reviewed-ingredients">
                    Edit proposed ingredient names
                </label>
                <textarea
                    id="reviewed-ingredients"
                    value={proposed}
                    rows={2}
                    maxLength={8000}
                    disabled={busy or disabled}
                    onChange={lambda (e: ChangeEvent) { proposed = e.target.value; }}
                />
                {<p role="status">{"Please clarify: " + "; ".join(uncertainty)}</p>
                    if len(uncertainty) > 0
                    else None}
                <button
                    type="button"
                    className="button primary"
                    disabled={busy or disabled}
                    onClick={confirm}
                >
                    Confirm & find meals
                </button>
            </div>
                if reviewing
                else None}
            <PhotoIntake
                names={names}
                disabled={busy or disabled}
                onConfirmed={photo_confirmed}
                onBusy={photo_busy}
            />
            <p className="pantry-notice" role="status">{message}</p>
            <div className="pantry-chip-heading">
                <h3>Confirmed ingredients <span>{len(names)}</span></h3>
                <button
                    type="button"
                    className="text-button"
                    disabled={busy or disabled or len(names) == 0}
                    onClick={clear}
                >
                    Clear pantry
                </button>
            </div>
            <ul className="pantry-chips">
                {[
                    <li key={name}>
                        <span>{name}</span>
                        <button
                            type="button"
                            aria-label={"Remove " + name}
                            disabled={busy or disabled}
                            onClick={lambda (e: MouseEvent) { remove(name); }}
                        >
                            ×
                        </button>
                    </li> for name in names
                ]}
            </ul>
            {<p className="pantry-empty">
                Start with a few ingredients and a little curiosity.
            </p>
                if len(names) == 0
                else None}
            <p className="storage-note">{storage_note}</p>
        </section>;
}
