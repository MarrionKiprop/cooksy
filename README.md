# Cooksy

Your Ingredients. The World's Kitchens.

Cooksy is a Jac-native culinary discovery and cook-along application in development.
**M4 adds selected recipe details and recoverable cook-along sessions.** Open View
recipe from Explore or a pantry match to see quantities, pantry status, preparation,
substitutions, ordered sample steps and provenance. Start cook-along, mark steps done,
go back, finish, restart or end a session. Progress recovers within the browser tab.
Recipes remain abbreviated, unverified demos; model inference is a later milestone.

## Run locally

Use the supplied Jac 0.37.25 environment (pinned in jac.toml):

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
jac install
jac run --show
jac run --dev
```

Open http://localhost:8000. Development UI uses port 8000; the API uses port 8001.
On WSL, if Windows localhost forwarding fails, run `hostname -I` in WSL and open
`http://<first-WSL-IP>:8000/` from Windows. The user verified this route works.
Keep the server terminal running; use the actual app port printed by Jac if occupied.
No provider keys or environment file are needed for pantry matching. Installation needs
package-registry access. The first server start provisions Jac's local runtime/data.
This is a local development preview; production deployment is a later milestone.
Jac's runtime enables a local admin portal by default; configure its credentials
and deployment settings before exposing this development server publicly.

## Verify

Stop the development server before formatting, checking or building: these commands
can rewrite generated modules, and concurrent HMR can interrupt browser navigation.

```bash
jac fmt . --check
jac check .
jac build --as client
```

Type checks have installed-compiler warnings about JSX/runtime typing and
unused generated state aliases; see docs/evidence/m1-verification.md and the M2 log.
Browser behavior is checked in a real browser rather than a trivial status-string unit test.
Install the browser once, then start `jac run --dev` in a separate terminal:

```bash
node .jac/client/node_modules/@playwright/test/cli.js install chromium
node tests/shell-smoke.mjs
```

The smoke suite covers all routes, deep-link refresh, a 404, keyboard skip link and
region selection, actual RPC requests, offline/reconnect, and 390px/320px layouts.
To regenerate screenshots, use `COOKSY_SCREENSHOTS=1 node tests/shell-smoke.mjs`.
Captures go to /tmp/cooksy-m1-screenshots to avoid Jac watcher reloads. Stop the
server before copying them into docs/screenshots.
Browser binaries and Node are developer tooling, not application implementation.
Run the isolated graph and pantry suites (no fixture attaches to root):

```bash
jac test -d tests
```

With the dev server running, also run `node tests/cooking-smoke.mjs`,
`node tests/pantry-smoke.mjs` and `node tests/discovery-smoke.mjs` for actual
HTTP discovery, 8→2→1 filtering, graph-backed quantities and steps, trace events,
region-reset behavior, mobile layout, empty responses and retry. Use
`COOKSY_SCREENSHOTS=1 node tests/discovery-smoke.mjs` for captures under
/tmp/cooksy-m2-screenshots; copy into docs only after stopping the server.

## Architecture

- `main.jac` renders the file-based route tree and imports shared CSS.
- `pages/layout.jac` supplies navigation, the development disclosure and footer.
- `pages/` contains Home, Explore, Pantry, Cook Along and catch-all routes.
- `components/` contains typed Jac UI components and reactive connectivity state.
- `endpoints.jac` exposes server-pinned connectivity and discovery functions.
- `graph/models.jac` declares culinary nodes and typed relationship/ownership edges.
- `graph/seed.jac` constructs one isolated transient demo graph per request.
- `graph/views.jac` defines typed wire projections from those relationships.
- `walkers/discovery.jac` traverses catalogue → region → tradition → recipe →
  ingredient/step, reads relationship fields, and records actual encounter events.
- `styles/global.css` defines responsive typography, colors, layouts and a decorative
  serving illustration. The illustration is CSS artwork, not a model-generated meal.

M2/M3 use real nodes/edges/walkers. It intentionally rebuilds a small demo graph
per request without persisting or modifying user state. Shared ingredients are reused
within each graph; step order comes from HAS_STEP sequence. The catalogue includes
ownership edges to keep reverse-linked traditions/recipes reachable in transient memory.
M3 adds Pantry/IntakeItem nodes, HAS_INGREDIENT edges, IntakeWalker and
MatchingWalker. M4 adds recoverable cooking sessions; later milestones add durable account-owned
graph memory, structured LLM enrichment and reference-based nutrition calculations. Candidate discovery proposes approximately five
meals; full recipe generation follows selection. The M2 seed is test/demo data,
not a manually maintained production catalogue. Python stays limited to specialised
MobileNet and SDXL inference adapters.

