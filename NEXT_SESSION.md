# Resume at: M4

M3 is complete: Pantry accepts ingredient names, normalises explicit aliases and
removes duplicates through IntakeWalker, stores names in browser sessionStorage
with in-memory fallback, and builds transient HAS_INGREDIENT relationships for
MatchingWalker. Results show direct essential-type coverage, missing essentials,
missing optional items and explicit substitution suggestions, with stable ranking.
No server-side shared pantry or account persistence is implemented.
M3 commit hash is recorded in PROGRESS.md after the milestone commit.

Read first:

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
cat AGENTS.md docs/PROGRESS.md docs/DECISIONS.md NEXT_SESSION.md
git status --short
git log -5 --oneline
jac guide jac-sv-persistence
jac guide jac-sv-auth
jac guide jac-walker-patterns
jac guide jac-cl-routing
jac guide jac-cl-js-interop
jac guide jac-testing
```

Next task: M4 RecipeWalker, selected-recipe detail view and CookingWalker with a
recoverable CookingSession/current-step/completed-step contract. Decide and document
identity/storage boundaries before persisting user sessions; never store private
anonymous sessions on a shared guest root. Reuse graph/projections.jac for edge-backed
recipe data. Recipe keys are stable demo keys; transient jids are not durable IDs.
Keep demo/verification disclosures. Do not implement M5 LLM inference in this milestone.

Definition of done: select a recipe, open its details, begin cook-along, advance and
reverse steps, recover current progress, and test session isolation/bounds. Add timers
only if they can be implemented and tested correctly. Run applicable checks, update
recovery files, commit, push and verify remote hash.

Existing checks (stop server before editing or compilation because HMR watches even
PNG/docs writes):

```bash
jac fmt . --check
jac check .
jac test tests/discovery_tests.jac
jac test tests/pantry_tests.jac
jac build --as client
jac run --dev
# Separate terminal after server is ready:
node tests/shell-smoke.mjs
node tests/discovery-smoke.mjs
node tests/pantry-smoke.mjs
```

Preview: http://localhost:8000; on Windows/WSL use the first WSL IP if localhost
forwarding fails. User confirmed http://172.26.123.103:8000 works this session.
Keep the server terminal open. Screenshot mode writes under /tmp/cooksy-m3-screenshots;
copy into docs only after stopping the server. Restore the running preview at handoff.

Known limits: amounts/dietary suitability are not checked; recipe examples are
unverified fixtures. Aliases are explicit, and substitutions do not change coverage.
Pantry is scoped to this browser tab/origin; browser session restoration may retain
sessionStorage. Failed submissions retain drafts; Retry refreshes committed names.
Installed Jac emits existing JSX/runtime typing warnings. No model credentials are
needed for M4 demo work. Ongoing Git pushes are authorized. Verify clean Git status.
