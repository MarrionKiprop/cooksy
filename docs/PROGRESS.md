# Cooksy progress

Date: 2026-10-16 (Africa/Nairobi). Current milestone: M1 complete; next: M2.
M0 foundation: `34e76eddfcbac857e8c3386b2a0db05790d9fc33`. M1 adds the runnable shell.

| Milestone | Status | Scope / acceptance | Commit | Risks / next action |
| --- | --- | --- | --- | --- |
| M0 | Complete | Inspect environment; recovery files and guide evidence; validate and commit | 34e76ed | No app yet; begin M1 next session |
| M1 | Complete | Verified web-app scaffold, warm responsive shell, navigation, visible demo status; startup/check/browser evidence | 0be1768 | Culinary graph begins in M2 |
| M2 | Not started | Real culinary nodes/edges; two regions and multiple traditions; DiscoveryWalker and traversal test through ingredients/steps | — | Seed is demo/test data only |
| M3 | Not started | Pantry intake and deterministic matching; normalisation/dedupe/essential/optional/ranking tests | — | Respect confirmation boundary |
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
