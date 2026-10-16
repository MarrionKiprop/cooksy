import from ..discovery.DiscoveryWorkspace { DiscoveryWorkspace }

def:pub PantryWorkspace() -> JsxElement {
    return <DiscoveryWorkspace initial_mode="explore"/>;
}
