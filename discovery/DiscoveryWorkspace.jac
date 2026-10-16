import from "@jac/runtime" { Link, useNavigate }
import from endpoints {
    culinary_regions,
    recommend_meals,
    restore_meals,
    prepare_candidate
}
import type from graph.views { RegionView, TraditionView }
import type from .views { MealPlan }
import from ..pantry.PantryEditor { PantryEditor }
import from ..pantry.client_state {
    read_pantry,
    read_scope,
    write_scope,
    read_choices,
    save_choices,
    clear_choices
}
import from .MealCard { MealCard }

def:pub DiscoveryWorkspace(initial_mode: str) -> JsxElement {
    navigate = useNavigate();
    has names: list[str] = [],
        regions: list[RegionView] = [],
        traditions: list[TraditionView] = [],
        selected: str = "",
        tradition: str = "",
        mode: str = "explore",
        meal_plan: MealPlan | None = None,
        busy: bool = True,
        error: str = "",
        message: str = "",
        revision: int = 0;

    def context(region: str, kitchen: str, demo: bool) -> str {
        return mode
            + "|"
            + region
            + "|"
            + kitchen
            + "|"
            + ("demo" if demo else "live")
            + "|"
            + ",".join(names);
    }
    async def loadInitial {
        busy = True;
        error = "";
        names = read_pantry();
        mode = "discover" if initial_mode == "discover" else "explore";
        try {
            metadata = await culinary_regions();
            regions = metadata.regions;
            traditions = metadata.traditions;
            stored = read_scope().split("|");
            if mode == "explore" and len(stored) == 2 {
                if stored[0] in [item.key for item in regions] {
                    selected = stored[0];
                }
                if stored[1]
                    in [
                        item.key
                        for item in traditions
                        if item.region_key == selected
                    ] {
                    tradition = stored[1];
                }
            }
            if len(names) > 0 {
                keys = read_choices(context(selected, tradition, False));
                demo: bool = False;
                if len(keys) == 0 and not selected {
                    keys = read_choices(context("", "", True));
                    demo = True;
                }
                if len(keys) > 0 {
                    try {
                        meal_plan = await restore_meals(
                            names, keys, mode, selected, tradition, demo
                        );
                    } except Exception {
                        clear_choices();
                        message = "Saved choices expired or changed. Your pantry is safe; find five meals again.";
                    }
                }
            }
        } except Exception {
            error = "We couldn’t load the culinary navigation. Retry the connection; your pantry is unchanged.";
        }
        busy = False;
    }
    async can with entry {
        await loadInitial();
    }

    async def requestMeals(region: str, kitchen: str, demo: bool) {
        if len(names) == 0 {
            message = "Confirm ingredients before finding meals.";
            return;
        }
        busy = True;
        error = "";
        message = "Finding meals for your ingredients…";
        meal_plan = None;
        clear_choices();
        try {
            response = await recommend_meals(names, mode, region, kitchen, demo);
            meal_plan = response;
            message = "Your five meals are ready."
                if response.ready
                else "We couldn’t find five meals this time. Try again or choose another region.";
            if response.ready and len(response.choices) == 5 {
                save_choices(
                    context(region, kitchen, demo),
                    [choice.candidate.key for choice in response.choices]
                );
            }
        } except Exception {
            error = "Discovery is unavailable. Your confirmed pantry is unchanged. Retry or try the labelled demo choices.";
        }
        busy = False;
    }
    async def findMeals {
        await requestMeals(selected, tradition, False);
    }
    async def demoMeals {
        selected = "";
        tradition = "";
        if mode == "explore" {
            write_scope("|");
        }
        await requestMeals("", "", True);
    }
    def pantryChanged(updated: list[str]) {
        names = updated;
        meal_plan = None;
        message = "";
        error = "";
        clear_choices();
        if len(updated) > 0 {
            revision += 1;
        }
    }
    async can with [revision] entry {
        if revision > 0 {
            await requestMeals(selected, tradition, False);
        }
    }
    async def chooseRegion(key: str) {
        selected = key;
        tradition = "";
        meal_plan = None;
        message = "";
        clear_choices();
        write_scope(key + "|");
        if len(names) > 0 {
            await requestMeals(key, "", False);
        }
    }
    async def chooseTradition(e: ChangeEvent) {
        tradition = e.target.value;
        meal_plan = None;
        clear_choices();
        write_scope(selected + "|" + tradition);
        if len(names) > 0 {
            await requestMeals(selected, tradition, False);
        }
    }
    async def selectMeal(key: str) {
        active = meal_plan;
        if active is None or not active.ready or len(active.choices) != 5 {
            return;
        }
        if key not in [choice.candidate.key for choice in active.choices] {
            return;
        }
        busy = True;
        error = "";
        message = "Preparing your recipe…";
        try {
            prepared = await prepare_candidate(key);
            message = "Your recipe is ready."
                if prepared.ready
                else "We couldn’t prepare this recipe. Try again or choose another meal.";
            if prepared.ready {
                navigate("/recipes/" + prepared.key);
            }
        } except Exception {
            error = "Preparation is unavailable. Your five choices remain here; select the meal again to retry.";
        }
        busy = False;
    }

    active = meal_plan;
    selected_description = "Choose a region, or explore them all.";
    for region in regions {
        if region.key == selected {
            selected_description = region.subtitle;
        }
    }
    return
        <div className="page-width discovery-workspace">
            <div className="page-intro">
                <span className="eyebrow">YOUR INGREDIENTS. THE WORLD’S KITCHENS.</span>
                <h1>
                    {"Let dinner" if mode == "discover" else "A world of kitchens."}
                    <br/>
                    <em>
                        {"surprise you."
                            if mode == "discover"
                            else "Start with what you have."}
                    </em>
                </h1>
                <p>Find something delicious with what you have.</p>
            </div>
            <nav className="discovery-mode-nav" aria-label="Discovery modes">
                <Link
                    to="/explore"
                    className={"button primary"
                        if mode == "explore"
                        else "button secondary"}
                    aria-current={"page" if mode == "explore" else None}
                >
                    Explore regions
                </Link>
                <Link
                    to="/discover"
                    className={"button primary"
                        if mode == "discover"
                        else "button secondary"}
                    aria-current={"page" if mode == "discover" else None}
                >
                    Discover worldwide
                </Link>
            </nav>
            <div className="discovery-setup">
                <PantryEditor
                    names={names}
                    disabled={busy}
                    onConfirmed={pantryChanged}
                />
                <section className="culinary-lenses" aria-labelledby="lens-title">
                    <h2 id="lens-title">
                        {"Follow your curiosity"
                            if mode == "explore"
                            else "A little adventure for dinner"}
                    </h2>
                    {<>
                        <p>Explore 15 regions and their culinary traditions.</p>
                        <button
                            type="button"
                            className={"region-choice selected"
                                if not selected
                                else "region-choice"}
                            aria-pressed={not selected}
                            onClick={lambda (e: MouseEvent) { chooseRegion(""); }}
                            disabled={busy}
                        >
                            All regions
                        </button>
                        <div className="region-choice-grid">
                            {[
                                <button
                                    type="button"
                                    key={region.key}
                                    className={"region-choice selected"
                                        if selected == region.key
                                        else "region-choice"}
                                    aria-pressed={selected == region.key}
                                    disabled={busy}
                                    onClick={lambda (e: MouseEvent) { chooseRegion(
                                        region.key
                                    ); }}
                                >
                                    <span aria-hidden="true">{region.motif}</span>
                                    {region.name}
                                </button> for region in regions
                            ]}
                        </div>
                        <p className="selected-region-context">
                            {selected_description}
                        </p>
                        {<label className="tradition-filter">
                            Culinary tradition
                            <select
                                aria-label="Culinary tradition"
                                value={tradition}
                                disabled={busy}
                                onChange={chooseTradition}
                            >
                                <option value="">Any tradition in this region</option>
                                {[
                                    <option key={item.key} value={item.key}>
                                        {item.name}
                                    </option>
                                    for item in traditions
                                    if item.region_key == selected
                                ]}
                            </select>
                        </label>
                            if selected
                            else None}
                    </>
                        if mode == "explore"
                        else <div className="worldwide-intro">
                            <span className="worldwide-mark" aria-hidden="true">◎</span>
                            <p>
                                Discover dishes from around the world, picked for the ingredients you have.
                            </p>
                            <p>A little variety for your next meal.</p>
                        </div>}
                    <button
                        type="button"
                        className="button primary"
                        disabled={busy or len(names) == 0}
                        onClick={findMeals}
                    >
                        {"Working…" if busy else "Find five meals"}
                    </button>
                </section>
            </div>
            {<div role="alert" className="discovery-status">
                <p>{error}</p>
                <button
                    type="button"
                    className="button secondary"
                    disabled={busy}
                    onClick={loadInitial}
                >
                    Retry connection
                </button>
            </div>
                if error
                else None}
            <p role="status" className="discovery-message">{message}</p>
            {<p role="status" className="matching-progress">Finding your next meal…</p>
                if busy
                else None}
            {<section
                className="five-meal-results"
                aria-labelledby="meal-results-title"
            >
                <div className="discovery-heading">
                    <div>
                        <span className="eyebrow">COMPARE BEFORE YOU CHOOSE</span>
                        <h2 id="meal-results-title">
                            {"Your five meal choices"
                                if active.ready
                                else "Still finding your five"}
                        </h2>
                    </div>
                    <span className="result-count">
                        {str(len(active.choices)) + " / 5 meals"}
                    </span>
                </div>
                {<p className="demo-disclosure">
                    Sample recipes · not personalised AI suggestions.
                </p>
                    if active.demo
                    else None}
                <p className="match-disclosure">
                    Compare what you have and what you’ll need. Check amounts in the full recipe.
                </p>
                <div className="five-meal-grid">
                    {[
                        <MealCard
                            key={choice.candidate.key}
                            choice={choice}
                            selectable={active.ready}
                            busy={busy}
                            onSelect={lambda (e: MouseEvent) { selectMeal(
                                choice.candidate.key
                            ); }}
                        /> for choice in active.choices
                    ]}
                </div>
                <details>
                    <summary>Why these choices?</summary>
                    <p>
                        Meals are ranked by ingredients on hand, missing essentials and cooking time. Worldwide discovery also looks for variety.
                    </p>
                </details>
            </section>
                if active is not None
                else None}
            {<div className="discovery-fallback">
                <p>
                    Try a broader region or browse our sample recipes while we find more choices.
                </p>
                <button
                    type="button"
                    className="button secondary"
                    disabled={busy or len(names) == 0}
                    onClick={findMeals}
                >
                    Retry discovery
                </button>
                <button
                    type="button"
                    className="text-button"
                    disabled={busy or len(names) == 0}
                    onClick={demoMeals}
                >
                    Browse sample recipes
                </button>
            </div>
                if not busy and (error or (active is not None and not active.ready))
                else None}
            <details className="discovery-info">
                <summary>About discovery and your pantry</summary>
                <p>
                    When needed, Cooksy sends your ingredient list and chosen region to OpenAI to suggest meals. AI-generated recipes should be checked before cooking.
                </p>
                <p>
                    Your pantry is saved in this browser tab. Some meal choices may become unavailable later; you can search again with the same ingredients.
                </p>
            </details>
        </div>;
}
