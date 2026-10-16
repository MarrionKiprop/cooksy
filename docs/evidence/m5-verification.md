# M5 verification — 2026-10-16

Scope: graph-first by-llm candidates, selected-recipe preparation, provenance and
validation, deterministic scoring, process graph reuse, extractive active-step help.

Verified toolchain patterns: installed Jac 0.37.25 guides captured in m5-guides.
OpenAI model page fetched: https://developers.openai.com/api/docs/models/gpt-4.1-mini.
User saved the key into ignored .env, selected lower-cost GPT-4 class, then explicitly
approved the fixed live-test payload and maximum three paid requests. No key values
were displayed or stored in evidence. Production JS scan found no saved key value.

Observed checks before the final consistency fix:

- Initial MockLLM tests: failed due to absent optional litellm; `jac install` after
  adding [byllm.model] succeeded, syncing runtime dependencies and npm closure.
- Initial test parse: failed because graph is reserved; renamed to catalogue.
- Initial full type check: 43 passed, one failed on window.sessionStorage typing.
  Corrected to ambient sessionStorage + explicit str boundary; affected 3 files passed.
- `jac test -d tests`: PASS, 23 tests in 26.91s, including 8 M5 tests plus all 15
  graph/pantry/cooking regressions. MockLLM exercises actual request/schema parsing.
- Formatter gate: PASS, 43/43 Jac sources. Production client build: PASS.
- Five browser suites: PASS (shell, discovery, pantry, cooking, enrichment).
  Existing HTTP graphs/navigation/recovery are real; help-success UI is mocked.
  M5 covers exact step payload, clearing answers on step changes, 503 preservation,
  graph-first results/navigation, 320px layout and zero browser page errors.
- Initial browser startup: failed due to an older preview still running. Stopped
  both process sessions, started one instance, verified actual shell RPC readiness.
- Live check: first invocation was rejected by automatic approval review; no API
  call ran. After explicit user approval, exactly 3 calls ran: grounded help (one
  checked quotation), discovery (three validated candidates), selected preparation
  (ten steps). Cross-request get_recipe/cook_session and real browser detail,
  next-step and reload passed with cached data and no more model calls.
- Visual review of the selected live recipe found measured cooking water omitted
  from structured ingredients. Added a deterministic validator and regression to
  reject that inconsistency. The recipe remained unverified throughout; no claim
  of independent culinary correctness is made. Final server restart expires it.

Final consistency-fix checks and final browser confirmation are recorded below.
Compiler warnings about JSX/runtime typing and generated state aliases remain;
this is not a zero-warning claim. All app/orchestration/validation remains Jac.
No M6/M7/M8 functionality was implemented.

Visual review: desktop discovery and mobile cooking screenshots under
`docs/screenshots/m5-*` show readable inputs, provenance and unverified states,
coverage explanations, progress and exact-step help. Capture writes were outside
the watched app; copying into docs occurred with preview stopped.

Limits: public generated culinary graph is bounded process memory, not durable
storage. Server restart clears generated recipes/candidates; saved cooking snapshots
then require a new recipe. Dietary/allergy/nutrition/culinary authenticity are not
verified. Quotation-only help intentionally declines questions beyond current step
text. General natural-language consistency cannot be proven by schema checks.

Final results:

- Full `jac check .`: PASS, 43 files in 83.41s; existing warnings retained.
- Post-review `jac test tests/enrichment_tests.jac`: PASS, 9 tests in 7.71s,
  including undeclared measured-water rejection before graph mutation.
- Post-review affected `jac check` (memory/workbench/tests): PASS, 3 files in 4.44s.
- Post-review production client build: PASS, client.kndz4BPj.js (4.4s).
- Earlier full suite remains 23/23; the added regression brings M5 to 9 cases,
  alongside 15 existing cases. No live calls ran after the three approved requests.

Final content-version gates supersede the earlier counts:

- `jac test -d tests`: PASS, 25 tests in 47.30s (10 M5, 15 existing).
- `jac check .`: PASS, all 43 files in 66.65s; warnings retained.
- `jac fmt . --check`: PASS, all 43 files.
- Production build: PASS, client.B_1fscKh.js (3.4s).
- All five browser suites repeated after content versions/completion copy: PASS.
- Generated content fingerprint is projected and checked on start/recovery/help;
  unit regression rejects stale fixture-version progress for generated recipes.
- No live paid test repeated after final consistency/version changes. Live provider
  transport and output parsing were verified by the earlier approved three calls.
