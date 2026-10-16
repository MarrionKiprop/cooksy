# Cooksy progress

Date: 2026-10-16 (Africa/Nairobi). Current milestone: M7 preview flow complete in demo mode; M8 not started.
M0 foundation: `34e76eddfcbac857e8c3386b2a0db05790d9fc33`. M1 adds the runnable shell.

| Milestone | Status | Scope / acceptance | Commit | Risks / next action |
| --- | --- | --- | --- | --- |
| M0 | Complete | Inspect environment; recovery files and guide evidence; validate and commit | 34e76ed | No app yet; begin M1 next session |
| M1 | Complete | Verified web-app scaffold, warm responsive shell, navigation, visible demo status; startup/check/browser evidence | 0be1768 | Culinary graph begins in M2 |
| M2 | Complete | Real culinary nodes/edges; two regions and multiple traditions; DiscoveryWalker and traversal test through ingredients/steps | e8f2773 | Demo graph only; pantry/matching begins in M3 |
| M3 | Complete | Pantry intake and deterministic matching; normalisation/dedupe/essential/optional/ranking tests | ea65d48 | Names only; tab-scoped pantry, no account sync |
| M4 | Complete | Recipe detail and cooking session; advance/reverse/recover progress | 337fc3a | Tab-scoped progress; no account sync or timers |
| M5 | Complete | Graph-first structured enrichment, selected preparation, grounded help, provenance/validation and content-version recovery | 524e785 | GPT-4.1 mini verified; process cache expires on restart |
| M6 | Complete | Local MobileNet adapter, upload/review/explicit confirmation and private graph links | See checkpoint below | Limited ImageNet ingredient coverage; no multi-object detection |
| M7 | Complete (demo flow) | Selected-recipe preview, SDXL adapters, graph cache/metadata, labels and error tests | See checkpoint below | Real SDXL unavailable; user has no local/hosted setup |
| M8 | Not started | Nutrition references/disclosure, accessibility/responsive polish, full journey and demo handoff | — | Full runtime validation still required |

## M0 evidence and checks

Completed: AGENTS.md, README.md, .env.example, docs/PROGRESS.md,
docs/DECISIONS.md, NEXT_SESSION.md, .gitignore; original briefs copied verbatim
to docs/briefs; seven CLI outputs saved in docs/evidence. Independent repository
initialized on main. Global Git identity is configured; private SSH key contents
were neither read nor copied. Key permissions inspected: private 600 / public 644.

Commands and observed results:

- `pwd`, workspace/jac-code listings: PASS; jac-code empty, no existing project.
- Ancestor `AGENTS.md` lookup: none found; project recovery files did not exist.
- Initial workspace `git status --short` and `git log -3 --oneline`: FAIL as expected,
  workspace is not a repository. New independent Cooksy repository resolves this.
- `/home/langstkip/workspace/jac/bin/jac --version`: PASS, 0.37.25.
- `jac guide`, `jac guide jac-essentials`, `jac guide jac-project-kinds`,
  `jac guide jac-scaffold`, `jac guide jac-fullstack-patterns`,
  `jac create --help`: PASS (exit 0); exact output preserved in docs/evidence.
- Exploratory `jac run --show` in workspace: FAIL (exit 1), no project/entry point;
  no app scaffold exists at M0. Record actual app plan/startup during M1.
- `command -v gh`: unavailable. GitHub authentication/push not attempted.
- `git init -b main /home/langstkip/workspace/jac-code/cooksy`: PASS.
- Python documentation validation (required nonempty files, byte-identical briefs,
  guide exit records, local Markdown links, no application files): PASS.
- Initial `git diff --cached --check`: FAIL due to CRLF in verbatim source briefs
  and a blank final line in captured CLI output. Preserved those original bytes.
- `git diff --check 34e76ed -- .` and
  `git diff-tree --check --root 34e76ed -- . ":(exclude)docs/briefs/**" ":(exclude)docs/evidence/**"`:
  PASS for authored documentation (immutable source/evidence excluded).
- `git check-ignore .env .env.local githubfile models/test.pt`: PASS.
- `git status --porcelain` after final documentation commit: required empty.

