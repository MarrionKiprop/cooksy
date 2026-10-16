import from endpoints { review_photo_ingredients, confirm_photo_ingredients }
import type from .views { PredictionView }

def:pub PhotoIntake(
    disabled: bool,
    names: list[str],
    onConfirmed: Callable[[list[str]], None],
    onBusy: Callable[[bool], None]
) -> JsxElement {
    has data: str = "",
        preview: str = "",
        busy: bool = False,
        message: str = "",
        receipt: str = "",
        predictions: list[PredictionView] = [],
        selections: list[str] = [],
        model: str = "";

    def set_busy(value: bool) {
        busy = value;
        callback = onBusy as any;
        callback.call(None, value);
    }

    def selected(e: ChangeEvent) {
        target = e.target as any;
        files = target.files;
        data = "";
        preview = "";
        receipt = "";
        predictions = [];
        selections = [];
        if not files or files.length == 0 {
            return;
        }
        file = files[0];
        if file.size > 5242880 or file.type not in ["image/jpeg", "image/png"] {
            message = "Choose a JPEG or PNG image up to 5 MiB.";
            target.value = "";
            return;
        }
        set_busy(True);
        browser = window as any;
        reader: any = new(browser.FileReader);
        reader.onload = lambda (event: any) {
            data = str(reader.result);
            preview = data;
            set_busy(False);
            message = "Photo ready. Choose Review photo to classify locally; nothing is added automatically.";
        };
        reader.onerror = lambda (event: any) {
            set_busy(False);
            message = "Could not read the photo. Try another file.";
        };
        reader.readAsDataURL(file);
        target.value = "";
    }
    async def analyse(demo: bool) {
        if not data {
            return;
        }
        set_busy(True);
        receipt = "";
        predictions = [];
        selections = [];
        try {
            result = await review_photo_ingredients(data, demo);
            predictions = result.predictions;
            selections = ["" for p in result.predictions];
            receipt = result.receipt;
            model = result.model;
            message = result.message;
        } except Exception {
            message = "Photo review failed. Your confirmed pantry is unchanged; try again or type ingredients.";
        }
        set_busy(False);
    }
    def edit(index: int, value: str) {
        selections = [
            value if i == index else name for (i, name) in enumerate(selections)
        ];
    }
    async def confirm {
        set_busy(True);
        try {
            result = await confirm_photo_ingredients(receipt, selections, names, True);
            callback = onConfirmed as any;
            callback.call(None, result.names);
            receipt = "";
            predictions = [];
            selections = [];
            data = "";
            preview = "";
            message = result.message;
        } except Exception {
            message = "Could not confirm suggestions. Use ingredient names only; if review expired, review the photo again. Your pantry is unchanged.";
        }
        set_busy(False);
    }
    return
        <div className="photo-intake">
            <h3>Or start with a photo</h3>
            <p className="fixture-note">
                Choose or take a photo of one prominent ingredient. The baseline supports only some ingredients, such as banana, orange, broccoli and cabbage. Classification suggests alternatives, not a complete inventory. Review every name. Photos are processed locally on this server, not sent to the LLM or saved.
            </p>
            <label htmlFor="pantry-photo">Take or upload an ingredient photo</label>
            <input
                id="pantry-photo"
                type="file"
                accept="image/jpeg,image/png"
                capture="environment"
                disabled={busy or disabled}
                onChange={selected}
            />
            {<img
                className="ingredient-photo"
                src={preview}
                alt="Your ingredient photo for review"
            />
                if preview
                else None}
            <div className="photo-actions">
                <button
                    type="button"
                    className="button secondary"
                    disabled={busy or disabled or not data}
                    onClick={lambda (e: MouseEvent) { analyse(False); }}
                >
                    {"Reviewing photo…" if busy else "Review photo"}
                </button>
                <button
                    type="button"
                    className="text-button"
                    disabled={busy or disabled or not data}
                    onClick={lambda (e: MouseEvent) { analyse(True); }}
                >
                    Try demo suggestions
                </button>
            </div>
            <p role="status">{message}</p>
            {<div className="photo-review">
                <h3>Review photo suggestions</h3>
                <p className="fixture-note">
                    {model
                        + ". Scores are model confidence, not certainty. Fields start blank: accept a suggestion, edit its name, or leave blank to reject."}
                </p>
                {[
                    <div className="photo-prediction" key={str(index)}>
                        <label htmlFor={"photo-name-" + str(index)}>
                            {p.ingredient + " — " + str(int(p.confidence * 100)) + "%"}
                        </label>
                        <input
                            id={"photo-name-" + str(index)}
                            value={selections[index]}
                            maxLength={80}
                            placeholder="Leave blank to reject"
                            disabled={busy or disabled}
                            onChange={lambda (e: ChangeEvent) { edit(
                                index, e.target.value
                            ); }}
                        />
                        <button
                            type="button"
                            className="text-button"
                            disabled={busy or disabled}
                            onClick={lambda (e: MouseEvent) { edit(
                                index, p.ingredient
                            ); }}
                        >
                            {"Accept " + p.ingredient}
                        </button>
                    </div> for (index, p) in enumerate(predictions)
                ]}
                <button
                    type="button"
                    className="button primary"
                    disabled={busy or disabled or not any(selections)}
                    onClick={confirm}
                >
                    Confirm photo ingredients
                </button>
            </div>
                if receipt
                else None}
        </div>;
}
