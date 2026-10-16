import from endpoints { cooking_help }

def:pub StepHelp(
    recipe_key: str, sequence: int, finished: bool, version: str
) -> JsxElement {
    has question: str = "",
        busy: bool = False,
        message: str = "",
        quotes: list[str] = [];
    can with [recipe_key, sequence, finished] entry {
        question = "";
        message = "";
        quotes = [];
    }
    async def ask {
        busy = True;
        quotes = [];
        message = "Looking only at this recipe step…";
        asked_key = recipe_key;
        asked_sequence = sequence;
        asked_finished = finished;
        try {
            result = await cooking_help(
                recipe_key, sequence, finished, version, question
            );
            if recipe_key == asked_key
                and sequence == asked_sequence
                and finished == asked_finished {
                quotes = result.quotes;
                message = result.message;
            }
        } except Exception {
            message = "Help is unavailable. Your cooking progress is unchanged.";
        }
        busy = False;
    }
    return
        <section className="step-help" aria-labelledby="step-help-title">
            <h3 id="step-help-title">A little clarity for this step</h3>
            <p>
                AI can point to relevant wording in the current instruction. If the recipe does not contain an answer, it will say so.
            </p>
            <label>
                Question about this step
                <input
                    maxLength={500}
                    value={question}
                    disabled={busy or finished}
                    onChange={lambda (e: ChangeEvent) { question = e.target.value; }}
                />
            </label>
            <p className="fixture-note">
                Your question and current recipe step are sent to OpenAI. No chat history is saved.
            </p>
            <button
                className="button secondary"
                type="button"
                onClick={ask}
                disabled={busy or finished or not question.strip()}
            >
                {"Finding wording…" if busy else "Ask about this step"}
            </button>
            <div role="status">
                <p>{message}</p>
                {[<blockquote key={quote}>{quote}</blockquote> for quote in quotes]}
            </div>
        </section>;
}