Manual verification: inspected briefs, empty target directory, installed CLI outputs,
Git identity and documentation. No UI/screenshot, type check, test suite or app build
is applicable to M0; none is reported passing.

Known limitations: all application functionality and provider activation remain
unimplemented. .env.example entries are explicitly proposed, not consumed. GitHub
owner, remote visibility and SSH authentication remain unresolved. Architecture's
hackathon deadline is source context, not a verified current schedule.

Next action: follow NEXT_SESSION.md to implement only M1 after this checkpoint.

## GitHub setup follow-up — 2026-10-16

- Workspace githubfile authentication: FAIL (public key rejected).
- ~/.ssh/id_ed25519 authentication: PASS, authenticated account MarrionKiprop.
- Initial sandbox network lookup: FAIL; authorized network retry succeeded.
- Set repository-local core.sshCommand and origin: PASS.
- Remote lookup: FAIL, Repository not found for MarrionKiprop/cooksy.
- GitHub plugin offered for repository creation; no gh CLI/token available.
- Updated operating instructions for user-authorized ongoing verified pushes.
- `git diff --check`: PASS. No push has succeeded; remote creation remains pending.

Next Git action: create empty remote, push main with upstream, compare remote hash
to local HEAD. M1 remains the next application milestone.

## GitHub initial push completed — 2026-10-16

User created the repository. `git ls-remote origin` succeeded with empty output
(empty repository); `git push -u origin main` succeeded, publishing the foundation
and Git configuration commits through 2a7972a. Main now tracks origin/main.
Updated recovery documents to remove the creation blocker. `git diff --check`
passed before committing this handoff. Push this documentation commit and verify
remote main equals local HEAD. Next application milestone remains M1.

## M1 — Verified Jac application skeleton and polished shell — 2026-10-16

Completed: scaffolded web-app in place, preserved original ignores, removed only
generated guestbook code, added main.jac, endpoints.jac, five file-based routes,
shared layout, typed components, warm responsive CSS, labelled decorative artwork,
local regional selection, accessible nav/skip link, development disclosure, real
server status/retry, metadata, browser smoke suite and four reviewed screenshots.
Updated README, AGENTS, decisions, progress and restart brief. Dependency config and
jac.lock are committed; runtime, keys and generated data remain ignored.

Checks and outcomes (details: docs/evidence/m1-verification.md):

- `jac create --kind web-app --skip`: PASS, scaffold in existing repo.
- Installed guide queries: PASS; eleven relevant outputs saved in m1-guides.
- Initial `jac install`: FAIL under network sandbox; authorized retry PASS.
- Initial check: FAIL on invalid callback annotation; corrected using props guide.
- Final `jac check .`: PASS, 11 files; warnings disclosed, not zero-warning claim.
- `jac fmt . --check`: PASS, all 11 Jac sources formatted.
- `jac run --show`: PASS, web-app serve plan.
- `jac run --dev`: PASS, UI 8000/API 8001; real status POST returned 200.
- `jac build --as client`: PASS, production browser bundle.
- Initial jac browse: FAIL, no browser installed; installed Chromium.
- Initial browser runs while tooling rewrote modules: FAIL, transient reload /
  screenshot/navigation errors. Restarting with no concurrent compilation resolved.
- `node tests/shell-smoke.mjs`: PASS, all routes, keyboard, SPA refresh/404,
  actual RPC, offline/reconnect, 390px/320px overflow and no page errors.
- `COOKSY_SCREENSHOTS=1 node tests/shell-smoke.mjs`: PASS; screenshots saved.
- `git diff --check` and recovery/link/source validation: PASS before commit.

Manual verification: inspected desktop Home and mobile Home/Explore screenshots;
confirmed branding, visible preview notice, section spacing and real connected
footer. Tightened region title sizing to fit narrow cards. Screenshot files are
under docs/screenshots. Automated checks cover keyboard interactions but do not
constitute a full accessibility audit.

Known limitations: region cards are static shell content; selection is transient.
Pantry/cooking explicitly unavailable; graph, persistence, recipe results and models
are later milestones. Jac emits JSX/runtime typing/lint warnings. Run check/build
with dev server stopped to avoid generated-module reload races. Local runtime
provides admin defaults; production hardening is unimplemented and this is not a
public deployment. Next milestone: M2, real culinary graph and traversal tests.

