# Cooksy

Your Ingredients. The World's Kitchens.

Cooksy is a planned Jac-native culinary discovery and cook-along application:
confirmed pantry → culinary discovery → graph-based feasibility ranking → five
meal choices → selected recipe → nutrition/serving preview → guided cooking.

**Current status: M0 recovery foundation. There is no runnable application yet.**
No UI, graph, inference integration or live provider has been implemented or tested.

## Repository and source requirements

Local repository: `/home/langstkip/workspace/jac-code/cooksy`, branch `main`.
The original [implementation guidance](docs/briefs/implementation-guidance.md) and
[revised architecture](docs/briefs/technical-architecture.md) are preserved verbatim.
Resume using [NEXT_SESSION.md](NEXT_SESSION.md); see [progress](docs/PROGRESS.md)
and [architecture decisions](docs/DECISIONS.md).

## Local workflow

The supplied Jac environment contains Jac 0.37.25. No installation is needed for M0.

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
jac --version
jac guide
```

M1 will scaffold in this existing repository using `jac create --kind web-app --skip`
(no project name and no --force), inspect the generated files, then install dependencies.
Do not run the scaffold until beginning M1 and preserving the recovery documents.
The installed scaffold guide verifies this planned workflow:

```bash
jac install
jac check .
jac run --show
jac run --dev
```

These app commands have not passed here: M0 deliberately contains no jac.toml or
application code. `jac test` will apply after feature tests exist; M1 must record
actual startup, navigation and browser verification. Dependency installation may
need network permission. Verified guide outputs are preserved in docs/evidence.

## Intended architecture and provider setup

Jac owns client/server application logic and real culinary nodes, relationship
edges and walkers. Graph memory is consulted before structured LLM enrichment;
Jac performs deterministic availability/ranking. Candidate discovery and full recipe
preparation are separate stages. A small M2 seed supports tests and demos only.
Python adapters are restricted to MobileNet suggestions and SDXL serving previews.

No provider is configured. `.env.example` lists proposed application settings,
explicitly not runtime functionality. M5 will verify `jac guide jac-by-llm`, select
and test the provider/model, document actual secret names and server-side loading,
and add deterministic mocks. M6 will document MobileNet dependencies, compatible
weights and preprocessing; M7 will document SDXL local/hosted contracts, storage,
cache and GPU requirements. Those activation steps depend on the adapters being
implemented. Demo results must never be represented as real inference. Nutrition
will use referenced measurements or clearly identified demo estimates.

GitHub SSH authentication is verified as MarrionKiprop using the existing
`~/.ssh/id_ed25519` key, selected through repository-local Git configuration.
`origin` targets `git@github.com:MarrionKiprop/cooksy.git`; remote creation is
pending because GitHub returned “Repository not found.” No commits have been
pushed yet. Once the empty repository exists, run `git push -u origin main`.
Future checked milestone commits must be pushed and verified against origin/main.
SSH keys remain outside the project and are not included in any commit.
