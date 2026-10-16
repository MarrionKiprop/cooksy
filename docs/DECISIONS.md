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
