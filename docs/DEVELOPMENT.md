# Cooksy

Your Ingredients. The World's Kitchens.

Cooksy is a Jac-native culinary discovery and cook-along application in development.
**M0–M8 are implemented as a local development demo.** Review and confirm one
shared ingredient pantry, Explore15regions or Discover varied meals worldwide,
choose from five validated dishes, then open the selected recipe and cook along.
Recipe pages include sourced nutrition estimates/subtotals and an optional preview
panel. Live SDXL is deferred; its demo never pretends to be a generated food image.
AI culinary output and recipe quantities remain unverified.

Start with the [demo walkthrough](DEMO.md), [architecture](ARCHITECTURE.md),
[nutrition methodology](NUTRITION.md) and [recorded follow-ups](FOLLOW_UPS.md).

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
MatchingWalker. M4 adds recoverable cooking sessions; M5 implements structured enrichment. Durable account-owned
graph memory remains future work. M8 adds a small sourced nutrition reference subset. Candidate discovery proposes approximately five
meals; full recipe generation follows selection. The M2 seed is test/demo data,
not a manually maintained production catalogue. Python stays limited to specialised
MobileNet and SDXL inference adapters.

## Pantry storage and score

Names are stored in sessionStorage for this browser tab/origin and sent to the
server for matching. Closing the tab normally ends this storage; reopening/duplicating
or browser session restoration may restore it. Clear pantry removes the saved list.
When storage is unavailable, module memory preserves pantry state across routes;
a full refresh loses this fallback.
The server constructs request-local nodes and does not persist pantries to the shared
guest root. Runtime report logs may include supplied names. Account sync and
durable pantry persistence are not implemented.

A small explicit alias map normalizes names, case and whitespace. It does not infer
quantities or silently add staples; invalid entries are shown for correction.
Raw chickpeas are not treated as already-cooked chickpeas. Photo intake requires
explicit review and confirmation; unconfirmed suggestions never enter the pantry.

Score is floor(100 × directly available essential ingredient types / essential
types). Optional items do not reduce it. Optional-only recipes receive 100; recipes
with no requirements are omitted. Ranking uses fewer missing essentials, higher
coverage, shorter time, then stable recipe key. Edge-listed substitutes are suggestions,
never automatic availability. Amounts, dietary/allergy suitability and full recipe
verification are not checked. Normal results use validated AI graph content; fixtures require an explicit demo action.

Explore, Discover and Pantry use one editor and confirmed list. Review ingredients,
edit proposed names, then “Confirm & find meals”. Sentences use structured LLM
interpretation; simple lists use deterministic aliases. No implicit staples.
Discovery uses graph cache and at most initial + one repair model request. Fewer
than five valid distinct choices remain visible but nonselectable: retry, broaden
scope or explicitly use labelled demo fixtures. Discover favors variety within
readiness bands. Back/reload restore exact graph keys without inference; expired
keys require an explicit search. Normal results never silently use demo recipes.
The 15 regions/45 example traditions are navigation metadata, not a food database.
Legacy developer fixtures remain at `/demo`.

## Recipe detail and cook-along

Open `/recipes/gamja-jeon-demo` or select View recipe on any demo card. RecipeWalker
traverses the culinary graph, and the detail view combines its shared projection
with M3 availability. No nutrition or generated serving image is fabricated.

Cook-along has one active session per tab/origin. Starting a new recipe replaces it.
Snapshots contain the stable recipe key, recipe content version, current sequence and
finished flag. Jac validates those fields, reconstructs real CookingSession,
CURRENT_STEP and COMPLETED_STEP relationships, traverses steps and applies the action.
Back rewinds the completed prefix; finishing completes the last step; restart clears
progress. Invalid keys/versions/bounds fail safely and can be discarded in the UI.
Snapshots record user progress, not independently verified cooking completion.

Progress is saved to sessionStorage; a client module memory fallback survives route
navigation when storage is blocked, with a visible warning that refresh recovery
will be lost. There is no server-owned durable session or cross-device account sync.
Runtime report logs may include recipe/progress data. Timers are deferred.
The help panel selects checked quotations from the current graph instruction. Sample steps are not a complete cooking guide.

`get_recipe` requires recipe_key and ingredients. `cook_session` requires all five
fields: recipe_key, current_sequence, finished, action and version. Clients send
these explicitly because omitted intermediate defaults were mishandled by the
installed HTTP binder. Incomplete requests are tested as validation failures.

`COOKSY_SCREENSHOTS=1 node tests/cooking-smoke.mjs` writes reviewed captures under
/tmp/cooksy-m4-screenshots; stop the server before copying them into docs.

## Photo intake (M6)

