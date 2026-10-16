# M4 verification

RecipeWalker traverses catalogue/region/tradition/recipe and selects edge-backed
recipe details. CookingWalker visits the session recipe and its actual steps,
then updates CURRENT_STEP and COMPLETED_STEP relationships. restore_session rejects
out-of-bounds/finished mismatch and nonconsecutive or duplicate step order.

Full Jac suite: 15 passed. Final cooking suite: 4 passed after HTTP contract change.
Full type gate: 34 passed; final affected-contract gate: 7 passed. Formatting: 34/34.
Production client build passed. Existing JSX/runtime warnings remain disclosed.

Cooking browser acceptance passes selection/deep-link refresh, quantity/availability
and ordered steps, actual RPC, next/back/finish/restart, refresh and route recovery,
mobile overflow, failed-action preservation, end, unknown recipe, independent/corrupt
sessions and blocked-storage fallback. Incomplete HTTP requests fail validation.
M1/M2/M3 browser suites also passed.

Failures corrected before acceptance: redundant optional-view assignment, duplicate
import/inline RPC codec (annotation-only import), RecipeWalker formatting, omitted
intermediate HTTP defaults (all fields now required/sent), and an early attempt
before server readiness. No persisted data reset or generated JS edit was used.

[Desktop recipe](../screenshots/m4-recipe-desktop.png) and
[mobile cook-along](../screenshots/m4-cooking-mobile.png) were visually reviewed.

The browser stores one versioned stable-key/current/finished snapshot per tab/origin;
Jac validates it and reconstructs a request-local graph. A module-memory fallback
survives navigation when tab storage is blocked, but cannot survive refresh.
Snapshots are user progress, not authentication/proof of cooking. No private shared
root writes or account persistence. No timers, inference, nutrition or images were
implemented; recipe content remains clearly labelled abbreviated demo data.
