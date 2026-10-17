# Cooksy demo and handoff

## Start

Use the supplied Jac0.37.25 environment. From the repo: `jac install --frozen`,
then `jac run --dev`. UI8000, API8001. In Windows/WSL, use the first WSL address from
`hostname -I` if localhost forwarding fails. Keep the terminal running.

For a no-paid-call demo, set `COOKSY_LLM_MODE=demo` in ignored `.env` and restart.
No OpenAI key is required for the deterministic demo. Live SDXL remains off;
“View sample layout” works without model weights. Photo demo needs a Python worker
with Pillow (configured optional vision environment); manual typed intake always
works if vision is unavailable.

## JacHammer hosted demo limitations

Real photo recognition and SDXL generation are excluded from the hosted demo.
Use typed ingredients for the shared pantry, then Explore/Discover, recipe selection
and cook-along. Live culinary suggestions require server-side OpenAI configuration.

Photo recognition has a working local integration, but the hosted CPU dependency
installation ended with exit code137; the sandbox pod then became unavailable.
The cause was not confirmed. Hosted packages, verified MobileNet weights and worker
configuration were not completed or tested. Do not retry installation for this demo.

Real SDXL generation has not been verified locally or in JacHammer. No suitable
hosted GPU/model runtime or external SDXL provider is configured. The explicit
sample layout is an illustration placeholder, not an SDXL-generated image.
Neither sample photo suggestions nor sample layouts demonstrate real inference.

These are deployment/inference follow-ups, not completed hosted capabilities.
The user has deferred both features for the JacHammer demonstration.

## Five-minute walkthrough

1. Open **My pantry**. Type `potato, cooking oil, salt`. Click **Review ingredients**.
   Show the editable proposal and that the confirmed basket is still empty.
2. **Confirm & find meals**. Switch between Explore and Discover to show the same
   basket. Explore has15regions and optional traditions; Discover is Surprise Me.
3. With providers disabled, live discovery honestly has insufficient coverage.
   Choose **Browse sample recipes** explicitly. Show five labelled developer fixtures;
   no fixture is presented as a live AI recommendation.
4. Select **Gamja-jeon**. Only selection opens/prepares a full recipe. Inspect
   quantities, pantry availability and ordered method. Demo instructions are abbreviated.
5. Open **A little nourishment**. It shows a known-ingredient subtotal: potato and
   salt have supported gram references; generic cooking oil in millilitres is
   excluded rather than assumed zero or assigned an invented density. Expand
   references and follow an ingredient's USDA source link.
6. In **Picture your plate**, select **View sample layout**. Show the explicit
   no-image-generated disclosure. The recipe-grounded prompt remains in server metadata.
   Reload to demonstrate cached state without generation. Real SDXL is deferred.
7. **Start cook-along**, mark step1done, reload at step2, then finish the session.
   Back/restart/recovery controls work. Help requires live provider or browser-test
   mock; never fake a live help answer in a no-paid-call demo.
8. Optional: show **photo intake** with a prominent ingredient photo. Local MobileNet
   offers only supported low-reliability alternatives. Accept/edit/reject before
   confirmation. Explicit demo photo suggestions are fixed fixtures, not recognition.

## Live culinary demonstration (when deliberately enabled)

The saved server-only OpenAI key can be used through explicit ingredient interpretation,
discovery, selected preparation or step-help actions. These may incur provider costs.
No live requests are needed for regression verification. AI proposals remain
unverified, partial sets cannot be selected, and only one chosen recipe is prepared.
Do not imply USDA references verify AI recipe quantities, safety or authenticity.

## Quality checks

Stop the dev server before source edits, fmt/check/build/install. Run
`jac fmt . --check`, `jac test -d tests`, `jac check .`, `jac build --as client`.
Start the preview before browser checks. Run each `node tests/<name>-smoke.mjs`:
shell, discovery, cooking, pantry, pantry-discovery, global-discovery, enrichment,
vision, preview, final-journey, accessibility. Tests use browser mocks for paid LLM
and SDXL outputs; real local demo/graph/nutrition RPC are exercised. Accessibility
scan writes `/tmp/cooksy-m8-accessibility.json`; inspect incomplete checks manually.
Axe is a development dependency, not an application runtime feature.

Optional adapter Python runs `tests/vision_adapter_tests.py` and
`tests/sdxl_adapter_tests.py`. Never run `enrichment-live.mjs` or a paid provider test
without fresh explicit authorization. Do not commit .env, user photos or weights.

See [architecture](ARCHITECTURE.md), [nutrition methodology](NUTRITION.md),
and [follow-ups](FOLLOW_UPS.md) for scope and limits.
