import from "@jac/runtime" { Link }
import from ..components.RegionCard { RegionCard }

def:pub Explore() -> JsxPage {
    has selected: str = "All regions";
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
                    Choose a place that sparks your curiosity. This preview introduces the regions; recipe discovery is coming soon.
                </p>
            </div>
            <div className="explore-toolbar">
                <span>Pick your inspiration</span>
                <button
                    type="button"
                    className={"filter-button selected"
                        if selected == "All regions"
                        else "filter-button"}
                    aria-pressed={selected == "All regions"}
                    onClick={lambda (e: MouseEvent) { selected = "All regions"; }}
                >
                    All regions
                </button>
            </div>
            <div className="region-grid">
                <RegionCard
                    name="East Africa"
                    subtitle="Explore Kenyan, Ethiopian and Tanzanian kitchens."
                    motif="❋"
                    tone="terracotta"
                    selected={selected == "East Africa"}
                    onSelect={lambda (e: MouseEvent) { selected = "East Africa"; }}
                />
                <RegionCard
                    name="East Asia"
                    subtitle="Explore Korean, Japanese and Chinese kitchens."
                    motif="◒"
                    tone="sage"
                    selected={selected == "East Asia"}
                    onSelect={lambda (e: MouseEvent) { selected = "East Asia"; }}
                />
                <RegionCard
                    name="South Asia"
                    subtitle="Explore Indian, Sri Lankan and Pakistani kitchens."
                    motif="✷"
                    tone="saffron"
                    selected={selected == "South Asia"}
                    onSelect={lambda (e: MouseEvent) { selected = "South Asia"; }}
                />
                <RegionCard
                    name="The Mediterranean"
                    subtitle="Explore Greek, Turkish and Italian kitchens."
                    motif="☼"
                    tone="lavender"
                    selected={selected == "The Mediterranean"}
                    onSelect={lambda (e: MouseEvent) { selected = "The Mediterranean"; }}
                />
            </div>
            <section className="selection-panel" aria-labelledby="selection-title">
                <div>
                    <span className="eyebrow">YOUR NEXT ADVENTURE</span>
                    <h2 id="selection-title" aria-live="polite">{selected}</h2>
                    <p>
                        Region selection is a local preview. Pantry matching and recipe discovery are not connected yet.
                    </p>
                </div>
                <Link to="/pantry" className="button primary">
                    Visit my pantry{" "}
                    <span aria-hidden="true">→</span>
                </Link>
            </section>
        </div>;
}
