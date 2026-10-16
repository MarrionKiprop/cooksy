# Cooksy operating instructions

Read this file, docs/PROGRESS.md, docs/DECISIONS.md, NEXT_SESSION.md, and
`git status --short` / `git log -5 --oneline` before changing code each session.
Read both preserved briefs in docs/briefs when resolving product requirements.

## Scope and milestone discipline

Complete one milestone at a time, in M0–M8 order. M0 and M1 are complete; the user authorized M2 with “so m2 then.”
Complete M2 before moving to M3, preserving the milestone boundary. Follow the acceptance criteria in the implementation brief.
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
