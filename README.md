# Cooksy

Your Ingredients. The World's Kitchens.

Cooksy is a Jac-native culinary discovery and cook-along application in development.
**M1 provides a runnable responsive shell:** Home, an interactive regional preview,
Pantry and Cook Along empty states, a not-found page, and real Jac server connectivity
with retry. Discovery, pantry storage, recipes, cooking sessions and model inference
are not yet implemented. Every screen discloses its preview status.

## Run locally

Use the supplied Jac 0.37.25 environment (pinned in jac.toml):

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
jac install
jac run --show
jac run --dev
```

Open http://localhost:8000. Development UI uses port 8000; the API uses port 8001.
No provider keys or environment file are needed for the shell. Installation needs
package-registry access. The first server start provisions Jac's local runtime/data.
This is a local development preview; production deployment is a later milestone.
Jac's runtime enables a local admin portal by default; configure its credentials
and deployment settings before exposing this development server publicly.

## Verify

Stop the development server before formatting, checking or building: these commands
can rewrite generated modules, and concurrent HMR can interrupt browser navigation.

```bash
jac fmt . --check
jac check .
jac build --as client
```

Type checks pass with installed-compiler warnings about JSX/runtime typing and
unused generated state aliases; these are documented in docs/evidence/m1-verification.md.
M1 behavior is checked in a real browser rather than a trivial status-string unit test.
Install the browser once, then start `jac run --dev` in a separate terminal:

```bash
node .jac/client/node_modules/@playwright/test/cli.js install chromium
node tests/shell-smoke.mjs
```

The smoke suite covers all routes, deep-link refresh, a 404, keyboard skip link and
region selection, actual RPC requests, offline/reconnect, and 390px/320px layouts.
To regenerate screenshots, use `COOKSY_SCREENSHOTS=1 node tests/shell-smoke.mjs`.
Captures go to /tmp/cooksy-m1-screenshots to avoid Jac watcher reloads. Stop the
server before copying them into docs/screenshots.
Browser binaries and Node are developer tooling, not application implementation.
`jac test` will cover graph/domain tests from M2 onward.

## Architecture

- `main.jac` renders the file-based route tree and imports shared CSS.
- `pages/layout.jac` supplies navigation, the development disclosure and footer.
- `pages/` contains Home, Explore, Pantry, Cook Along and catch-all routes.
- `components/` contains typed Jac UI components and reactive connectivity state.
- `endpoints.jac` exposes a read-only status function, explicitly pinned server-side.
- `styles/global.css` defines responsive typography, colors, layouts and a decorative
  serving illustration. The illustration is CSS artwork, not a model-generated meal.

Later milestones add actual culinary nodes, typed edges and traversing walkers.
Graph memory is consulted before structured LLM enrichment; Jac performs deterministic
matching and nutrition calculations. Candidate discovery proposes approximately five
meals; full recipe generation follows selection. The M2 seed is test/demo data,
not a manually maintained production catalogue. Python stays limited to specialised
MobileNet and SDXL inference adapters.

## Providers and limitations

No provider is configured. `.env.example` lists proposed settings, explicitly not
runtime functionality. M5 will verify the installed by-llm guide, select/test a model
provider and document server-side credentials and activation. M6 will document vision
weights/preprocessing and require confirmation before pantry mutation. M7 will document
SDXL local/hosted contracts, caching and the required illustrative AI label. Nutrition
will use referenced measurements or disclosed demo estimates. None of those integrations
has been exercised in M1.

## Project memory and GitHub

The original [implementation guidance](docs/briefs/implementation-guidance.md) and
[architecture](docs/briefs/technical-architecture.md) are preserved verbatim.
Resume using [NEXT_SESSION.md](NEXT_SESSION.md); see [progress](docs/PROGRESS.md),
[decisions](docs/DECISIONS.md), and [M1 verification](docs/evidence/m1-verification.md).

Remote: [MarrionKiprop/cooksy](https://github.com/MarrionKiprop/cooksy), branch main.
SSH uses the existing ~/.ssh/id_ed25519 key through repository-local Git configuration.
After checked milestone/recovery commits, `git push` and verify remote main equals
local HEAD. Never commit keys, .env, generated runtime/data, models or user uploads.
