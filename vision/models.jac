import from graph.models { Ingredient, Pantry }
node IngredientImage {
    has digest: str,
        model: str,
        width: int,
        height: int,
        demo: bool;
}

node DetectionResult {
    has label: str,
        suggested: str,
        confidence: float,
        position: int;
}

edge DETECTS: IngredientImage --> DetectionResult {}
edge CONFIRMED_AS: DetectionResult --> Ingredient {}
edge PANTRY_IMAGE: Pantry --> IngredientImage {}
