# Architecture decisions

Date: 2026-10-16 (Africa/Nairobi). All implementation details remain subject to
installed-tool verification. Raw M0 command evidence: docs/evidence/.

## D001 — Repository and first-session scope

Context: jac-code was empty; no project history or recovery files existed. The
implementation prompt explicitly says “Implement only M0 unless M0 is already complete.”
Decision: create jac-code/cooksy as an independent main-branch repository; preserve
both briefs and complete only the documentation foundation. Global Git identity is
MarrionKiprop / maccherop@gmail.com. Alternative: build the entire product immediately.
Consequence: no runnable app at M0; M1 is the exact next milestone.

## D002 — Installed Jac and web-app scaffold

Context: the architecture's file tree is illustrative, not compile-ready.
Evidence: `jac --version` → 0.37.25; `jac guide`, `jac guide jac-essentials`,
`jac guide jac-project-kinds`, `jac guide jac-scaffold`, `jac create --help` all exit 0.
Decision: use the installed CLI's web-app scaffold in M1. No-name
`jac create --kind web-app --skip` initializes cwd; --skip defers dependency
installation to `jac install`. Inspect scaffold output before choosing module paths.
The guide's default web-app entry is main.jac plus endpoints.jac, so do not mandate
app.jac or .cl.jac filenames from the proposal. Alternative: hand-written config.
Consequence: preserve/reconcile M0 documents and use no --force during scaffolding.

## D003 — Full-stack workflow and evidence boundaries

Evidence: `jac guide jac-fullstack-patterns` and jac-scaffold verify inferred client
placement from JSX/imports, server endpoints, generated RPC, `jac check .`,
`jac run --show`, `jac run --dev`, and browser QA through `jac browse`.
Decision: adopt those patterns after scaffolding; read component, routing, styling,
core syntax and type guides before implementing M1. Read testing guidance before tests.
Alternative: a separate Python backend or hand-maintained JavaScript client.
Consequence: Jac remains the first-party implementation language. M0 has no runtime
validation: exploratory `jac run --show` in workspace exited 1 because there was no
entry-point/project. This is expected, not an app failure or a passing start check.

## D004 — Reconciling graph reuse with LLM-first discovery

Context: guidance requires graph-first retrieval while revised architecture rejects
a manually maintained global catalogue. Decision: the graph is reusable memory;
insufficient coverage triggers structured enrichment. M2 seeds are explicit demo/test
fixtures. Propose about five candidates first; generate the selected complete recipe
only after selection. Match and compute deterministically in Jac. Alternative: a
fixed recipe catalogue or generating five full recipes per request.
Consequence: M5 must test graph reuse, validation, provenance and duplicate handling.
No graph or by-llm syntax is asserted by this product decision; verify relevant guides
in M2/M5 before implementation.

## D005 — Provider and ML boundaries

Context: no provider, GPU, weights or inference integration has been verified.
Decision: defer provider activation to M5–M7; define proposed settings as such in
.env.example. Add tested deterministic demo modes and visible status disclosure.
Vision requires explicit confirmation. SDXL follows recipe selection with the required
AI label; nutrition uses reference data or disclosed demo estimates.
Alternative: implicit provider assumptions or fabricated live results.
Consequence: M0 requires no credentials and makes no claim that inference works.

## D006 — Local Git and milestone hash bookkeeping

Context: Git identity and SSH key file permissions exist; gh is unavailable and no
remote owner/destination or authentication has been established. Decision: create
local commits now, leave key material untouched, defer publishing until destination
is resolved. Record the M0 foundation hash in a follow-up documentation commit.
Alternative: guess a GitHub owner/visibility or attempt to embed a commit's own hash.
Consequence: local history is recoverable; the ledger commit is discoverable with
`git log` and cannot recursively contain its own hash.

## D007 — Preserve original document bytes

Context: whitespace checking flags CRLF in the supplied briefs and a final blank
line in captured CLI output. Decision: preserve source/evidence bytes and apply
whitespace checks to authored documentation separately; record the initial failed
check explicitly. Alternative: normalise originals and lose byte identity.
Consequence: source verification remains exact, and original whitespace is not
misreported as a passing check.

## D008 — GitHub authentication and ongoing push authorization