Take/upload a JPEG or PNG (5 MiB, 16 megapixels maximum) in the shared pantry editor.
“Review photo” runs a local CPU MobileNetV3 Small classifier. Suggestions start
unaccepted: accept a name, edit it, or leave blank to reject; then explicitly choose
“Confirm photo ingredients”. Only confirmed names enter the same shared pantry and
trigger the existing meal flow. Photo failures preserve typed entry and saved names.

This ImageNet baseline recognizes only some ingredient categories (for example
banana, orange, broccoli, cabbage). It classifies a prominent object; alternative
predictions are not distinct detected objects. It is not a complete kitchen inventory
or a food-specific trained model. Scores do not establish correctness. Explicit
“Try demo suggestions” returns fixed, labelled potato/tomato fixtures regardless of
the photo, never an automatic fallback. No photo is sent to the culinary LLM.

The thin Python adapter runs in a bounded subprocess (25 seconds). Configure:

```dotenv
COOKSY_VISION_MODE=local
COOKSY_VISION_PYTHON=/absolute/path/to/vision-env/bin/python
COOKSY_VISION_MODEL_PATH=/absolute/path/to/mobilenet_v3_small-047dcff4.pth
```

Create a separate Python environment and install `adapters/requirements-vision.txt`.
For CPU-only wheels use the official PyTorch CPU index for torch/torchvision.
Download weights explicitly; inference never downloads them:

```bash
mkdir -p models
curl --fail --location https://download.pytorch.org/models/mobilenet_v3_small-047dcff4.pth -o models/mobilenet_v3_small-047dcff4.pth
sha256sum models/mobilenet_v3_small-047dcff4.pth
```

Expected SHA256: `047dcff4addef86ea5bc2eff13c9614dc11f47ab1160d0a71a25e7db994f4e1f`.
Weights and `.env` remain ignored. Missing decoder/runtime/weights gives an honest
unavailable state. A blank Python path uses `python3` from PATH; packaged Jac itself is not a Python worker. Restart after config
changes. Set mode `off` to disable normal inference; demo remains explicit.

Photos travel as bounded data URLs through typed RPC and are decoded/validated in
memory; application code saves no uploaded images or raw bytes to graph/storage.
Signed review receipts expire after 15 minutes/server restart and carry only digest,
dimensions, model and predictions. Confirmation reconstructs request-local
IngredientImage → DETECTS → DetectionResult → CONFIRMED_AS → Ingredient topology,
linked to Pantry; private graphs are not attached to shared roots. Graph provenance
is transient, not durable photo history. Mobile capture availability depends on
browser/device; file selection works in WSL desktop browsers.

Tests: configured vision Python runs `tests/vision_adapter_tests.py`; Jac vision
tests are included in `jac test -d tests`; browser regression is
`node tests/vision-smoke.mjs`. Browser photo RPC/inference and demo confirmation are
real; culinary LLM calls are intercepted. No paid API checks are required.

## Providers and limitations

M5 uses server-only `OPENAI_API_KEY` from ignored `.env`, loaded by Jac’s server:

```dotenv
OPENAI_API_KEY=your-local-key
COOKSY_LLM_MODE=live
```

Never put a real key in `.env.example` or client code. Restart Jac after editing
`.env`. Set `COOKSY_LLM_MODE=demo` to disable provider calls. Model identity is
`gpt-4.1-mini` in ai/provider.jac and jac.toml; `jac install` installs its optional
LLM capability. Each provider call uses a 35-second timeout and no automatic retries; discovery
orchestration permits one bounded repair request.
No provider call runs on page load: discovery, preparation and help are explicit
user actions. Ingredient names/cuisine or question/current step go to OpenAI.

Generated culinary content is cached in a bounded process-lifetime graph, with
provenance and unverified labels. **Server restart expires generated candidates and
recipes**; generated instructions also carry a content version to reject stale progress. Refresh/navigation in the same server process can reuse them. No private
pantry, question history or cooking sessions are stored in that cache. Prepared
recipes must preserve the candidate’s ingredient names. Schema and coherence
checks are not independent culinary, nutrition, allergy or authenticity verification.
Help accepts only exact quotations from the current instruction, and states when
that instruction lacks an answer. It does not provide an open-ended cooking chat.

Run `jac test -d tests` for deterministic MockLLM tests (no paid calls), and
all eleven browser suites: shell, discovery, cooking, pantry, pantry-discovery,
global-discovery, enrichment, vision, preview, final-journey and accessibility (each `node tests/<name>-smoke.mjs`). Browser
help success is mocked; the graph-first RPC/navigation are real. Provider errors
leave existing graph content and progress available. This is local development;
public deployment needs authentication, spending limits and durable cache design.
M6 photo intake and M7 preview flow are implemented. Live SDXL needs provider setup;
M8 reference-based nutrition and local demo quality checks are implemented.

## Nutrition and quality (M8)

