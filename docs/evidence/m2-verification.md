# M2 verification

M2 introduces a request-local transient demo graph, not persisted user data.
Topology: 1 catalogue, 4 regions, 8 traditions, 8 recipes, 16 shared ingredients,
16 steps. Typed REQUIRES holds quantity/unit/essentiality/preparation/substitution;
HAS_STEP holds sequence. Catalogue ownership edges retain reverse-linked sources.
Discovery traverses IN_REGION, incoming PART_OF, incoming BELONGS_TO, outgoing
REQUIRES and HAS_STEP. Projected response types contain data read from that topology.

Checks:

- Installed guide queries saved in m2-guides; syntax queried before implementation.
- Initial check failed due to an in-body docstring; changed to a comment.
- Initial graph test caught unordered steps in the transient runtime; explicit
  sorting by projected HAS_STEP sequence fixed the intentionally reversed seed.
- Repeat test caught transient reverse-linked source lifetime issue; typed catalogue
  ownership edges fixed reachability. No persisted data reset was performed.
- First client build attempted to compile graph queries into JS; server pin for
  endpoints.discover established a generated RPC boundary. Subsequent build passed.
- `jac test tests/discovery_tests.jac`: 4 passed; repeated run: 4 passed.
- `jac fmt . --check`: 17/17 sources formatted.
- `jac check .`: 17 passed; installed JSX/runtime warnings remain.
- `jac build --as client`: PASS after server pin.
- Discovery browser smoke: PASS, real RPC and typed payloads; 8→2→1 filters,
  optional quantities, ordered steps, trace, region reset, unknown-filter empty
  response, mobile layout, error/retry and no page errors.
- Original shell smoke: PASS, navigation/keyboard/deep links/404 and 390px/320px layouts.

[Desktop Explore](../screenshots/m2-explore-desktop.png) and
[mobile Explore](../screenshots/m2-explore-mobile.png) capture the demo experience.

The graph tests prove five node types are reached, shared ingredients are deduped
in the visit trace, requirements change when their edge quantities change, optional
flags and preparation survive projection, steps are ordered, region/tradition/all
filters work, unknown or incompatible filters return no recipes, and fixtures and
walker collections are independent. They operate on transient graphs with no root
attachment, avoiding cross-run graph pollution.

Demo dishes are developer-authored unverified adaptations with abbreviated sample
steps. They are not evidence of authenticity, complete recipes, nutrition reference
data or model inference. No pantry ranking, RecipeWalker/cooking session, persistence,
vision, SDXL or by-llm enrichment is implemented in M2.
