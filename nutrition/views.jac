obj NutrientValue {
    has name: str,
        unit: str,
        total: float | None,
        per_serving: float | None;
}

obj NutritionItemView {
    has name: str,
        grams: float | None,
        reference: str,
        source_url: str,
        reason: str;
}

obj NutritionView {
    has status: str,
        servings: int,
        matched: int,
        total_items: int,
        values: list[NutrientValue],
        items: list[NutritionItemView],
        disclosure: str;
}

obj EstimatedFood {
    has name: str,
        grams: float | None,
        values: list[float | None],
        assumptions: str;
}

obj NutritionProposal {
    has items: list[EstimatedFood];
}

sem EstimatedFood.name = "Exact requested ingredient name, including raw/cooked distinctions.";
sem EstimatedFood.grams = "Approximate edible grams for the declared quantity, not a serving. Use stated typical portion or density assumptions when reasonable; null when a reasonable estimate cannot be made.";
sem EstimatedFood.values = "Six approximate values per 100 g: kcal, protein g, carbohydrate g, fat g, fibre g, sodium mg. Unknown values must be null, not zero.";
sem EstimatedFood.assumptions = "Short explicit food identity, raw/cooked state and portion or density assumptions. No invented citations or medical claims.";
sem NutritionProposal.items = "Only requested unsupported ingredients, at most one item per exact name. Omit an item if its food identity cannot be reasonably interpreted.";