Final M1 verification: `jac fmt . --check` passed, production client build passed,
and the isolated screenshot-enabled smoke suite passed after moving PNG writes
outside the watched app. Server stopped cleanly; copied four final screenshots
into docs/screenshots. Confirmed .env/key/model/runtime exclusions remain active.

M1 milestone commit: `0be176888fb5d3e39fc30453f06168fa4212d8ba`. All checks and screenshots were recorded before this
checkpoint. The following documentation commit records this immutable hash.

## M2 — Object-spatial culinary graph seed — 2026-10-16

Completed graph/models.jac (real nodes and typed edges), graph/seed.jac (isolated
demo graph), graph/views.jac (typed projections), walkers/discovery.jac (real
visit/entry/exit traversal and actual encounter events), and discovery endpoint.
Explore loads regions from the graph, filters regions/traditions server-side, shows
eight clearly labelled demo recipe cards with edge-backed quantities, optional
flags, preparation/substitution notes and ordered sample steps. Added loading,
error/retry and no-match states plus optional walker trace. No M3/M4/M5 features
were claimed or implemented. Updated shell disclosure and recovery files.

Commands and outcomes:

- Relevant `jac guide` queries: PASS; M2 outputs under docs/evidence/m2-guides.
- Initial formatter/check: FAIL on in-body docstring, corrected to comment.
- Initial graph tests: FAIL on transient edge-order behavior; explicit projected
  step sorting fixed it. A repeat run then failed on reverse-linked source lifetime;
  catalogue ownership edges fixed reachability without deleting persisted state.
- `jac test tests/discovery_tests.jac`: PASS, 4 tests; immediate repeat: PASS, 4 tests.
- `jac fmt . --check`: PASS, 17 Jac files formatted.
- `jac check .`: PASS, 17 files; existing JSX/runtime warnings retained/disclosed.
- Initial `jac build --as client`: FAIL, walker pulled client; explicit discover
  server pin fixed the crossing. Subsequent production build: PASS.
- `jac run --dev`: PASS, UI localhost:8000, API localhost:8001.
- `COOKSY_SCREENSHOTS=1 node tests/discovery-smoke.mjs`: PASS; actual HTTP discovery,
  8→2→1 filtering, optional quantities, ordered steps, real trace, region-reset,
  unknown-filter empty response, mobile layout, 503/retry and no browser errors.
- `node tests/shell-smoke.mjs`: PASS, navigation, keyboard, deep links/404,
  connectivity/retry, 390px/320px layouts and no browser runtime errors.
- `git diff --check`, link/recovery integrity and credential/runtime ignore checks:
  PASS before commit. Screenshots/logs saved under docs/evidence and docs/screenshots.

Manual review: desktop and mobile Explore screenshots show region cards, the demo
disclosure, tradition selector, recipe cards and optional trace. All food examples
are developer fixtures; sample steps are not full verified recipes.

Known limits: request-local demo topology is rebuilt for each query, not durable
culinary memory. Four regions are illustrative coverage; live enrichment is M5.
Pantry matching is M3; recipe/cooking state is M4. No model provider, inference,
nutrition data or generated serving image integration exercised. WSL access note
added after user confirmed browser access via the WSL address.

Next: M3, confirmed pantry intake and deterministic recipe matching.

M2 milestone commit: `e8f277376759d153ffa5d7f21aff6169c02aa3d6`. The follow-up documentation commit records this hash;
all graph, type, build and browser checks passed before the checkpoint.

## M3 — Pantry intake and deterministic matching — 2026-10-16

Implemented Pantry/IntakeItem nodes, typed PENDING_ITEM and HAS_INGREDIENT edges,
IntakeWalker and MatchingWalker, explicit aliases and strict names-only validation,
server-pinned matching endpoint and typed contracts. Extracted the existing recipe
projection for shared relationship-backed reads. Added explicit edge substitution
options to two demo requirements. No LLM or arithmetic delegation.

Pantry UI supports manual comma/newline entry, normalisation/deduplication, removal,
clear, browser-tab recovery, region filtering, ranked recipe explanations, direct
available/missing-essential/missing-optional categories, possible swaps, validation,
loading/retry and blocked-storage fallback. Quantities and account persistence are
explicitly unimplemented. Updated Home/Explore preview copy, docs and screenshot evidence.

