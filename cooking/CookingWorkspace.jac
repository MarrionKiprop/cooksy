import from ..ai.StepHelp { StepHelp }
import from "@jac/runtime" { Link }
import from endpoints { cook_session }
import type from .views { CookingView }
import from .client_state { read_session, save_session, clear_session }

def:pub CookingWorkspace() -> JsxElement {
    has state: CookingView | None = None,
        busy: bool = True,
        error: str = "",
        recipe_key: str = "",
        current: int = 1,
        finished: bool = False,
        version: str = "cooksy-demo-v1",
        storage_note: str = "Progress saved in this tab.";

    async def updateSession(action: str) {
        busy = True;
        error = "";
        try {
            response = await cook_session(
                recipe_key, current, finished, action, version
            );
            state = response;
            current = response.current_sequence;
            finished = response.finished;
            if not save_session(response) {
                storage_note = "Tab storage is unavailable. Progress survives navigation here, but not a refresh.";
            }
        } except Exception {
            error = "We couldn’t update your session. Your last saved step is unchanged. Try again or start a new session.";
        }
        busy = False;
    }

    async def loadInitial {
        snapshot = read_session();
        if not snapshot {
            busy = False;
            return;
        }
        try {
            parts = snapshot.split("|");
            if len(parts) != 4 or parts[3] not in ["0", "1"] {
                raise ValueError("Invalid progress format");
            }
            version = parts[0];
            recipe_key = parts[1];
            current = int(parts[2]);
            finished = parts[3] == "1";
            await updateSession("resume");
        } except Exception {
            error = "Saved progress could not be restored. Discard it and choose a recipe to start again.";
        }
        busy = False;
    }
    async can with entry {
        await loadInitial();
    }

    def discard(e: MouseEvent) {
        clear_session();
        state = None;
        recipe_key = "";
        current = 1;
        finished = False;
        error = "";
    }
    async def retry {
        await updateSession("resume");
    }
    async def nextStep {
        await updateSession("next");
    }
    async def previousStep {
        await updateSession("back");
    }
    async def restart {
        await updateSession("restart");
    }

    active = state;
    return
        <div className="page-width cooking-workspace">
            <div className="page-intro">
                <span className="eyebrow">A LITTLE FOCUS. A DELICIOUS FINISH.</span>
                <h1>
                    One step
                    <br/>
                    <em>at a time.</em>
                </h1>
                <p>Follow your selected recipe, with progress you can return to.</p>
            </div>
            {<p role="status" className="discovery-status">
                Opening your cooking session…
            </p>
                if busy
                else None}
            {<div role="alert" className="discovery-status">
                <p>{error}</p>
                <button
                    type="button"
                    className="button secondary"
                    onClick={retry}
                    disabled={busy}
                >
                    Retry session
                </button>
                <button
                    type="button"
                    className="text-button"
                    onClick={discard}
                    disabled={busy}
                >
                    Discard saved session
                </button>
            </div>
                if error
                else None}
            {<section className="cook-session" aria-labelledby="active-recipe">
                <div className="cook-session-heading">
                    <div>
                        <span className="small-tag">
                            {"SAMPLE RECIPE"
                                if active.recipe_key.endswith("-demo")
                                else "AI-GENERATED RECIPE"}
                        </span>
                        <h2 id="active-recipe">{active.recipe_name}</h2>
                    </div>
                    <Link to={"/recipes/" + active.recipe_key} className="inline-link">
                        View recipe →
                    </Link>
                </div>
                <p className="fixture-note">
                    Check ingredient amounts and doneness as you cook.
                </p>
                <div className="cook-progress">
                    <span aria-live="polite">
                        {str(len(active.completed))
                            + " of "
                            + str(active.total_steps)
                            + " steps completed"}
                    </span>
                    <progress
                        aria-label="Cooking progress"
                        value={len(active.completed)}
                        max={active.total_steps}
                    ></progress>
                </div>
                <article className="active-step" aria-live="polite">
                    <span className="eyebrow">
                        {"SESSION COMPLETE"
                            if active.finished
                            else "STEP "
                                + str(active.current_sequence)
                                + " OF "
                                + str(active.total_steps)}
                    </span>
                    <h3>
                        {"You’ve reached the end of this recipe."
                            if active.finished
                            else active.instruction}
                    </h3>
                    <p>
                        {"Your progress is saved. You can review the last step or restart."
                            if active.finished
                            else "Take your time. Mark this step done when you’re ready to move on."}
                    </p>
                </article>
                <div className="cook-controls">
                    <button
                        type="button"
                        className="button secondary"
                        onClick={previousStep}
                        disabled={busy
                            or (active.current_sequence == 1 and not active.finished)}
                    >
                        {"Review final step" if active.finished else "← Back a step"}
                    </button>
                    <button
                        type="button"
                        className="button primary"
                        onClick={nextStep}
                        disabled={busy or active.finished}
                    >
                        {"Finish session"
                            if active.current_sequence == active.total_steps
                            else "Mark done & continue →"}
                    </button>
                </div>
                <StepHelp
                    key={active.recipe_key
                        + str(active.current_sequence)
                        + str(active.finished)}
                    recipe_key={active.recipe_key}
                    sequence={active.current_sequence}
                    finished={active.finished}
                    version={active.version}
                />
                <div className="cook-session-bottom">
                    <p className="storage-note">{storage_note}</p>
                    <button
                        type="button"
                        className="text-button"
                        onClick={restart}
                        disabled={busy}
                    >
                        Restart this recipe
                    </button>
                    <button
                        type="button"
                        className="text-button"
                        onClick={discard}
                        disabled={busy}
                    >
                        End session
                    </button>
                </div>
            </section>
                if active is not None
                else None}
            {<section className="empty-kitchen">
                <div className="empty-art" aria-hidden="true">◷</div>
                <h2>Your next cooking adventure awaits.</h2>
                <p>
                    Open a recipe from Explore or your pantry matches, then start a cook-along session.
                </p>
                <Link to="/explore" className="button primary">
                    Explore the kitchens ↗
                </Link>
            </section>
                if active is None and not busy and not error
                else None}
        </div>;
}
