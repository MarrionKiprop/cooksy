# Resume at: M5

M4 is complete: /recipes/:key shows graph-backed details and pantry availability;
Explore and pantry cards link to it. CookingWalker maintains real current/completed
step relationships, with tab-scoped snapshot recovery and a route-memory fallback.
Next/back/finish/restart/end, bounds, version checks, failed actions, isolation and
blocked storage were tested. No timers, model inference, nutrition or images yet.
M4 milestone hash is recorded in PROGRESS.md after committing.

Read first:

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
cat AGENTS.md docs/PROGRESS.md docs/DECISIONS.md NEXT_SESSION.md
git status --short
git log -5 --oneline
jac guide jac-by-llm
jac guide jac-types
jac guide jac-sv-persistence
jac guide jac-testing
```

Exact next task: M5 structured culinary enrichment and grounded active-recipe/step
assistance through verified Jac by-llm patterns. Consult existing graph candidates
first, validate/deduplicate structured proposals, preserve provenance and explicit
unverified status. Keep all ranking/filtering/arithmetic in Jac. Separate candidate
discovery from selected full-recipe preparation; never present fixture text as
model output. Start with installed MockLLM examples and malformed/unavailable tests.

Before any real provider/API setup, read the applicable credential/provider skill;
for OpenAI or an unspecified provider, use the installed openai-platform-api-key
credential gate. Do not print keys or silently pick a paid model. No provider has
been configured in M0–M4, and no live integration should be claimed before testing.

Definition of done: existing graph consulted first, validated schema-constrained
proposals with provenance/duplicate handling, grounded help limited to selected
recipe/step, unavailable-provider UI and deterministic mocks, tests for valid,
malformed/duplicate/unavailable results, applicable full checks, updated recovery
files, focused commit pushed and remote hash verified. Keep M6 photo inference out.

Existing checks (stop server before edits/check/build/install):

```bash
jac fmt . --check
jac check .
jac test -d tests
jac build --as client
jac run --dev
# Separate terminal after startup:
node tests/shell-smoke.mjs
node tests/discovery-smoke.mjs
node tests/pantry-smoke.mjs
node tests/cooking-smoke.mjs
```

Important contracts: cook_session requires all five arguments, get_recipe requires
its ingredient list; omitted intermediate HTTP defaults were broken in this Jac
installation. CookingView client annotations use import type to prevent duplicate
wire-codec declarations. Graphs remain request-local; browser snapshots are not
account authentication. Stable recipe keys + version restore state; never jids.
SessionStorage may survive browser restoration. No shared anonymous private graph.

Preview localhost:8000; Windows/WSL access through http://172.26.123.103:8000 worked
in this session (check hostname -I if it changes). Keep the server terminal open.
Capture screenshots to /tmp before copying into docs with server stopped. Leave a
running preview at handoff. Ongoing pushes are authorized; verify a clean tree.
