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
        message = "Checking graph memory and discovering five choices…";
        meal_plan = None;
        clear_choices();
        try {
            response = await recommend_meals(names, mode, region, kitchen, demo);
            meal_plan = response;
            message = response.message;
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
        message = "Preparing only the meal you selected…";
        try {
            prepared = await prepare_candidate(key);
            message = prepared.message;
            if prepared.ready {
                navigate("/recipes/" + prepared.key);
            }
        } except Exception {
            error = "Preparation is unavailable. Your five choices remain here; select the meal again to retry.";
        }
        busy = False;
    }

    active = meal_plan;
    selected_description = "All 15 culinary regions are available; choose a lens or explore without a regional filter.";
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
                <p>
                    One shared pantry. Five meal choices. A full recipe only after you choose.
                </p>
            </div>
            <div className="discovery-mode-nav" aria-label="Discovery modes">
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
            </div>
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
                        <p>
                            15 culinary lenses, with traditions underneath. These are starting points, not claims that cuisines are uniform.
                        </p>
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
                                Discover is your “surprise me” path: worldwide dishes with deliberate variety across culinary traditions, while prioritizing ingredients you have.
                            </p>
                            <p>
                                No regional filter. The same confirmed pantry and recipe flow.
                            </p>
                        </div>}
                    <p className="fixture-note">
                        Finding meals or changing a region/tradition sends confirmed ingredient names and scope to OpenAI GPT-4.1 mini when graph coverage is insufficient. Sentences are interpreted only when you request review. AI dishes remain unverified.
                    </p>
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
            {<p role="status" className="matching-progress">
                Working on your culinary journey…
            </p>
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
                        {str(len(active.choices)) + " / 5 validated"}
                    </span>
                </div>
                {<p className="demo-disclosure">
                    Developer demo fixtures · not live AI discovery.
                </p>
                    if active.demo
                    else None}
                <p className="match-disclosure">
                    Readiness compares ingredient names, not quantities or dietary suitability. Missing essentials remain visible; substitutions are never silently counted as available.
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
                    <ol>
                        {[
                            <li key={str(index)}>{active.events[index]}</li>
                            for index in range(len(active.events))
                        ]}
                    </ol>
                </details>
            </section>
                if active is not None
                else None}
            {<div className="discovery-fallback">
                <p>
                    Five valid choices are needed before recipe selection. Retry, explore a broader region, or try a clearly labelled demo.
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
                    Try demo choices
                </button>
            </div>
                if not busy and (error or (active is not None and not active.ready))
                else None}
            <p className="storage-note">
                Your confirmed pantry is private to this browser tab. Generated culinary memory currently lasts for this server process; restarting may expire saved choices. Photo suggestions need your confirmation. Optional serving previews are on your selected recipe page; live SDXL needs setup. Nutrition is a later module.
            </p>
        </div>;
}
