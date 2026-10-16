import from "@jac/runtime" { Link }
import from endpoints { match_pantry, discover }
import from graph.views { RegionView }
import from .views { MatchView }
import from .MatchCard { MatchCard }

def:pub PantryWorkspace() -> JsxElement {
    has names: list[str] = [],
        matches: list[MatchView] = [],
        regions: list[RegionView] = [],
        draft: str = "",
        selected: str = "",
        error: str = "",
        notice: str = "",
        storage_note: str = "Saved in this browser tab. Sent to Jac only for matching.",
        busy: bool = False;

    def saveNames {
        try {
            sessionStorage.setItem("cooksy.pantry.v1", "|".join(names));
        } except Exception {
            storage_note = "Tab storage is unavailable. Your pantry lasts until you leave this page.";
        }
    }

    async def refreshMatches(proposed: list[str]) -> bool {
        busy = True;
        error = "";
        notice = "";
        try {
            response = await match_pantry(proposed, selected);
            names = response.intake.names;
            matches = response.matches;
            if response.intake.rejected {
                notice = "Please enter names only for: "
                    + ", ".join(response.intake.rejected);
            }
            saveNames();
            return True;
        } except Exception {
            error = "We couldn’t match your pantry. Your ingredients are still here; try again.";
            return False;
        } finally {
            busy = False;
        }
    }

    async def loadInitial {
        busy = True;
        try {
            stored = sessionStorage.getItem("cooksy.pantry.v1");
            if stored {
                names = str(stored).split("|");
            }
        } except Exception {
            storage_note = "Tab storage is unavailable. Your pantry lasts until you leave this page.";
        }
        try {
            discovery = await discover();
            regions = discovery.regions;
            if names {
                await refreshMatches(names);
            }
        } except Exception {
            error = "We couldn’t reach the kitchen. Try again when you’re connected.";
        }
        busy = False;
    }

    async can with entry {
        await loadInitial();
    }

    async def submit(e: FormEvent) {
        e.preventDefault();
        if not draft.strip() and not names {
            notice = "Add at least one ingredient name to get started.";
            return;
        }
        proposed = names + [draft] if draft.strip() else names;
        if await refreshMatches(proposed) {
            draft = "";
        }
    }

    async def removeIngredient(name: str) {
        remaining = [
            item
            for item in names
            if item != name
        ];
        if remaining {
            await refreshMatches(remaining);
        } else {
            names = [];
            matches = [];
            notice = "";
            error = "";
            saveNames();
        }
    }

    def clearPantry(e: MouseEvent) {
        names = [];
        matches = [];
        draft = "";
        notice = "";
        error = "";
        saveNames();
    }

    async def changeRegion(e: ChangeEvent) {
        selected = e.target.value;
        if names {
            await refreshMatches(names);
        }
    }

    async def retry {
        if names {
            await refreshMatches(names);
        } else {
            await loadInitial();
        }
    }

    return
        <div className="page-width pantry-workspace">
            <div className="page-intro">
                <span className="eyebrow">THE BEST PLACE TO START</span>
                <h1>
                    Your pantry,
                    <br/>
                    <em>full of possibility.</em>
                </h1>
                <p>
                    Tell us what’s on your shelf. We’ll show what fits, what’s missing, and why.
                </p>
            </div>
            <div className="pantry-layout">
                <section className="pantry-editor" aria-labelledby="pantry-title">
                    <div className="pantry-editor-heading">
                        <h2 id="pantry-title">What do you have?</h2>
                        <span aria-hidden="true">✳</span>
                    </div>
                    <form onSubmit={submit}>
                        <label htmlFor="ingredient-input">Ingredient names</label>
                        <textarea
                            id="ingredient-input"
                            value={draft}
                            onChange={lambda (e: ChangeEvent) { draft = e.target.value; }}
                            placeholder="Potatoes, eggs, spinach, onion…"
                            rows={4}
                            maxLength={8000}
                            disabled={busy}
                            aria-describedby="ingredient-hint"
                        />
                        <p id="ingredient-hint">
                            Separate names with commas or new lines. Leave out amounts for now. No salt or oil is assumed.
                        </p>
                        <button
                            type="submit"
                            className="button primary"
                            disabled={busy}
                        >
                            {"Matching…" if busy else "Add & find meals"}{" "}
                            <span aria-hidden="true">→</span>
                        </button>
                    </form>
                    <p className="storage-note">{storage_note}</p>
                    <div className="pantry-chip-heading">
                        <h3>Your ingredients <span>{len(names)}</span></h3>
                        <button
                            type="button"
                            className="text-button"
                            disabled={busy or not names}
                            onClick={clearPantry}
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
                                    disabled={busy}
                                    onClick={lambda (e: MouseEvent) { removeIngredient(
                                        name
                                    ); }}
                                >
                                    ×
                                </button>
                            </li> for name in names
                        ]}
                    </ul>
                    {<p className="pantry-empty">
                        A few simple ingredients can open up a world of meals.
                    </p>
                        if not names
                        else None}
                    <p className="pantry-notice" role="status">{notice}</p>
                    <p className="photo-note">
                        Photo suggestions are coming later. You’ll always confirm them before they reach your pantry.
                    </p>
                </section>
                <section
                    className="pantry-results"
                    aria-labelledby="matches-title"
                    aria-busy={busy}
                >
                    <div className="discovery-heading">
                        <div>
                            <span className="eyebrow">MAKE MORE OF WHAT’S HERE</span>
                            <h2 id="matches-title">Your pantry matches.</h2>
                        </div>
                        <div className="tradition-filter">
                            <label htmlFor="pantry-region">Region</label>
                            <select
                                id="pantry-region"
                                value={selected}
                                onChange={changeRegion}
                                disabled={busy}
                            >
                                <option value="">All regions</option>
                                {[
                                    <option key={region.key} value={region.key}>
                                        {region.name}
                                    </option> for region in regions
                                ]}
                            </select>
                        </div>
                    </div>
                    <p className="match-disclosure">
                        Graph recipes · ranked by fewer missing essentials, then coverage and cooking time. Name coverage only; quantities are not checked. Substitutions never silently count as available.
                    </p>
                    {<div role="alert" className="discovery-status">
                        <p>{error}</p>
                        <button
                            type="button"
                            className="button secondary"
                            onClick={retry}
                            disabled={busy}
                        >
                            Retry matching
                        </button>
                    </div>
                        if error
                        else None}
                    {<p role="status" className="matching-progress">
                        Comparing your pantry with recipe requirements…
                    </p>
                        if busy
                        else None}
                    {<div className="match-list">
                        {[
                            <MatchCard
                                key={candidate.recipe.key}
                                candidate={candidate}
                            /> for candidate in matches
                        ]}
                    </div>
                        if not busy and not error and names
                        else None}
                    {<div className="matching-empty">
                        <span aria-hidden="true">❋</span>
                        <h3>A little pantry. A lot of possibility.</h3>
                        <p>
                            Add some ingredients to see graph recipes ranked by what you have.
                        </p>
                        <Link to="/explore" className="inline-link">
                            Explore the kitchens{" "}
                            <span aria-hidden="true">↗</span>
                        </Link>
                    </div>
                        if not names and not busy and not error
                        else None}
                    {<p className="discovery-status">
                        No prepared recipes in this region yet. Try all regions.
                    </p>
                        if names and not matches and not busy and not error
                        else None}
                </section>
            </div>
        </div>;
}