Checks and outcomes:

- Relevant installed guide queries: PASS; evidence under docs/evidence/m3-guides.
- Initial extraction script: FAIL to match formatted source; projection written
  explicitly. Initial format/type gates rejected reserved entry/match names and
  misplaced module docstring; fixed with draft/candidate and module-first docstring.
- `jac test tests/pantry_tests.jac`: PASS, 7 tests; repeat run PASS recorded below.
- `jac test tests/discovery_tests.jac`: PASS, all 4 existing graph tests.
- `jac fmt . --check`: initial FAIL for graph/models layout; formatted it and
  final gate PASS, 25 Jac source files.
- `jac check .`: PASS, 25 source files; existing compiler warnings remain.
- `jac build --as client`: PASS, production browser bundle.
- `COOKSY_SCREENSHOTS=1 node tests/pantry-smoke.mjs`: PASS, real RPC, aliases,
  duplicate handling, coverage/optional/substitution boundaries, removal/filtering,
  invalid entries, tab recovery/isolation, offline retry with draft retention,
  clear, blocked-storage fallback and mobile layout.
- `node tests/discovery-smoke.mjs`: PASS, graph discovery/filter/trace/retry regression.
- `node tests/shell-smoke.mjs`: PASS, navigation/keyboard/deep-link/404 and
  390px/320px responsive regression.
- `git diff --check`, original-brief byte integrity, recovery links and secret/data
  ignore checks: PASS before commit.

Manual review: desktop/mobile Pantry screenshots show ingredient chips, explicit
storage scope, ranked recipe cards, transparent coverage, missing ingredients and
suggested swaps without counting them as available. Browser screenshots/logs saved
under docs/screenshots and docs/evidence. No live model/provider claimed.

Known limits: ingredient presence only, no quantity sufficiency or dietary/allergy
validation; eight unverified demo recipes. SessionStorage is per tab/origin and may
be restored by the browser. No persisted server-side pantry graph/account sync. Runtime report logs may include supplied names. Retry
refreshes committed pantry; failed entry draft remains to submit explicitly.
Cook-along is M4, AI discovery is M5, photo classification is M6.

Next milestone: M4 recipe selection/details and recoverable cook-along sessions.

Final repeat: pantry suite passed again (7 tests in 9.98s).

M3 milestone commit: `ea65d4854042c6034bec66b7c30354ab4e660780`; pushed successfully. The follow-up documentation
commit records this checkpoint; graph/browser/build/type checks passed before it.

## M4 — Recipe detail and cook-along foundations — 2026-10-16

Added RecipeWalker, selected-recipe API/detail route, links from Explore/pantry,
quantities/preparation/availability/substitution/sample steps and provenance context.
Added CookingSession plus SESSION_RECIPE/CURRENT_STEP/COMPLETED_STEP, a validating
restore helper and CookingWalker with actual recipe/step traversal. Browser-tab
snapshot recovery plus module-memory fallback maintain one isolated active session.
Cook-along has next/back/finish/restart/end, progress, empty/loading/error/retry and
invalid saved-state handling. No fake timer/help/provider/nutrition/preview claims.

Checks and outcomes:

- Relevant installed guides queried/saved: PASS.
- Initial optional-view assignment: FAIL, removed redundant same-projection copy.
- First Vite build: FAIL, duplicate CookingView import/inline codec; annotation-only
  import fixed it. No generated/runtime source edited.
- Initial formatting: FAIL for RecipeWalker layout; formatted and final gate PASS
  for all 34 sources.
- `jac check .`: PASS, 34 files; final affected-contract check PASS, 7 files after
  tightening HTTP arguments. Existing compiler warnings remain.
- `jac test -d tests`: PASS, 15 tests together; cooking suite after final API fix
  PASS, 4 tests. Covers selection, actual step edges, resume/finish/back/restart,
  boundary validation, version/recipe/action rejection, isolation and bad ordering.
- Production `jac build --as client`: PASS after codec/default-call fixes.
- First cooking browser run: FAIL, omitted HTTP defaults misbound current_sequence
  to a string. Required explicit fields and sent all five args; incomplete requests
  now fail validation. A premature startup attempt hit connection refused; waited
  for server readiness before the final passing run.
