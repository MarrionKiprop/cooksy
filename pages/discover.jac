import from ..discovery.DiscoveryWorkspace { DiscoveryWorkspace }

def:pub Discover() -> JsxPage {
    return <DiscoveryWorkspace initial_mode="discover"/>;
}
