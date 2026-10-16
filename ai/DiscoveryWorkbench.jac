import from .CandidateCard { CandidateCard }
import from "@jac/runtime" { useNavigate }
import from endpoints { enrich, prepare_candidate }
import type from .views { CandidateView }

def:pub DiscoveryWorkbench() -> JsxElement {
    navigate = useNavigate();
    has cuisine: str = "",
        ingredients: str = "",
        busy: bool = False,
        message: str = "",
        events: list[str] = [],
        candidates: list[CandidateView] = [];
    can with entry {
        try {
            stored = (sessionStorage.getItem("cooksy.pantry.v1") or "") as str;
            ingredients = ", ".join(stored.split("|"));
        } except Exception {
            ingredients = "";
        }
    }
    async def search {
        busy = True;
        message = "Checking culinary graph coverage…";
        try {
            result = await enrich([ingredients], cuisine);
            candidates = result.candidates;
            events = result.events;
            message = result.message;
        } except Exception {
            message = "Discovery is unavailable. Try again; the demo collection remains below.";
        }
        busy = False;
    }
    async def select(key: str) {
        busy = True;
        message = "Preparing only your selected recipe…";
        try {
            result = await prepare_candidate(key);
            message = result.message;
            if result.ready {
                navigate("/recipes/" + result.key);
            }
        } except Exception {
            message = "Recipe preparation failed. Your candidates remain available; try again.";
        }
        busy = False;
    }
    return
        <section className="ai-workbench" aria-labelledby="ai-discovery-title">
            <span className="eyebrow">BEYOND THE DEMO COLLECTION</span>
            <h2 id="ai-discovery-title">What could your ingredients become?</h2>
            <p>
                Check existing dishes first, then ask AI when fewer than five candidates cover your cuisine. Scores compare ingredient names, not quantities. These discovery inputs do not change your saved pantry.
            </p>
            <div className="ai-fields">
                <label>
                    Cuisine or region
                    <input
                        value={cuisine}
                        maxLength={80}
                        placeholder="Try Italian, Mexican, or leave blank"
                        onChange={lambda (e: ChangeEvent) { cuisine = e.target.value; }}
                        disabled={busy}
                    />
                </label>
                <label>
                    Ingredients to discover with
                    <textarea
                        value={ingredients}
                        maxLength={8000}
                        placeholder="tomato, onion, rice"
                        onChange={lambda (e: ChangeEvent) { ingredients = e.target.value; }}
                        disabled={busy}
                    />
                </label>
            </div>
            <p className="fixture-note">
                Searching may send these ingredient names and cuisine to OpenAI GPT-4.1 mini. AI dishes are unverified and cached for this server process only; restarting clears them. No dietary, allergy or nutrition guarantees.
            </p>
            <button
                className="button primary"
                type="button"
                disabled={busy}
                onClick={search}
            >
                {"Working…" if busy else "Discover dishes"}
            </button>
            <p role="status" className="ai-message">{message}</p>
            <div className="ai-candidates">
                {[
                    <CandidateCard
                        key={item.key}
                        candidate={item}
                        busy={busy}
                        onSelect={lambda (e: MouseEvent) { select(item.key); }}
                    /> for item in candidates
                ]}
            </div>
            {<details>
                <summary>Discovery execution</summary>
                <ol>
                    {[
                        <li key={str(index)}>{events[index]}</li>
                        for index in range(len(events))
                    ]}
                </ol>
            </details>
                if len(events)
                else None}
        </section>;
}
