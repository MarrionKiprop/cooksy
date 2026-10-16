# Resume at: M2

M1 is complete: Cooksy has a runnable Jac web shell, file-based navigation, responsive
styles, interactive regional preview, honest Pantry/Cook Along empty states, and
server connectivity with retry. No culinary graph or model inference exists yet.
M1 milestone commit: `0be176888fb5d3e39fc30453f06168fa4212d8ba`; see docs/PROGRESS.md for evidence.

First commands:

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
cat AGENTS.md docs/PROGRESS.md docs/DECISIONS.md NEXT_SESSION.md
git status --short
git log -5 --oneline
jac --version
jac guide jac-node-edge-patterns
jac guide jac-walker-patterns
jac guide jac-has-fields
jac guide jac-sv-persistence
jac guide jac-testing
```

Exact next task: define the real culinary graph and seed an explicitly labelled
fixture covering at least two regions, multiple traditions, recipes, ingredient
requirements on typed edges, and ordered steps. Implement DiscoveryWalker with
actual traversal. Query installed guides and log verified patterns before writing
Jac graph code. Reuse the shell; do not scaffold again.

Definition of done: a test proves Region → Tradition → Recipe → Ingredient/Step
traversal, quantities/essentiality live on REQUIRES edges, discovery can filter
regions/traditions or traverse all cuisines, tests use isolated fixtures and pass
on repeat runs, applicable checks pass, documents updated, focused M2 commit pushed
and remote hash verified. Do not implement M3 matching/intake in the M2 milestone.

Commands for the existing shell (stop server before checks/build/install):

```bash
jac fmt . --check
jac check .
jac build --as client
jac run --dev
# Separate terminal, after server is ready:
node tests/shell-smoke.mjs
```

Blockers: none for M2. Jac compiler has JSX/runtime typing warnings; see the M1
verification report. Concurrent check/build/install with HMR can corrupt transient
client module linking; stop server first and restart, preserving graph data.
Screenshot output must stay outside the app until server shutdown (see README).
No credentials are needed for graph fixture work. Provider/weights/GPU setup belongs
to M5–M7. GitHub SSH and tracking work; ongoing `git push` is authorized.
No uncommitted files are expected after milestone/ledger commits; verify status.
