import from "@jac/runtime" { Link }
import from ..components.RegionCard { RegionCard }
import from ..components.RecipeSeedCard { RecipeSeedCard }
import from endpoints { discover }
import from graph.views { RegionView, TraditionView, RecipeView, TraversalEvent }

def:pub Explore() -> JsxPage {
    has selected: str = "",
        tradition: str = "",
        loading: bool = True,
        error: str = "",
        regions: list[RegionView] = [],
        traditions: list[TraditionView] = [],
        recipes: list[RecipeView] = [],
        events: list[TraversalEvent] = [];

    async def loadDiscovery {
        loading = True;
        error = "";
        try {
            response = await discover(selected, tradition);
            regions = response.regions;
            traditions = response.traditions;
            recipes = response.recipes;
            events = response.events;
        } except Exception {
            error = "We couldn’t reach the demo kitchen. Please try again.";
        }
        loading = False;
    }

    async can with [selected, tradition] entry {
        await loadDiscovery();
    }

    def chooseRegion(key: str) {
        selected = key;
        tradition = "";
    }

    selection_name = "All regions";
    for region in regions {
        if region.key == selected {
            selection_name = region.name;
        }
    }

    return
        <div className="page-width explore-page">
            <div className="page-intro">
                <span className="eyebrow">LET YOUR APPETITE WANDER</span>
                <h1>
                    A world of kitchens.
                    <br/>
                    <em>Where shall we begin?</em>
                </h1>
                <p>
                    Choose a region, meet its kitchens, and browse a small collection of demo recipes.
                </p>
            </div>
            <p className="demo-disclosure">
                Demo collection · Eight illustrative adaptations across four regions. No AI inference. Match these demos from My pantry. This is a small sample, not the full world of Cooksy.
            </p>
            <div className="explore-toolbar">
                <span>Pick your inspiration</span>
                <button
                    type="button"
                    className={"filter-button selected"
                        if not selected
                        else "filter-button"}
                    aria-pressed={not selected}
                    disabled={loading}
                    onClick={lambda (e: MouseEvent) { chooseRegion(""); }}
                >
                    All regions
                </button>
            </div>
            <div className="region-grid">
                {[
                    <RegionCard
                        key={region.key}
                        name={region.name}
                        subtitle={region.subtitle}
                        motif={region.motif}
                        tone={region.tone}
                        selected={selected == region.key}
                        disabled={loading}
                        onSelect={lambda (e: MouseEvent) { chooseRegion(region.key); }}
                    /> for region in regions
                ]}
            </div>
            <section className="selection-panel" aria-labelledby="selection-title">
                <div>
                    <span className="eyebrow">YOUR NEXT ADVENTURE</span>
                    <h2 id="selection-title">{selection_name}</h2>
                    <p>
                        Recipes below come from the demo culinary graph. Compare these demo recipes with your ingredients in My pantry.
                    </p>
                </div>
                <Link to="/pantry" className="button primary">
                    Visit my pantry{" "}
                    <span aria-hidden="true">→</span>
                </Link>
            </section>
            <section
                className="discovery-section"
                aria-labelledby="discovery-title"
                aria-busy={loading}
            >
                <div className="discovery-heading">
                    <div>
                        <span className="eyebrow">A TASTE OF WHAT’S POSSIBLE</span>
                        <h2 id="discovery-title">Recipes to get curious about.</h2>
                    </div>
                    <div className="tradition-filter">
                        <label htmlFor="tradition">Kitchen tradition</label>
                        <select
                            id="tradition"
                            value={tradition}
                            disabled={loading}
                            onChange={lambda (e: ChangeEvent) { tradition = e.target.value; }}
                        >
                            <option value="">All traditions</option>
                            {[
                                <option key={item.key} value={item.key}>
                                    {item.name}
                                </option> for item in traditions
                            ]}
                        </select>
                    </div>
                </div>
                {<p role="status" className="discovery-status">
                    Exploring the demo kitchens…
                </p>
                    if loading
                    else None}
                {<div role="alert" className="discovery-status">
                    <p>{error}</p>
                    <button
                        type="button"
                        className="button secondary"
                        onClick={loadDiscovery}
                    >
                        Retry discovery
                    </button>
                </div>
                    if error
                    else None}
                {<div className="recipe-grid">
                    {[
                        <RecipeSeedCard key={recipe.key} recipe={recipe}/>
                        for recipe in recipes
                    ]}
                </div>
                    if not loading and not error
                    else None}
                {<p className="discovery-status">
                    No demo recipes match this selection. Try another region or tradition.
                </p>
                    if not loading and not error and not recipes
                    else None}
                <p aria-live="polite" className="result-count">
                    {"Exploring…" if loading else str(len(recipes)) + " demo recipes"}
                </p>
            </section>
            <details className="graph-trace">
                <summary>Behind the scenes: graph traversal</summary>
                <p>
                    Actual DiscoveryWalker encounters for the current response. Shared ingredients are listed once. No model was called.
                </p>
                <ol>
                    {[
                        <li key={index}><span>{event.kind}</span> {event.label}</li>
                        for (index, event) in enumerate(events)
                    ]}
                </ol>
            </details>
        </div>;
}
