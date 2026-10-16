# Resume at: M6

M5 is complete: graph-first structured candidates, selected recipe preparation and
extractive active-step help use Jac by llm() with GPT-4.1 mini. The saved server-only
key is in ignored .env; never display it. Exactly three fixed-payload paid checks
were explicitly approved and completed. Do not silently repeat that paid smoke.
M5 implementation commit: `524e785800a63396cc8e4d696ecc9bb0c81d2c4e`; pushed and remote hash verified.

Read AGENTS.md, docs/PROGRESS.md, docs/DECISIONS.md, both briefs as needed, status/log
and relevant installed guides before edits. The Jac environment is
/home/langstkip/workspace/jac/bin/jac (0.37.25); app is this directory.

Exact next milestone: M6 MobileNet photo-to-confirmed-pantry flow. Verify installed
Jac endpoints/upload, Python interoperability, graph/walker/client and testing guides
before selecting patterns. Python is limited to specialized inference adapters.
Inspect actual model/dependency availability; never claim real classification from
mock output. Validate uploads, file size/content and prediction contract. Show
suggestions for explicit user review; only confirmed detections may enter pantry
HAS_INGREDIENT edges via IntakeWalker. Add graph relationships for image/detection/
confirmation per the architecture and meaningful mocked/adapter contract tests.
Keep missing weights/unconfigured mode honest. Do not implement M7 SDXL in M6.

M5 baseline checks: 25 Jac tests, full 43-file check and five browser suites passed.
Pantry follow-up: 26 Jac tests, affected 7-file type check plus final component check,
production build and all six browser suites pass. Evidence is recorded.
Existing warnings remain. Use MockLLM for normal tests, not live paid calls.

Important contracts:
- All five cook_session arguments are explicit; get_recipe requires ingredient list.
- Generated Recipe.version fingerprints content; pass projected version for start,
  snapshot recovery and help. Fixtures still use cooksy-demo-v1.
- Generated culinary graph cache is bounded process memory (100 candidates), not
  durable. Restart clears generated dishes; private pantries/questions are not stored.
- Candidate summaries precede full selected preparation. Jac scores and ranks.
- Measured cooking water must be declared; output still needs independent verification.
- Step help only accepts exact quotations from the current graph instruction.
- Browser pantries/progress are tab/origin scoped, with documented storage fallback.
- Client view annotations may need import type to avoid duplicate generated codecs.

Stop every old dev preview before edits/check/build/install/docs writes; overlapping
servers caused one port conflict. Run jac fmt . --check, jac check ., jac test -d tests,
jac build --as client, then jac run --dev and node tests/{shell,discovery,pantry,cooking,
enrichment}-smoke.mjs individually. Capture outside app and copy with server stopped.
The optional enrichment-live.mjs makes paid calls and requires explicit opt-in.

WSL browser previously works at http://172.26.123.103:8000 (hostname -I if changed).
Leave one running preview at handoff. GitHub origin/main pushes are already authorized;
commit scoped milestones/recovery docs, push, record milestone hash in a second
ledger commit, push and verify remote HEAD equals local HEAD. Never force push.

Pantry follow-up: Add & find meals, removals and region selection invoke discovery
from confirmed names after deterministic matching. discover_pantry uses essential
coverage_score=100; Explore enrich retains browse coverage_score=0. Both share
run_enrichment and EnrichmentWalker. Use readable cuisine names; strip the leading
“The ” from the Mediterranean display label. Reload/retry matching makes no AI call.
CandidateCard is shared; do not duplicate candidate rendering in the two screens.
Run tests/pantry-discovery-smoke.mjs in addition to the five baseline browser suites.
Pantry smoke intercepts discover_pantry to avoid accidental paid model requests.
Empty client lists require explicit length checks in conditionals/JSX.
