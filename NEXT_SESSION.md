# M0–M8 local demo complete — follow-ups only on user direction

Read AGENTS.md, PROGRESS.md, DECISIONS.md and git status/log first. Latest user asked
to finish M8 while keeping liveSDXL for later. M8 implements sourced nutrition,
quality checks and demo handoff. See docs/{DEMO,ARCHITECTURE,NUTRITION,FOLLOW_UPS}.md.

Nutrition:10exact USDA SR Legacy records in nutrition/references.json, FDC IDs,
links/archiveSHA256 and original nutrient-field evidence. Deterministic Jac walker
uses declared edible mass(g/kg/mg), all listed optional ingredients, per100g sums,
equalservings and displayrounding. Unknownfoods/units/values never becomezero.
Partial results must say known-ingredient subtotal; no complete-meal claims. No
LLM nutrients or generic-oil/count/volume guesses. Request-local profile/reference
links, isolated panel/retry; no private pantry shared-root writes.

Gates:53Jac tests,69-file fullcheck plus post-audit layout/nav checks,productionbuild,
6vision+6SDXL adaptertests and all11browser suites passed. Axe7routes/expandedstates
zero reported violations, incomplete decorative/pseudo-background color checks
recorded; not full accessibility certification. Desktop/mobile screenshots reviewed.
Clean no.env/no-model source copy in /tmp/cooksy-m8-clean:install--frozen,53tests,
build and actual no-key/provider-disabled fulljourney passed. Final build asset
matches original. No model-response mocks for that offline journey; no paidcalls.

Regression suites:node tests/{shell,discovery,cooking,pantry,pantry-discovery,
global-discovery,enrichment,vision,preview,final-journey,accessibility}-smoke.mjs,
individually. Offline finaljourney variant requires providersdisabled, then set
COOKSY_OFFLINE_JOURNEY=1. Standard browser tests mock paid provider outputs. Never
run enrichment-live/paid image checks without renewed explicit authorization.
Previous3paid-call approval exhausted. .env/key/modelweights never printed/committed.

Deferred:liveSDXL(no provider/GPU/weights), food-specific/multi-object vision and
confidence improvements, durable graph/account memory, broader nutrition references,
production/auth/ops and human accessibility/device testing. Do not silently start.
Preserve user green-bananas...jpg and Zone.Identifier untracked; no privatephoto push.

Jac /home/langstkip/workspace/jac/bin/jac0.37.25. Stop preview before source/docs,
fmt/check/build/install or screenshotcopy (HMR); elevated compilercache access.
Actual workerPython must be explicitconfig or python3 fromPATH, never packaged
sys.executable(Jac launcher). Existing visionenvironment is langstEnv/bin/python;
weights remain ignored. Source provider settings preserved. Leave preview running
at http://172.26.123.103:8000 (WSL IP maychange). Main pushes authorized; verifyremote
hash, noforcepush. Implementationcheckpoint recorded in progress after commit.
