# Cooksy progress

Date: 2026-10-16 (Africa/Nairobi). Current milestone: M0 complete, foundation commit
pending below; next: M1. This repository contains documentation only.

| Milestone | Status | Scope / acceptance | Commit | Risks / next action |
| --- | --- | --- | --- | --- |
| M0 | Complete | Inspect environment; recovery files and guide evidence; validate and commit | Recorded after foundation commit | No app yet; begin M1 next session |
| M1 | Not started | Verified web-app scaffold, warm responsive shell, navigation, visible demo status; startup/check/browser evidence | — | Install dependencies; preserve recovery files |
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
- `git diff --cached --check`: PASS before foundation commit.
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
