"""Typed wire views, projected from culinary graph relationships."""
obj RegionView {
    has key: str,
        name: str,
        subtitle: str,
        motif: str,
        tone: str;
}

obj TraditionView {
    has key: str,
        name: str,
        region_key: str;
}

obj RequirementView {
    has name: str,
        quantity: float,
        unit: str,
        essential: bool,
        preparation: str,
        substitution_notes: str;

    has substitutes: list[str] = [];
}

obj StepView {
    has sequence: int,
        instruction: str;
}

obj RecipeView {
    has key: str,
        name: str,
        description: str,
        minutes: int,
        servings: int,
        region: str,
        tradition: str,
        provenance: str,
        verification: str,
        requirements: list[RequirementView],
        steps: list[StepView];
}

obj TraversalEvent {
    has kind: str,
        label: str;
}

obj DiscoveryResult {
    has regions: list[RegionView],
        traditions: list[TraditionView],
        recipes: list[RecipeView],
        events: list[TraversalEvent];

    has mode: str = "demo_graph",
        disclosure: str = "Developer demo fixtures. No AI inference. Pantry matching compares names, not quantities. Recipes are illustrative adaptations, not verified cooking guidance.";
}
