# Architecture decisions

Date: 2026-10-16 (Africa/Nairobi). All implementation details remain subject to
installed-tool verification. Raw M0 command evidence: docs/evidence/.

## D001 — Repository and first-session scope

Context: jac-code was empty; no project history or recovery files existed. The
implementation prompt explicitly says “Implement only M0 unless M0 is already complete.”
Decision: create jac-code/cooksy as an independent main-branch repository; preserve
both briefs and complete only the documentation foundation. Global Git identity is
MarrionKiprop / maccherop@gmail.com. Alternative: build the entire product immediately.
Consequence: no runnable app at M0; M1 is the exact next milestone.

## D002 — Installed Jac and web-app scaffold

Context: the architecture's file tree is illustrative, not compile-ready.
Evidence: `jac --version` → 0.37.25; `jac guide`, `jac guide jac-essentials`,
`jac guide jac-project-kinds`, `jac guide jac-scaffold`, `jac create --help` all exit 0.
Decision: use the installed CLI's web-app scaffold in M1. No-name
`jac create --kind web-app --skip` initializes cwd; --skip defers dependency
installation to `jac install`. Inspect scaffold output before choosing module paths.
The guide's default web-app entry is main.jac plus endpoints.jac, so do not mandate
app.jac or .cl.jac filenames from the proposal. Alternative: hand-written config.
Consequence: preserve/reconcile M0 documents and use no --force during scaffolding.

## D003 — Full-stack workflow and evidence boundaries

Evidence: `jac guide jac-fullstack-patterns` and jac-scaffold verify inferred client
placement from JSX/imports, server endpoints, generated RPC, `jac check .`,
`jac run --show`, `jac run --dev`, and browser QA through `jac browse`.
Decision: adopt those patterns after scaffolding; read component, routing, styling,
core syntax and type guides before implementing M1. Read testing guidance before tests.
Alternative: a separate Python backend or hand-maintained JavaScript client.
Consequence: Jac remains the first-party implementation language. M0 has no runtime
validation: exploratory `jac run --show` in workspace exited 1 because there was no
entry-point/project. This is expected, not an app failure or a passing start check.

## D004 — Reconciling graph reuse with LLM-first discovery

Context: guidance requires graph-first retrieval while revised architecture rejects
a manually maintained global catalogue. Decision: the graph is reusable memory;
insufficient coverage triggers structured enrichment. M2 seeds are explicit demo/test
fixtures. Propose about five candidates first; generate the selected complete recipe
only after selection. Match and compute deterministically in Jac. Alternative: a
fixed recipe catalogue or generating five full recipes per request.
Consequence: M5 must test graph reuse, validation, provenance and duplicate handling.
No graph or by-llm syntax is asserted by this product decision; verify relevant guides
in M2/M5 before implementation.

## D005 — Provider and ML boundaries

Context: no provider, GPU, weights or inference integration has been verified.
Decision: defer provider activation to M5–M7; define proposed settings as such in
.env.example. Add tested deterministic demo modes and visible status disclosure.
Vision requires explicit confirmation. SDXL follows recipe selection with the required
AI label; nutrition uses reference data or disclosed demo estimates.
Alternative: implicit provider assumptions or fabricated live results.
Consequence: M0 requires no credentials and makes no claim that inference works.

## D006 — Local Git and milestone hash bookkeeping

Context: Git identity and SSH key file permissions exist; gh is unavailable and no
remote owner/destination or authentication has been established. Decision: create
local commits now, leave key material untouched, defer publishing until destination
is resolved. Record the M0 foundation hash in a follow-up documentation commit.
Alternative: guess a GitHub owner/visibility or attempt to embed a commit's own hash.
Consequence: local history is recoverable; the ledger commit is discoverable with
`git log` and cannot recursively contain its own hash.

## D007 — Preserve original document bytes

Context: whitespace checking flags CRLF in the supplied briefs and a final blank
line in captured CLI output. Decision: preserve source/evidence bytes and apply
whitespace checks to authored documentation separately; record the initial failed
check explicitly. Alternative: normalise originals and lose byte identity.
Consequence: source verification remains exact, and original whitespace is not
misreported as a passing check.

## D008 — GitHub authentication and ongoing push authorization

User requested GitHub configuration and continuing pushes. Workspace githubfile
was rejected; ~/.ssh/id_ed25519 authenticated as MarrionKiprop (SSH exit 1 with
GitHub's successful-authentication greeting is expected). Set repository-local
core.sshCommand to select that key and origin to MarrionKiprop/cooksy over SSH.
Do not change global SSH settings or copy key material. Remote ls-remote returned
Repository not found; repository creation and initial push remain pending. No gh
CLI or token environment variable is available. Offered GitHub plugin connection
for repository creation. Future checked commits should be pushed without asking
again; verify remote branch hash, never force push or overwrite remote history.
