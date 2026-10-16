# Cooksy operating instructions

Read this file, docs/PROGRESS.md, docs/DECISIONS.md, NEXT_SESSION.md, and
`git status --short` / `git log -5 --oneline` before changing code each session.
Read both preserved briefs in docs/briefs when resolving product requirements.

## Scope and milestone discipline

Complete one milestone at a time, in M0–M8 order. M0–M5 and their shared workflow additions are complete. M6 photo intake is complete; M7 selected-recipe preview flow is complete in explicit demo mode. M8 waits for user direction.
Preserve milestone boundaries and follow the acceptance criteria in the implementation brief.
Before every milestone commit update progress, decisions, and restart instructions;
run applicable checks, record exact outcomes and limitations, and commit only
scoped files. Record the resulting milestone hash in a subsequent documentation
commit: a commit cannot contain its own hash. Leave a clean working tree.
On interruption, record exact pending work and uncommitted files in NEXT_SESSION.md.
Never overwrite user work, reset graph data, or use destructive Git commands.

## Verified workflow

Jac executable: `/home/langstkip/workspace/jac/bin/jac` (0.37.25 at M0).
Use `export PATH="/home/langstkip/workspace/jac/bin:$PATH"` for the commands below.
Installed `jac guide` is authoritative. Query each relevant topic before introducing
its feature; record command, pattern, alternatives and consequence in DECISIONS.
Guide evidence is under docs/evidence; M1 queries are in m1-guides. Read relevant
guides before new features. The web-app scaffold is already complete: NEVER scaffold
over this repository again. main.jac renders file-based route children; pages use
JsxPage, layout uses JsxLayout/Outlet, and endpoints.shell_status / endpoints.discover are pinned server.
M4 recipe detail is /recipes/:key; RecipeWalker assembles graph-backed views.
CookingSession/SESSION_RECIPE/CURRENT_STEP/COMPLETED_STEP are real transient
relationships. CookingWalker validates and transitions them; versioned browser
snapshots recover progress. Never use transient jids for recovery or attach private
anonymous sessions to shared roots. cook_session requires all five state arguments
explicitly (the installed HTTP binder mishandled omitted intermediate defaults).
Client CookingView annotations use import type to avoid duplicate generated codecs.
Run all Jac tests with `jac test -d tests`; add cooking-smoke to browser gates.
M3 pantry names live in browser sessionStorage with an in-memory fallback. They
are sent to match_pantry and used in a transient graph; never write anonymous
private pantries to root.shared. IntakeWalker enforces confirmation and aliases.
MatchingWalker uses direct essential-type coverage; optional ingredients and
unconfirmed substitutions never inflate/penalize that score. Pantry quantities
are unknown. Rank by missing essentials, score, minutes, stable key.
Run `jac test tests/pantry_tests.jac` plus discovery tests, and all three browser
suites (shell-smoke, discovery-smoke, pantry-smoke).
M2 graph is transient demo data: never attach fixtures to user roots. Catalogue
ownership edges retain reverse-linked recipe/tradition sources. Requirements live
on REQUIRES edges; sort step views explicitly by HAS_STEP sequence.
Run `jac test tests/discovery_tests.jac` twice for graph isolation and
`node tests/discovery-smoke.mjs` for graph-backed UI/RPC in addition to shell smoke.
Commands: `jac install`, `jac fmt . --check`, `jac check .`, `jac build --as client`,
`jac run --show`, `jac run --dev`. Stop the server before fmt/check/build/install to
avoid generated-module/HMR races; restart before browser verification. Browser smoke:
`node tests/shell-smoke.mjs` (install Chromium through the local Playwright CLI first).
Use COOKSY_SCREENSHOTS=1 to capture outside the app at /tmp/cooksy-m1-screenshots;
stop the server before copying captures to docs/screenshots (writes trigger HMR). The installed formatter is
`jac fmt`; `jac format` was removed. Compiler warning limits are recorded in the
M1 verification report; do not silently suppress or claim zero warnings.
Read jac-testing before writing feature tests; run `jac test` once tests exist.
Use `jac browse` per the fullstack guide for browser verification and screenshots.
Do not report type/build/browser/provider success unless actually exercised.

## Architecture and conventions

Keep the app, UI, orchestration, deterministic matching and calculations in Jac.
Use actual nodes, typed relationship edges and traversing walkers. Python is limited
to specialised MobileNet/SDXL inference adapters. CSS and small reference JSON are
allowed. Prefer cohesive modules and explicit types; test model boundaries.
Two-stage reasoning: propose approximately five candidates, then prepare only the
selected full recipe. Consult graph memory first; enrich insufficient coverage.
The M2 seed is a test/demo fixture, not the production knowledge catalogue.
LLM output requires schema checks, deduplication, provenance and uncertainty labels.
Never delegate arithmetic or ingredient ranking to an LLM. Nutrition needs reference
data or explicit demo disclosure. Classifier suggestions require user confirmation
before pantry mutation. Generate previews only for selected recipes, cache metadata,
and label every preview “AI-generated serving preview; illustrative, not an exact photograph.”
Generate trace events from actual execution. Keep unconfigured/demo states visible.
Use warm responsive culinary design, semantic controls and keyboard navigation.

## Credentials and Git

No credentials are needed for M0/M1. Verify provider setup when M5 begins.
Never print or commit private keys, .env, uploads or model weights. The SSH key files
are outside this repository; do not copy them here. Global Git identity is configured.
GitHub SSH authentication is verified as MarrionKiprop using ~/.ssh/id_ed25519.
The repository-local core.sshCommand selects that key; origin targets
git@github.com:MarrionKiprop/cooksy.git. Remote exists; main tracks origin/main and the initial push succeeded.
The user explicitly authorized ongoing pushes: after each checked milestone and
recovery-document commit, push to origin/main and verify remote HEAD equals local
HEAD. First push: `git push -u origin main`; later pushes: `git push`. Never force
push. If the remote has unexpected history, inspect and preserve it before merging.
Report push failures accurately; a local commit is not evidence of remote backup.
Use conventional milestone-scoped commit subjects. Do not create unrelated changes.

