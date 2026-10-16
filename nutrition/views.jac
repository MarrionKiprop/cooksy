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