Selected recipe pages calculate reference-based estimates from declared edible masses.
The ten-food USDA SR Legacy subset includes energy, protein, carbohydrate, fat, fibre
and sodium. Jac performs all arithmetic; no nutrient numbers come from an LLM.
Unknown foods/units and missing nutrient values stay explicit gaps. Partial results
are labelled **known-ingredient subtotal**, never complete meal nutrition. Mass units
are g/gram/grams, kg and mg; no guessed counts, cup weights or liquid densities.
All listed ingredients, including optional ones, are included when supported.

Every supported ingredient links to its exact source. See [methodology](NUTRITION.md)
for records, archive provenance, assumptions and limits. Cooking losses, yield,
actual oil absorption and equal portions are not verified. Ingredient references
do not establish recipe safety, quantities, allergy suitability or authenticity.
Nutrition failures leave recipe/cooking usable.

The quality pass adds visible keyboard focus, reduced-motion support, contrast and
landmark corrections, mobile tables, full-journey checks and axe-core developer audits.
Automated checks and screenshots do not constitute full accessibility certification;
manual screen-reader/device testing remains follow-up work. The local demo was also
installed/tested/built in an isolated copy without .env or model weights. Optional
ML/provider setup is separate. Use `jac install --frozen` to verify declared locks.
For a no-model-mock final journey, run the app with culinary providers disabled and
`COOKSY_OFFLINE_JOURNEY=1 node tests/final-journey-smoke.mjs`. Never use that variant
against a live paid provider configuration.

## Serving previews (M7)

A selected full recipe has an optional “Picture your plate” panel. Page load only
checks the process cache. “Generate serving preview” requests generation explicitly;
“Try demo layout” shows an abstract plate with no generated food photograph. Demo
mode exercises the recipe-grounded prompt and graph cache, clearly labelled as no
SDXL inference. With the current environment, real SDXL remains unconfigured.

Jac constructs the prompt from actual recipe name/context, quantities/preparation
and ordered steps. It does not ask the culinary LLM to invent a visual brief. Cache
keys include recipe/content version, canonical prompt, model/provider settings and
render policy. Only successful/demo states are cached (max16), with seed, timestamp,
model/provider and recipe graph links. Restart expires preview memory. Images are
returned as validated PNG/JPEG data URLs, not persisted files or remote image links.
Every image is labelled “AI-generated serving preview; illustrative, not an exact
photograph.” Appearance cannot verify amounts, cultural authenticity or ingredients.

Optional server settings, kept in ignored `.env`:

```dotenv
COOKSY_SDXL_MODE=off
COOKSY_SDXL_PYTHON=/absolute/path/to/optional-image-env/bin/python
COOKSY_SDXL_MODEL_ID=stabilityai/stable-diffusion-xl-base-1.0
COOKSY_SDXL_MODEL_PATH=
COOKSY_SDXL_ENDPOINT=
COOKSY_SDXL_API_KEY=
```

Use mode `local` only with CUDA, compatible PyTorch/Diffusers/Transformers/Accelerate
and safetensors installed in that separate environment, and a complete pre-staged
Diffusers SDXL model directory. Loading is offline; the app never downloads model
weights. The [official Diffusers SDXL guide](https://huggingface.co/docs/diffusers/v0.35.0/en/using-diffusers/sdxl)
describes the pipeline. This local provider has not been live-verified here. Update model identity/version
when replacing model weights, so cached images are invalidated.

Mode `hosted` needs Pillow in the configured worker Python and a server-configured
HTTPS bridge, no redirects. It POSTs JSON
`{model,prompt,negative_prompt,seed,width:768,height:768,steps:25}` with an optional
server-only Bearer key. The bridge must return
`{image_base64:"...",mime_type:"image/png"}` (JPEG also accepted), not an image URL.
Vendor APIs with different contracts need a bridge/adapter; do not paste arbitrary
provider URLs expecting this shape to work. The host receives selected recipe text
on explicit request, never pantry photographs. No hosted provider is configured or
live-tested. Failures leave the recipe and cooking progress usable. Network timeout
is60seconds, process timeout100seconds; no automatic generation retries. Images are
bounded to2MiB/1.5megapixels and validated before use. Runtime fallback demo is explicit.

Verification: optional vision Python can run `tests/sdxl_adapter_tests.py` (mocked
hosted calls, no money); graph tests are included in `jac test -d tests`;
`node tests/preview-smoke.mjs` covers actual demo/cache RPC and mocked image success.
Do not run paid image/provider smoke checks without explicit authorization.

## Source repository

Source: [MarrionKiprop/cooksy](https://github.com/MarrionKiprop/cooksy).
Keep credentials, model weights, user photos and generated runtime files out of Git.
Historical development notes, evidence and design references are local-only.
