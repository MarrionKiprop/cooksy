# M5 workflow additions complete; M6 not started

Read AGENTS.md, docs/PROGRESS.md, docs/DECISIONS.md and git status/log first.
Natural-language review → editable explicit confirmation → one shared pantry →
Explore 15 regions/traditions or worldwide Discover → five valid choices → selected
recipe → cook-along. Discover serves Surprise Me. Normal graph/LLM discovery does
not use a static seed database; /demo and explicit labelled fallback retain fixtures.
The supplied workflow PNG is preserved. M6/M7/M8 remain unimplemented.

36 Jac tests, 54-file check, client build and all seven browser suites passed.
All inference mocked; no extra paid requests. Prior three-request authorization
is exhausted. Never print .env/keys. GPT-4.1 mini remains server-only.
Screenshots under docs/screenshots/m5-alignment show labelled browser fixtures.
Graph cache expires on server restart. Names only; no quantity/allergy verification.
Shared pantry has tab storage and navigation-memory fallback, no durable account data.
Initial load and restoration never infer; discovery has initial + one repair maximum.

Jac: /home/langstkip/workspace/jac/bin/jac 0.37.25. Stop preview before edits,
checks/build or copying captures; restart before browser tests. Compiler cache needs
elevated execution. Gates: jac fmt . --check; jac test -d tests; jac check .;
jac build --as client. Browser suites: tests/{shell,discovery,cooking,pantry,
pantry-discovery,global-discovery,enrichment}-smoke.mjs, each run with node.
Do not run enrichment-live without renewed paid-call authorization.

User authorizes normal checked commits/pushes to main; verify remote hash, never
force push. See progress for implementation checkpoint hash. Next: user direction
before M6. WSL preview previously works at http://172.26.123.103:8000; IP may change.