## M5 verified boundaries

OpenAI GPT-4.1 mini is configured server-side; .env is ignored. The user approved
three fixed-payload paid checks, all completed; do not silently repeat that paid smoke.
Use MockLLM for regressions. EnrichmentWalker checks graph coverage before inference;
Jac validates/deduplicates and scores/ranks, the model returns summaries only. Full
recipes are generated only on selection. AI output is always unverified. ai/memory
holds a bounded public culinary process cache, not durable account data; never add
private pantry/questions to it or promote fixtures to shared roots. Restart expires it.
Generated Recipe.version fingerprints quantities/servings/steps. Project it through
RecipeView and CookingView, and send the actual version for start/resume/help.
Fixtures retain cooksy-demo-v1. Reject undeclared measured cooking water before
RESOLVES_TO. No claim that schema checks establish general culinary correctness.
StepHelp only accepts exact quotations from the current graph instruction; it cannot
invent missing information or advance progress. Run the five browser suites including
enrichment-smoke; enrichment-live is opt-in and paid. Stop all old preview sessions
before starting a new server to prevent port conflicts. M6 photo intake is described below.

## M5 unified workflow supersedes earlier pantry integration

DiscoveryWorkspace and PantryEditor share client_state across Explore/Discover/Pantry
and RecipeDetail. Review structured natural-language proposals, edit and explicitly
confirm before pantry mutation. Simple lists normalize deterministically. Names only.
Canonical 15 regions/45 example traditions are graph navigation metadata, no recipes.
Discover is Surprise Me. Normal discovery uses AI graph memory, never implicit seed
fallback. Exactly five distinct valid choices unlock selected-only preparation;
partial sets stay disabled. Allow initial + one repair request, never unbounded retry.
Restore exact five saved keys without inference; cache expiry requires explicit search.
Demo is explicit, isolated from AI cache and no-inference. Legacy fixtures: /demo.
CandidateCard/DiscoveryWorkbench were replaced by MealCard/DiscoveryWorkspace.
Run all seven browser suites: shell, discovery, cooking, pantry, pantry-discovery,
global-discovery, enrichment (tests/<name>-smoke.mjs). Inference must be mocked;
enrichment-live remains paid and opt-in. Cache durability remains unimplemented.
M6 photo intake is complete; M7 preview boundaries follow below.

## M6 photo intake boundaries

PhotoIntake is embedded in the same PantryEditor. Accept JPEG/PNG only, 5 MiB and
16 megapixels; adapter verifies actual decoding/MIME, no animation, EXIF orientation.
No image bytes saved to graph/disk or sent to OpenAI. MobileNetV3 Small ImageNet V1
is prominent-object classification, not multi-object detection. Conservative label
mapping; no unsupported ingredient invention. All suggestions start unaccepted;
explicit editable confirmation is mandatory. Demo fixed predictions are explicit
and labelled, never implicit fallback. Failure preserves existing pantry/typed entry.
Use configured COOKSY_VISION_PYTHON for the optional adapter environment; do not add
large torch packages to the Jac runtime. Weights ignored, official checksum recorded.
Adapter subprocess has 25-second timeout, no shell and no inference-time download.
Signed 15-minute process-key receipts hold metadata/predictions only; reject tampering
and expiry. ConfirmPhotoWalker traverses actual detections using stable positions,
creates CONFIRMED_AS and shared ingredient references in a request-local private graph.
No durable photo history or anonymous shared-root writes. Typed RPC data URLs avoid
custom multipart transport; bound and validate both client/server. Parent busy state
prevents concurrent typed/photo mutations. Tests: vision_adapter_tests.py in configured
Python, Jac full suite, all eight browser suites including vision-smoke. No paid LLM.

## M7 selected-recipe preview boundaries

ServingPreview is isolated on RecipeDetail. Only explicit generation can call SDXL;
page load/reload is cache-only, no inference. serving_preview requires selected full
recipe key/exact version plus generate/demo booleans. Jac derives prompt from graph
projection/ordered steps and canonical ingredient ordering. VisualisationWalker
traverses actual Recipe and cached GeneratedImage nodes; bounded16-entry process
cache stores image/prompt/seed/provider/model/timestamp and recipe relationships.
No private pantry/photo inputs or durable memory added. Failures are not cached.
Explicit demo shows CSS plate + no-generation disclosure; never fake an SDXL image.
Every image carries the exact illustrative label. Provider failure preserves recipe,
cooking progress and prior preview. Optional Python local offline CUDA/Diffusers
and hosted HTTPS JSON bridge paths; neither has live SDXL verification. User has
neither provider nor GPU/weights. No model downloads, paid calls or OpenAI fallback.
Use adapters/sdxl_adapter.py, hosted contract in README, no client URLs/API keys.
Tests: six SDXL adapter tests in optional vision Python; all Jac tests; nine browser
suites including preview-smoke. Preserve untracked user JPG/Zone.Identifier; don't
commit private test photos. M8 waits for the next user request.

Packaged runtime correction: never use sys.executable as a Python worker fallback;
it resolves to the Jac launcher here. Explicit COOKSY_{VISION,SDXL}_PYTHON wins;
otherwise use shutil.which("python3") and return unavailable if missing. Actual
subprocess demo regression protects against relaunching the app. No data reset.
