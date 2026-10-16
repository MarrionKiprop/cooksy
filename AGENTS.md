# Cooksy operating instructions

Read this file, docs/PROGRESS.md, docs/DECISIONS.md, NEXT_SESSION.md, and
`git status --short` / `git log -5 --oneline` before changing code each session.
Read both preserved briefs in docs/briefs when resolving product requirements.

## Scope and milestone discipline

Complete one milestone at a time, in M0–M8 order. The initial request explicitly
permits only M0 this session. Do not build features until the recovery foundation
is committed. Follow the acceptance criteria in the implementation brief.
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
M0 evidence is under docs/evidence. Read jac-core-cheatsheet and jac-types before
writing Jac, then specialist guides as needed. Use the installed scaffold rather
than inventing jac.toml. For M1 use the no-name `jac create --kind web-app --skip`
inside this repository, inspect generated files and reconcile any documentation
it changes. Never use --force. Then `jac install`, `jac check .`, `jac run --show`,
and `jac run --dev`. These are verified guide instructions, not M0 runtime results.
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