User requested GitHub configuration and continuing pushes. Workspace githubfile
was rejected; ~/.ssh/id_ed25519 authenticated as MarrionKiprop (SSH exit 1 with
GitHub's successful-authentication greeting is expected). Set repository-local
core.sshCommand to select that key and origin to MarrionKiprop/cooksy over SSH.
Do not change global SSH settings or copy key material. Remote ls-remote returned
Repository not found; repository creation and initial push remain pending. No gh
CLI or token environment variable is available. Offered GitHub plugin connection
for repository creation. Future checked commits should be pushed without asking
again; verify remote branch hash, never force push or overwrite remote history.

## D009 — GitHub repository established

User confirmed creation of MarrionKiprop/cooksy. Verified the remote was empty
with `git ls-remote origin`, then successfully ran `git push -u origin main`.
Use the existing SSH remote and tracked main branch for future authorized pushes;
verify remote main matches local HEAD after pushing. No plugin connection or new
credentials were needed. Repository visibility was not inspected or changed.

## D010 — M1 verified shell structure

Evidence: `jac guide jac-core-cheatsheet`, `jac guide jac-types`,
`jac guide jac-cl-components`, `jac guide jac-cl-routing`,
`jac guide jac-cl-styling`, `jac guide jac-sv-endpoints`, `jac guide jac-config`,
and `jac guide jac-cl-js-interop` queried before implementation.
`jac create --kind web-app --skip` succeeded in cwd. Scaffold rewrote .gitignore;
merged its editor ignores with all original credential/model/runtime exclusions.
Decision: file-based pages returning JsxPage; shared layout returns JsxLayout and
renders Outlet. main.app(children) wraps children in JSX. Link/useLocation supply
navigation and active state. Shared CSS imported once; no UI dependency added.
Remove only generated guestbook files, replace endpoints with a read-only typed
status function, and exercise RPC in the shell. Reactive has state and typed
ChangeEvent/MouseEvent handlers follow the component guide.
Alternative: retain guestbook or add manual Router alongside pages; rejected as
unrelated scope/mixed routing. Consequence: M1 has navigable honest empty states,
no pantry mutations, graph seed, recipe results or model calls.

M1 correction: the initial callback annotation was rejected by the compiler.
`jac guide reference/agent-patterns/jac-cl-components --section props` verifies
`Callable[[MouseEvent], None]`, which replaces the invalid arrow form. The effects
section verifies `async can with entry { await ...; }` for initial RPC loading.

M1 placement verification: inspecting compiled/endpoints.js showed the pure status
function had been pulled into the client. `jac guide jac-codespaces` verifies that
anchor-free pure public functions can relocate; added an explicit server pin for
endpoints.shell_status so connectivity uses actual RPC. This prevents a static
local return from being mistaken for server connectivity. `jac fmt --help` is the
installed formatting command; `jac format` is removed despite older guide wording.

## D011 — Browser acceptance and development-tool sequencing

Context: the guide's jac browse could not find Chromium; installed Chromium with
Playwright. Added @playwright/test 1.64.1 as an npm dev dependency through
`jac install --npm --dev @playwright/test`, then pinned the verified version.
Decision: persist tests/shell-smoke.mjs with actual route, keyboard, responsive and
RPC/offline assertions; screenshots are optional via COOKSY_SCREENSHOTS=1.
Alternative: only inspect markup or a constant endpoint unit test; insufficient
to verify routing and server/client placement. Consequence: browser binary is a
developer prerequisite, no JavaScript application logic is introduced.

Observed concurrent compilation/check/build/HMR rewrites generated modules and can
produce temporary missing exports, navigation aborts, screenshot timeouts or a
server refresh error. Run checks/build/install with server stopped, then restart
before browser QA. No graph/cache reset was needed. A stable-server browser run
passed. Keep that sequence in README and AGENTS. The dev template hard-codes its
initial title; React 19 title/link metadata in main.jac sets Cooksy's title/favicon,
verified by browser assertions. This adds known intrinsic-typing warnings only.

M1 region selection is local UI state, not graph-backed discovery. The home artwork
is decorative CSS illustration labelled as such. No generation integration is implied.

Further M1 diagnosis: Jac's watcher also reacted to PNG writes under docs/screenshots,
not just source edits. The screenshot test was triggering its own HMR. Capture to
/tmp/cooksy-m1-screenshots outside the app; copy into docs only after stopping the
server. This is the concrete fix for repeatable screenshot acceptance.

## D012 — M2 graph model, fixture lifecycle and traversal

User authorized M2. Queried installed jac-node-edge-patterns, jac-walker-patterns,
jac-has-fields, jac-sv-persistence, jac-testing, core/types and fullstack/endpoint
and component guides before implementing their features. Typed endpoints on edges,
+>:TYPE(fields):+> construction, reverse typed queries, edge-object references,
ordered edge queries and can/visit/exit reporting are verified by these guides.
Decision: Catalogue → Region ownership edge; Tradition → Region PART_OF;
Recipe → Tradition BELONGS_TO; Recipe → Ingredient REQUIRES with quantities,
essentiality, preparation and substitution notes; Recipe → Step HAS_STEP with
sequence. Discovery walks backwards from regions into traditions/recipes, then
forwards into ingredients/steps. Typed view objects are assembled from graph edges,
not a duplicate JSON catalogue. Traces come from actual encounter abilities.

M2 uses a fresh transient demo graph per request, never attached to root. This is
supported by the node/edge guide and isolates fixtures without touching saved user
state. Four regions/eight traditions/eight recipes are a small demonstration, not
a global recipe database or verified culinary advice. Persistence/migrations remain
a future feature; graph-first enrichment is M5 and intake/ranking is M3. Alternative:
a shared persisted public seed now; deferred to avoid silently mixing fixtures with
user data and introducing ownership/concurrent-seeding contracts before needed.

M2 validation correction: transient edge ordering did not reorder the seed's reverse-
inserted steps in the first runtime test. Sort the projected StepView list explicitly
by the sequence read from HAS_STEP edges. Keep the deliberately reversed fixture to
exercise this behavior. Initial endpoint docstring was placed inside its body and
rejected; changed to a comment following the core guide's declaration-docstring rule.

M2 repeat-run test exposed a transient lifetime issue: reverse-linked tradition and
recipe sources could be collected after the builder returned. Added typed
CATALOGUE_TRADITION and CATALOGUE_RECIPE ownership edges from the catalogue, retaining
the reverse-linked sources through real topology rather than duplicate JSON or global
arrays. Two subsequent suite runs passed. First client build attempted to lower the
walker into JavaScript; explicitly pin endpoints.discover to server, following the
installed codespace guide and M1's verified status-RPC boundary.

## D013 — M3 pantry identity and deterministic matching

User authorized M3 and routine module decisions/continuing pushes. Verified installed
jac-sv-auth, node/edge, walker, types/core, client organisation/interop and testing
guides before implementation. Anonymous public roots are shared: do not store a
private pantry there. Decision: browser sessionStorage holds confirmed ingredient
names for this tab; matching sends the names and builds a transient Pantry graph
per request, with no root attachment or cross-request user-state globals. No login
or account persistence is implied. Storage failures leave usable in-memory UI and
an explicit disclosure. Existing transient demo catalogue remains the recipe source.

IntakeWalker traverses pending IntakeItem nodes, normalises whitespace/case and a
small explicit alias map, deduplicates, and updates HAS_INGREDIENT relationships.
Vision-source inputs require confirmed=True; manual UI uses typed input only. No
implicit oil/salt/staples. Names only: quantities are unknown on pantry edges.
MatchingWalker traverses pantry ingredients and culinary topology; availability is
computed from REQUIRES-backed views. Score = floor(100 * directly available essential
types / essential types). Optional ingredients do not reduce score. Rank by missing
essential count, descending score, minutes, stable recipe key. Explicit edge-listed
substitutes are suggestions, remain missing until the user confirms/adds the actual
required ingredient, and never inflate score. No LLM or arithmetic delegation.

M3 implementation notes: extracted the M2-tested recipe projection into
graph/projections.jac so discovery and matching read the same REQUIRES/HAS_STEP
data. Explicit substitutes are added to REQUIRES and projected without automatic
replacement. No recipe seed is persisted. The first projection extraction script
did not match formatted source; wrote the helper explicitly and reran graph tests.
Initial check rejected reserved names match/entry and an import before a module
docstring; renamed locals to candidate/draft and kept module docstrings first.
Seven pantry tests and four discovery regression tests subsequently passed.
Browser storage uses a delimited list of validated names (no JSON casts); browser
APIs remain inside Jac client code, with a working in-memory fallback if blocked.

## D014 — M4 selected recipes and recoverable cooking graph

User authorized M4 with “yes.” Queried installed persistence/auth/walker/routing/
client interop/testing, node-edge and core/types guides before introducing features.
Decision: RecipeWalker traverses catalogue/region/tradition/recipe and assembles the
selected edge-backed recipe view. Detail includes M3 availability, quantities,
ordered sample steps, provenance and honest unavailable nutrition/preview state.
No model generation is implied by the existing unverified demo fixture.

CookingSession connects to Recipe via SESSION_RECIPE, to its current RecipeStep via
CURRENT_STEP and to completed steps via COMPLETED_STEP. CookingWalker actually visits
recipe/step nodes, validates bounds and applies next/back/restart/resume transitions.
A versioned stable-key/current-step/finished snapshot is stored per browser tab;
server reconstructs/validates graph state per request, without shared root writes.
A client module memory fallback carries the session across routes if storage is
blocked; refresh recovery then is explicitly unavailable. Only one active session
per tab; starting a new one replaces it. Browser restoration may preserve tab storage.
Snapshots are progress conveniences, not authorization or proof a step was cooked.
Timers and LLM help are deferred rather than simulated. Alternative: introduce
account login/server-owned persisted sessions now; unnecessary for M4's isolated
working demo, and a later deliberate migration can add account persistence.

M4 verification corrections: removed a redundant assignment from RecipeWalker’s
optional details into MatchView (both already use the same projection), resolving
an Unknown boundary diagnostic. The first Vite build emitted both an import and
an inline RPC codec named CookingView. The installed jac-types import-type section
verifies annotation-only imports: client consumers now import CookingView as a type,
letting the generated RPC codec supply its runtime binding. No generated JS was edited.

M4 browser verification caught a real HTTP default-binding issue: a start request
with omitted intermediate defaults arrived with a string in current_sequence. The
UI now sends all five cooking arguments explicitly, and cook_session requires all
fields so incomplete external requests fail validation rather than relying on the
installed binder’s defaults. get_recipe likewise requires its ingredient list.
Unit helpers supply defaults only for in-process test convenience; no framework
or generated runtime files were modified. Added this failure to the verification log.

## D015 — M5 model boundary, public culinary cache, and grounded help

User authorized M5 with “next,” saved an OpenAI key in ignored `.env`, and selected
“the lower ones like 4.” Selected gpt-4.1-mini after checking its official model page
(https://developers.openai.com/api/docs/models/gpt-4.1-mini). The credential skill's
reuse decision is resolved by the user saving the existing key; no key was printed,
copied into source, or committed. Jac's server loads project `.env`; installed
scale/config/project_env.jac confirms this. Default live mode invokes the provider
only on explicit discovery, selection or help actions; COOKSY_LLM_MODE=demo disables
calls. Model timeout is 35 seconds, provider retries zero, malformed-output retries
zero. No tools or shared conversations are supplied to the model.

Verified `jac guide jac-by-llm`, jac-node-edge-patterns, jac-testing, jac-config,
jac-sv-auth, jac-types and jac-cl-components; evidence under m5-guides. Use typed obj
returns with per-field/function/argument sem annotations, declaration-only by llm(),
and MockLLM to exercise request construction and parsing. The first mock run exposed
missing optional litellm: [byllm.model] declares the capability, and jac install must
sync its third-party dependencies before even mocked calls work. A test initially
used reserved `graph` as a variable; renamed to catalogue following the core guide.

EnrichmentWalker traverses existing complete recipes and candidate memory before
checking coverage. At least five in-scope candidates skip inference; insufficient
coverage asks for at most five summaries. Jac validates lengths, positive bounded
time, required/unique normalized ingredients, cuisine scope and canonical dish +
tradition identity. Rejected/duplicate proposals do not become graph nodes. Jac
computes essential-name coverage and sorts by missing essentials, descending score,
time and stable key. No quantity sufficiency, nutrition or dietary claims are made.

Generated culinary memory is a bounded, process-lifetime graph (100 candidates),
not durable account storage. It holds only culinary proposals/requirements/prepared
recipes; private pantry, questions and cooking state are not attached. A lock
serializes discovery and preparation to avoid duplicate concurrent writes. Candidate
nodes connect to Ingredients via CANDIDATE_REQUIRES and to a selected complete Recipe
via RESOLVES_TO. Recipe quantities/steps use existing REQUIRES/HAS_STEP edges.
Prepared graph content is copied into request-local catalogues; fixtures are never
promoted into persistent/shared roots. Alternative: persist public culinary memory
now; deferred until ownership, retention and account boundaries are deliberate.
The UI discloses restart expiry; server restart deliberately clears generated dishes.

Selection generates only one full recipe; quantities must have exactly the candidate
ingredient names, positive finite bounded values, and bounded servings/steps. Schema
validation cannot establish culinary correctness or detect every ingredient mentioned
in natural-language directions. Every AI result therefore remains explicitly
unverified, with model provenance and timestamp. A successful selected recipe is
reused without another model call. Failed preparation leaves the candidate unchanged.

Cooking help is deliberately extractive: the model selects quotations from the
current graph instruction; Jac requires every quotation to be an exact substring.
Unknown keys, versions and out-of-range steps are rejected. No invented timings,
temperatures or substitutions are accepted. Empty answers disclose insufficient
context. No help call advances the session. Help components remount when the active
step/finished state changes so old answers cannot appear under a different step.

M5 live review follow-up: automatic approval review initially rejected the paid test
because its exact payload/destination lacked explicit approval. No workaround or
request was sent. User then explicitly approved the fixed ingredients, recipe step
and question for up to three paid GPT-4.1 mini calls. Those three calls returned
one grounded quotation, three validated proposals and a ten-step selected recipe.
Subsequent local requests/browser navigation proved graph reuse, cooking transitions
and reload recovery without extra inference. Visual review then found measured
cooking water present only in prose. Added a deterministic measured-water consistency
check and regression: undeclared measured cooking water now rejects preparation
before RESOLVES_TO is created. No further paid calls were made. The transient live
cache was cleared by the deliberate final server restart. The screenshot of that
rejected-in-review recipe is not shipped as an accepted recipe example. Broader
natural-language ingredient correctness still requires independent verification.

Generated recipe recovery uses a content fingerprint in Recipe.version (quantities,
servings and instructions), projected through RecipeView and CookingView. Clients
send that version explicitly for start/resume/help; fixtures retain cooksy-demo-v1.
Recreating a dish with different instructions therefore rejects stale progress,
rather than treating the stable dish identity as an instruction version. A regression
covers projection, generated cooking, stale fixture-version rejection and changed
instructions. This extends M4's version checks to generated content without changing
its explicit-argument RPC contract or private tab storage boundaries.

## D016 — Pantry discovery integration follow-up

User reported Explore worked but pantry entry/region selection did not. Inspection
confirmed PantryWorkspace only invoked prepared-recipe matching; it never invoked
M5 enrichment. Re-ran installed jac-cl-components and jac-testing guides before
changing the component/contract tests. Extracted CandidateCard so Explore and pantry
share provenance, missing essentials, score and selection controls.

Explicit pantry submission, ingredient removal and region changes now normalize/save
through match_pantry first, then call discover_pantry with confirmed names and a
readable culinary scope. “The Mediterranean” maps to “Mediterranean”; region slugs
are not model prompts. Added a pantry-specific coverage policy: five candidates
with all essential ingredient names available skip inference. Five unrelated/poorly
covered catalogue entries do not block pantry enrichment. Explore retains its
browse-oriented existing policy. Both routes use the same validated walker/provider;
Jac still computes scores and ranking. Prepared results remain available if AI fails.
Only a selected proposal invokes full preparation; cached matches are not duplicated
in candidate cards. Prepared MatchCard uses actual verification metadata.

Reload/retry matching does not automatically invoke AI. The pantry browser suites
intercept every discovery request, and inference/preparation in the new flow regression
is mocked. No additional paid calls were made. Browser testing exposed empty arrays
remaining truthy in a JSX condition; explicit len checks now hide empty discoveries,
prevent AI after entirely rejected entry, and clear stale empty-state UI. Existing
pantry private-storage, failed-draft and graph boundaries are preserved. M6 remains next.

## D017 — Unified discovery contract — 2026-10-16

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

Guide queries: jac-cl-components, jac-cl-routing, jac-by-llm, jac-testing; evidence
in docs/evidence/m5-alignment-guides. Also consulted client interop/types guidance.
Structured extract_ingredients and propose_options use typed schemas and sem
annotations. Simple lists remain deterministic. Never save raw model proposals
before explicit confirmation or silently add staples. Shared client_state provides
tab storage plus module-memory route fallback; full refresh loses that fallback.
A localized `as any` Callable.call bridge handles the installed JS typing boundary.
MockLLM.seen counts inference; wrapping by-llm functions breaks metadata reflection.
No generated/framework files were edited. The latest Cooksy direction supersedes
old names/static-food-database proposals in supplied reference documents.
