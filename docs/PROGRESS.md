# Cooksy progress

Date: 2026-10-16 (Africa/Nairobi). Current milestone: M3 complete; next: M4.
M0 foundation: `34e76eddfcbac857e8c3386b2a0db05790d9fc33`. M1 adds the runnable shell.

| Milestone | Status | Scope / acceptance | Commit | Risks / next action |
| --- | --- | --- | --- | --- |
| M0 | Complete | Inspect environment; recovery files and guide evidence; validate and commit | 34e76ed | No app yet; begin M1 next session |
| M1 | Complete | Verified web-app scaffold, warm responsive shell, navigation, visible demo status; startup/check/browser evidence | 0be1768 | Culinary graph begins in M2 |
| M2 | Complete | Real culinary nodes/edges; two regions and multiple traditions; DiscoveryWalker and traversal test through ingredients/steps | e8f2773 | Demo graph only; pantry/matching begins in M3 |
| M3 | Complete | Pantry intake and deterministic matching; normalisation/dedupe/essential/optional/ranking tests | ea65d48 | Names only; tab-scoped pantry, no account sync |
| M4 | Not started | Recipe detail and cooking session; advance/reverse/recover progress | — | Verify persistence before implementation |
| M5 | Not started | Structured by-llm enrichment and grounded help; reuse, provenance, malformed/duplicate/unavailable mocks | — | Provider/model not configured |
| M6 | Not started | MobileNet adapter, upload/review/confirmation graph; validation and contract tests | — | Weights and dependencies unverified |
| M7 | Not started | Selected-recipe SDXL preview, metadata/cache, label and error tests | — | Hosted/local inference unconfigured |
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
