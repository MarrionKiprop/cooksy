# Resume at: M3

M2 is complete: Explore uses a real transient Jac culinary graph and DiscoveryWalker.
Four regions, eight traditions/eight demo recipes, sixteen shared ingredients and
sixteen steps are connected by typed edges. Ingredients/quantities and sample steps
are projected from relationships; actual walker events are visible behind the scenes.
The graph is request-local and explicitly labelled demo, not persisted user data.
M2 commit hash is recorded in docs/PROGRESS.md after committing.

Read first:

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
cat AGENTS.md docs/PROGRESS.md docs/DECISIONS.md NEXT_SESSION.md
git status --short
git log -5 --oneline
jac guide jac-node-edge-patterns
jac guide jac-walker-patterns
jac guide jac-sv-persistence
jac guide jac-sv-auth
jac guide jac-testing
```

Exact next task: implement M3 Pantry/Ingredient and HAS_INGREDIENT relationships,
IntakeWalker for confirmed text ingredients, alias/duplicate normalisation, and
MatchingWalker comparing pantry against REQUIRES edges. Choose and document pantry
identity/storage boundaries before storing real user data; avoid a public shared
pantry. Preserve the demo graph contract and do not pretend its unverified recipes
are model output. Keep photo classification/confirmation flow for M6.

Definition of done: user enters ingredients and receives deterministic ordered
matches with available, missing-essential, missing-optional and substitution
explanations. Tests cover normalisation, duplicate handling, essential vs optional,
ranking/ties and confirmation boundary; graph/browser suites pass; recovery files
updated; focused M3 commit pushed and remote hash verified. No LLM filtering/arithmetic.

Existing checks (stop server before compile/check/build/install/edits):

```bash
jac fmt . --check
jac check .
jac test tests/discovery_tests.jac
jac test tests/discovery_tests.jac
jac build --as client
jac run --dev
# Separate terminal once server is ready:
node tests/shell-smoke.mjs
node tests/discovery-smoke.mjs
```

Preview: http://localhost:8000. In Windows/WSL use the first address from
`hostname -I` if localhost forwarding fails (user confirmed WSL IP access works).
Keep the server terminal open; actual ports are printed at startup. Screenshot
mode writes under /tmp/cooksy-m2-screenshots; copy into docs only after stopping
server. All writes in the project can trigger HMR, including docs/PNG files.

Known limits: installed compiler JSX/runtime typing warnings remain. The transient
runtime needed explicit catalogue ownership edges for reverse-linked sources, and
StepView sorting by HAS_STEP sequence; preserve those fixes. Discovery endpoint is
pinned server; client must only receive view objects/RPC stubs. No provider credentials
needed for M3. Ongoing Git pushes are authorized. Verify a clean tree before starting.