- `COOKSY_SCREENSHOTS=1 node tests/cooking-smoke.mjs`: PASS, real selected-recipe
  links/deep links and cooking RPC, next/back/finish/restart, reload/navigation
  recovery, mobile overflow, failed-action preservation, session end, unknown
  recipe, independent/corrupt session and blocked-storage fallback.
- Existing shell, discovery and pantry browser suites: PASS.
- Recovery/source/link/ignore and staged whitespace checks: PASS before commit.

Visual review: desktop selected recipe and mobile focused cook-along screenshots
show readable steps, clear demo status, missing/optional ingredients, progress and
labelled controls. Evidence under docs/evidence and docs/screenshots.

Limits: abbreviated unverified demo recipes; tab/origin scoped snapshots, no durable
server/session account sync. Browser restoration may retain sessionStorage. Timers,
contextual LLM help, nutrition and previews remain unimplemented. Retry resumes last
saved progress rather than replaying a failed next action. No live model was used.

Next milestone: M5 structured enrichment and grounded assistance (mock/provider gates).

M4 milestone commit: `337fc3a3aa99a13d9ae73dffd506107d0d4b9af7`; pushed successfully. This follow-up documentation
commit records the checkpoint. Verification evidence was recorded before committing.


## M5 — Structured culinary enrichment and grounded help — 2026-10-16

Added typed AI schemas/sem annotations, verified Jac by-llm provider configuration,
EnrichmentWalker, candidate/ingredient/RESOLVES_TO topology, bounded process culinary
memory, selected full-recipe generation, deterministic validation/deduplication/ranking,
provenance and unverified labels. Explore offers pantry/cuisine discovery beyond the
fixture regions. Existing graph coverage skips inference. Full recipes are prepared
only after selection and reused from graph memory. Cookbook help selects checked
verbatim wording from the current graph step and declines insufficient context.

Generated recipes use content-versioned snapshots through graph projections, detail,
cook-along and help; stale progress is rejected after recipe content changes. Added
finite quantities, exact quantity-name membership, bounds and measured-water checks.
No private pantry, questions or sessions enter the public process cache. Provider
failures preserve existing graph/UI content and do not advance progress.

Final verification:

- Installed Jac guides captured under docs/evidence/m5-guides; by-llm/config/node-edge/
  testing/client/auth/types patterns verified. `jac install` PASS, optional LLM closure.
- `jac test -d tests`: PASS, **25 tests in 47.30s** (10 M5 + 15 regressions).
- `jac check .`: PASS, **43 files in 66.65s**, existing warnings disclosed.
- `jac fmt . --check`: PASS, **43/43**. Production client build: PASS (3.4s).
- All five final browser suites: PASS; real graph/navigation/cooking RPC, 320px
  layout, failure preservation, storage recovery and step-answer reset. Browser
  help-success fixture is mocked; no paid calls run in these suites.
- Exactly three user-approved live GPT-4.1 mini requests: grounded help (one quote),
  structured discovery (three accepted candidates), selected ten-step preparation.
  Real cross-request graph/browser cooking/reload then passed without additional
  inference. Subsequent visual review caught undeclared measured water; tightened
  validation and added a passing regression. Content-version checks were added and
  verified with mocks/backend tests. No paid retest after those final changes.
- Saved key absent from production bundles; .env ignored/untracked. No key printed.
- Desktop discovery/mobile help captures reviewed; final captures in docs/screenshots.

Initial failures and fixes are recorded in m5-verification.md: reserved test variable,
missing optional litellm, browser storage typing, overlapping old preview processes,
and actual RPC envelope shape. Automatic review initially rejected live testing;
explicit payload/destination/spending approval then allowed exactly three requests.
No rejection was bypassed. Live cache was cleared during the final controlled restart.

Limits: generated culinary graph is process-lifetime (100 candidates), not durable
storage; restart expires generated recipes. Output remains unverified. Schema and
the measured-water rule cannot prove all natural-language ingredient correctness,
authenticity, allergy suitability or nutrition. Help quotes only the current step.
No M6 photo, M7 image generation or M8 nutrition integration was added.

