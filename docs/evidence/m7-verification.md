# M7 selected-recipe serving preview verification

No CUDA GPU, local SDXL weights, Diffusers/Transformers runtime or hosted endpoint
was configured. User confirmed they have neither local nor hosted setup. No weights
were downloaded and no paid image/API request was sent. The normal path is honestly
unavailable, while explicit demo returns a recipe-grounded preview state and CSS
plate layout, never a fake generated food photograph.

Implemented a Python optional local/hosted SDXL adapter and Jac deterministic prompt,
selected/version validation, actual VisualisationWalker traversal, bounded16-node
GeneratedImage graph cache with prompt/model/seed/timestamp metadata, and isolated
recipe-page UI. Cache-only page load never requests inference. Failure never blocks
recipe/cook-along or replaces an already visible preview with an error.

Six Python adapter tests PASS: explicit demo/no fabricated image, missing weights,
PNG/JPEG response validation, mocked hosted payload/auth, sanitized errors and
invalid input. Actual live SDXL inference is NOT exercised. Local path uses offline
Diffusers safetensors pipeline; hosted path is a documented JSON HTTPS bridge contract,
not a claim that arbitrary vendor APIs support this shape.

Initial affected Jac check passed4files. First5graph tests passed (14.04s), covering
prompt/version identity, cache-only no inference, graph reuse/metadata relationships,
errors/retry, unavailable selected keys/version and bounded cache eviction. Added
sixth test for canonical ingredient traversal-order invariance. Full check64files PASS(139.29s), fullsuite46PASS(43.47s), buildPASS.
Browser then exposed packaged sys.executable/Jac-launcher issue; fixed worker
fallback to actual python3 (also vision), added actual subprocess regression.
Final fullsuite47PASS(17.85s), affected3-file checkPASS(3.85s), buildPASS(3.0s).
All nine browser suites PASS. Actual demo/cache RPC, image-success mock, failures,
labels, mobile, cooking and local photo regression exercised. Screenshots reviewed.

Official pipeline reference consulted:
https://huggingface.co/docs/diffusers/v0.35.0/en/using-diffusers/sdxl
Jac guide outputs under docs/evidence/m7-guides. No framework/generated code edited.
Pre-existing user JPG and Windows Zone.Identifier attachment remain untouched,
untracked and outside the milestone commit.