## Pantry storage and score

Names are stored in sessionStorage for this browser tab/origin and sent to the
server for matching. Closing the tab normally ends this storage; reopening/duplicating
or browser session restoration may restore it. Clear pantry removes the saved list.
When storage is unavailable, the pantry works in memory until leaving the page.
The server constructs request-local nodes and does not persist pantries to the shared
guest root. Runtime report logs may include supplied names. Account sync and
durable pantry persistence are not implemented.

A small explicit alias map normalizes names, case and whitespace. It does not infer
quantities or silently add staples; invalid entries are shown for correction.
Raw chickpeas are not treated as already-cooked chickpeas. Photo input is not yet
available, but the walker rejects unconfirmed vision-source suggestions in tests.

Score is floor(100 × directly available essential ingredient types / essential
types). Optional items do not reduce it. Optional-only recipes receive 100; recipes
with no requirements are omitted. Ranking uses fewer missing essentials, higher
coverage, shorter time, then stable recipe key. Edge-listed substitutes are suggestions,
never automatic availability. Amounts, dietary/allergy suitability and full recipe
verification are not checked. Results come from eight explicit demo adaptations.

A failed submission retains the draft and previous pantry. Retry matching refreshes
the committed pantry; submit the retained draft with Add & find meals when ready.

## Recipe detail and cook-along

Open `/recipes/gamja-jeon-demo` or select View recipe on any demo card. RecipeWalker
traverses the culinary graph, and the detail view combines its shared projection
with M3 availability. No nutrition or generated serving image is fabricated.

Cook-along has one active session per tab/origin. Starting a new recipe replaces it.
Snapshots contain the stable recipe key, fixture version, current sequence and
finished flag. Jac validates those fields, reconstructs real CookingSession,
CURRENT_STEP and COMPLETED_STEP relationships, traverses steps and applies the action.
Back rewinds the completed prefix; finishing completes the last step; restart clears
progress. Invalid keys/versions/bounds fail safely and can be discarded in the UI.
Snapshots record user progress, not independently verified cooking completion.

Progress is saved to sessionStorage; a client module memory fallback survives route
navigation when storage is blocked, with a visible warning that refresh recovery
will be lost. There is no server-owned durable session or cross-device account sync.
Runtime report logs may include recipe/progress data. Timers and contextual AI help
are deferred. Sample steps are not a complete cooking guide.

`get_recipe` requires recipe_key and ingredients. `cook_session` requires all five
fields: recipe_key, current_sequence, finished, action and version. Clients send
these explicitly because omitted intermediate defaults were mishandled by the
installed HTTP binder. Incomplete requests are tested as validation failures.

`COOKSY_SCREENSHOTS=1 node tests/cooking-smoke.mjs` writes reviewed captures under
/tmp/cooksy-m4-screenshots; stop the server before copying them into docs.

## Providers and limitations

No provider is configured. `.env.example` lists proposed settings, explicitly not
runtime functionality. M5 will verify the installed by-llm guide, select/test a model
provider and document server-side credentials and activation. M6 will document vision
weights/preprocessing and require confirmation before pantry mutation. M7 will document
SDXL local/hosted contracts, caching and the required illustrative AI label. Nutrition
will use referenced measurements or disclosed demo estimates. None of those integrations
has been exercised in M1.

## Project memory and GitHub

The original [implementation guidance](docs/briefs/implementation-guidance.md) and
[architecture](docs/briefs/technical-architecture.md) are preserved verbatim.
Resume using [NEXT_SESSION.md](NEXT_SESSION.md); see [progress](docs/PROGRESS.md),
[decisions](docs/DECISIONS.md), and [M1 verification](docs/evidence/m1-verification.md), and
[M2 verification](docs/evidence/m2-verification.md), and
[M3 verification](docs/evidence/m3-verification.md), and
[M4 verification](docs/evidence/m4-verification.md).

Remote: [MarrionKiprop/cooksy](https://github.com/MarrionKiprop/cooksy), branch main.
SSH uses the existing ~/.ssh/id_ed25519 key through repository-local Git configuration.
After checked milestone/recovery commits, `git push` and verify remote main equals
local HEAD. Never commit keys, .env, generated runtime/data, models or user uploads.
