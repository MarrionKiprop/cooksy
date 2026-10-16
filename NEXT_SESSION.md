# Cooksy checkpoint — product copy cleanup

M0–M8 local-demo scope is complete. Latest work removes developer commentary from
normal product screens and makes README product-focused. Technical setup is in
docs/DEVELOPMENT.md. Full provenance is accessible in collapsed Recipe information;
short AI/Sample labels remain. Nutrition subtotal warnings, photo confirmation,
privacy details and honest sample-image labels remain. Raw API provenance and
traces are retained; sample descriptions now use culinary language.

Verification: 53 Jac tests pass; 69-file Jac check passes; production build passes.
After final sample-description edits, affected discovery tests (4) and seed check
pass. All 12 browser suites pass, including new product-copy checks and accessibility.
Desktop/mobile screenshots reviewed in docs/screenshots/product-copy. No paid calls.
See docs/evidence/product-copy/verification.md for exact scope and corrections.

Use feature-based commit subjects going forward; preserve historical Git records.
Deferred: real SDXL, food vision improvements, durable graph/account storage,
broader nutrition and production readiness (docs/FOLLOW_UPS.md). No new feature
has been started. Keep user banana JPG and Zone.Identifier untouched/untracked.
Never expose .env/keys; previous three-call live authorization is exhausted.

Jac: /home/langstkip/workspace/jac/bin/jac. Stop preview before watched edits,
format/check/build or evidence copies. Start with jac run --dev; UI8000/API8001.
Compiler cache and local browser execution need elevated sandbox access.
