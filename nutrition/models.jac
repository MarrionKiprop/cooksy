import from graph.models { Recipe, Ingredient }
import from .views { NutrientValue }
node FoodReference {
    has name: str,
        fdc_id: str,
        description: str,
        source_url: str,
        values: list[float | None];
}

node NutritionProfile {
    has recipe_version: str,
        servings: int,
        status: str = "unavailable";

    has values: list[NutrientValue] = [];
}

node NutritionItem {
    has name: str,
        grams: float | None,
        reason: str;
}

edge HAS_NUTRITION: Recipe --> NutritionProfile {}
edge NUTRITION_ITEM: NutritionProfile --> NutritionItem {}
edge USES_REFERENCE: NutritionItem --> FoodReference {}
edge SOURCE_INGREDIENT: NutritionItem --> Ingredient {}