M5 implementation commit: `524e785800a63396cc8e4d696ecc9bb0c81d2c4e`; pushed successfully and remote main verified.
This follow-up ledger commit records the checkpoint.
Next: M6 photo suggestions with explicit review/confirmation before pantry mutation.

## M5 follow-up — Pantry entry and regional AI discovery

Fixed the missing connection from pantry submission/region selection to M5 discovery.
Pantry normalization and saving precede discovery; names and readable region scope
reach a new pantry-specific server endpoint. Five fully covered essential-name
candidates skip inference, rather than five unrelated catalogue dishes. Shared
candidate cards preserve provenance and prepare only the selected dish; duplicate
prepared results are omitted. AI failures preserve saved names/prepared matches.
Reload does not invoke AI; empty/rejected pantries do not trigger discovery.

Verification: all 26 Jac tests PASS (50.80s); affected 7-file type check PASS (27.84s),
follow-up empty-state component check PASS (2.80s), final production build PASS (3.4s).
All six browser suites PASS, including the new pantry-discovery regression for
normalized ingredients, East Asia/Mediterranean scopes, no provider on reload,
AI failure recovery, selection/navigation, empty/rejected input and 320px layouts.
All inference in the new browser flow is mocked; no additional paid API calls.
Initial new browser test failed on the stale empty discovery panel; explicit length
guards fixed it. Existing compiler warnings remain. This is an M5 repair, not M6.

Pantry follow-up commit: `1ba4d99a5abae6b1e17889eb1768a7936c6fa194`; pushed and remote HEAD matched.
Formatter checked all 44 sources; staged whitespace and key-exclusion checks passed.

## M5 shared discovery workflow completed — 2026-10-16

Completed the user's requested M5 additions before M6: structured natural-language
ingredient review, editable explicit confirmation, one shared pantry across Explore,
Discover, Pantry and recipe detail; graph-backed navigation for 15 regions and 45
example traditions; worldwide Discover as Surprise Me; one five-choice result flow.
Jac validates, deduplicates, scopes and ranks results. Discover prefers variety
within readiness bands. Only the selected dish gets a full recipe. One initial
summary request plus at most one repair; partial results cannot be selected.
Exact-key saved-choice restoration does not invoke inference. Normal discovery
uses taxonomy plus AI graph memory; seed recipes appear only in explicit demo flows.

Verification: 36 Jac tests PASS; 54-file Jac check PASS (existing warnings retained);
client build PASS; all seven browser suites PASS: global-discovery, pantry,
pantry-discovery, enrichment, discovery, cooking and shell. Tests include actual
metadata/confirmation/demo graph RPC, all 15 scopes/traditions, shared state,
failures, exact-five gate, selected-only preparation, restoration, blocked storage
and 390/320px layouts. All inference mocked; no additional paid model requests.
Desktop Explore/mobile Discover screenshots reviewed: clearly labelled fixtures.
Initial browser attempt before server readiness failed connection; after readiness
all suites passed. Final formatting and whitespace checks must pass before commit.

Limits: ingredient names only, no quantity sufficiency/allergy/authenticity checks.
AI graph cache remains process-scoped and expires on restart. Regions/traditions
are navigation metadata, not an exhaustive food database. M6 vision, M7 images,
M8 nutrition and durable account data remain unimplemented. M6 has not started.

M5 workflow implementation checkpoint: `cb08338432954475790210917b503d8a70188053`; pushed to origin/main.
Final formatting, whitespace and staged/client-bundle credential checks passed.

## M6 — Photo-to-confirmed-pantry flow — 2026-10-16

Implemented bounded local Python MobileNetV3 Small CPU adapter with official weights
and checksum enforcement; JPEG/PNG actual decoding, MIME/size/pixel/frame checks,
EXIF orientation and 25-second process timeout. Conservative ingredient mapping
returns alternatives for a prominent object, not a multi-object inventory. Missing
runtime/weights/no-match/errors preserve typed intake; demo predictions are explicit
and labelled. No paid API/cloud photo requests or inference-time downloads.

