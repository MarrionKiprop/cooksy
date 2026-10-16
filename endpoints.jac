"""Read-only connectivity and transient culinary demo discovery endpoints."""

def:pub shell_status() -> str {
    return "Connected to the Jac kitchen";
}

import from graph.seed { build_demo_graph }
import from graph.views { DiscoveryResult }
import from walkers.discovery { DiscoveryWalker }

def:pub discover(region_key: str = "", tradition_key: str = "") -> DiscoveryResult {
    # Browse a transient demo graph without writing user state.
    catalogue = build_demo_graph();
    discovery = catalogue spawn DiscoveryWalker(
        region_key=region_key, tradition_key=tradition_key
    );
    return discovery.reports[0];
}
