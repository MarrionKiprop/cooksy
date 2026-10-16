import from ..discovery.DiscoveryWorkspace { DiscoveryWorkspace }

def:pub Explore() -> JsxPage {
    return <DiscoveryWorkspace initial_mode="explore"/>;
}