Shared PantryEditor now has capture/upload preview, unaccepted suggestions, accept,
editable names, blank rejection and explicit confirmation. Typed server RPC carries
bounded data URLs; no image files saved by application. Signed 15-minute ephemeral
receipts bind metadata/predictions without keeping private photo caches. Confirmation
traverses IngredientImage→DETECTS→DetectionResult→CONFIRMED_AS→Ingredient and
Pantry→HAS_INGREDIENT/PANTRY_IMAGE in request-local graphs, never shared roots.
Confirmed names merge into the same Explore/Discover/recipe pantry. Failures retain
review edits and existing pantry. Parent busy state prevents overlapping mutations.

Verification: 40 Jac tests PASS (47.51s), 59-file full check PASS (133.02s; existing
warnings retained), client build PASS. Six Python adapter tests PASS. All eight
browser suites PASS: vision, global-discovery, pantry, pantry-discovery, enrichment,
shell, discovery, cooking. Photo browser test exercises actual local decode, real
CPU inference/no_match, explicit demo, edited acceptance/rejected alternatives,
failed-confirmation preservation/retry, shared discovery, corrupt-file preservation
and 390/320px layouts; culinary inference mocked. No extra paid model calls.
Reviewed desktop/mobile photo-review screenshots using synthetic image and clearly
labelled fixed demo suggestions; no real-food accuracy benchmark claimed.

Local optional environment: Python3.12 with Pillow12.1.1, torch2.13.0+cpu,
torchvision0.28.0+cpu. Downloaded official 9.8MiB weights remain ignored. .env updated
only with local vision settings; OpenAI key never printed/committed. Setup/checksum,
guide evidence and validation notes recorded. M7/SDXL and M8/nutrition not started.
M6 classifier covers only a subset of ingredients; no full inventory, quantities,
allergy safety or durable photo history claims. Browser camera selection depends
on device/browser; WSL desktop file selection is verified.

M6 implementation checkpoint: `23c1388806953db54c68d406e3adf1d46c3edf59`; pushed and remote main verified.
Final formatting, whitespace and credential/weight exclusion checks passed.

## M7 — Selected-recipe serving-preview flow — 2026-10-16

User authorized next module after M6 and confirmed neither hosted SDXL provider
nor local weights/GPU is available. Implemented selected full-recipe/version RPC,
deterministic graph-grounded prompt, canonical ingredient order, VisualisationWalker
cache traversal, GeneratedImage metadata and ownership/recipe links, bounded16-entry
process cache, seed/model/prompt/version keying, isolated RecipeDetail preview panel,
explicit demo plate and required illustrative label. Initial load/reload only read
cache. Failures preserve recipe/progress and prior preview. No M8 work added.

Optional Python adapter supports offline local CUDA/Diffusers directory or a
configured HTTPS JSON bridge with server-only auth; PNG/JPEG bytes verified and
bounded. Neither real SDXL path is live-verified/configured. No multi-gigabyte model
download, paid generation, OpenAI image fallback or secret changes were performed.
Demo deliberately returns no food image; the UI says no SDXL image was generated.

Verification: initial fullsuite46tests PASS(43.47s), full check64files PASS(139.29s),
clientbuild PASS. Browser exposed packaged sys.executable resolving to Jac launcher,
which relaunched app instead of Python. Stopped preview/accidental child without
clearing data. Worker fallback now explicit configured Python or actual python3
from PATH; applied same fix to vision's previously unused blank-path fallback.
Added actual subprocess regression. Final fullsuite47tests PASS(17.85s), affected
3-file check PASS(3.85s), finalbuild PASS(3.0s). Six SDXL Python adapter tests PASS;
all nine browser suites PASS: preview, vision, shell, discovery, cooking, pantry,
pantry-discovery, global-discovery and enrichment. SDXL image-success and culinary
LLM calls mocked; actual selected demo/cache RPC and local photo inference exercised.
Desktop/mobile preview panels reviewed, screenshots under docs/screenshots/m7.

Limits: real SDXL must be configured separately. Hosted integration is a documented
JSON bridge contract; vendor-specific APIs need an adapter/bridge. Cache/images are
process-lifetime, not durable. Seed does not guarantee cross-platform determinism.
Nutrition and final M8 polish remain unimplemented. User's pre-existing JPG and
Zone.Identifier remain untouched and untracked, outside this milestone commit.
