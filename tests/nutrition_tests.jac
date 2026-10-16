import from unittest.mock { patch }
import from graph.models { Recipe, Ingredient, REQUIRES }
import from nutrition.service { NutritionWalker, references, grams_for, nutrition_for }
import from nutrition.models { HAS_NUTRITION, NUTRITION_ITEM, USES_REFERENCE }

test "USDA reference values provenance and schema are retained" {
    refs = references();
    assert len(refs) == 10 and len(set([ref.name for ref in refs])) == 10;
    potato = [
        ref
        for ref in refs
        if ref.name == "potato"
    ][0];
    assert potato.fdc_id == "170026"
        and potato.values == [77.0, 2.05, 17.49, 0.09, 2.1, 6.0];
    assert potato.source_url
        == "https://fdc.nal.usda.gov/food-details/170026/nutrients";
}

test "nutrition scales edible masses and equal servings through actual graph" {
    recipe = Recipe(
        key="nutrition-test", name="Potato", description="Test", minutes=10, servings=2
    );
    recipe +>:REQUIRES(quantity=0.3, unit="kg"):+> Ingredient(name="potato");
    recipe +>:REQUIRES(quantity=2.0, unit="g", essential=False):+> Ingredient(
        name="salt"
    );
    walking = recipe spawn NutritionWalker(reference=references());
    result = walking.result;
    assert result is not None and result.status == "estimate";
    assert result.values[0].total == 231.0 and result.values[0].per_serving == 115.5;
    assert result.values[5].per_serving == 396.6;
    profile = [recipe->:HAS_NUTRITION:->][0];
    assert profile.values[0].total == 231.0
        and profile.recipe_version == recipe.version;
    assert len([profile->:NUTRITION_ITEM:->->:USES_REFERENCE:->]) == 2;
}

test "unsupported foods counts and volumes produce labelled partial not complete meal totals" {
    recipe = Recipe(
        key="partial", name="Test", description="Test", minutes=10, servings=2
    );
    recipe +>:REQUIRES(quantity=100.0, unit="g"):+> Ingredient(name="potato");
    recipe +>:REQUIRES(quantity=15.0, unit="ml"):+> Ingredient(name="cooking oil");
    recipe +>:REQUIRES(quantity=1.0, unit="piece"):+> Ingredient(name="egg");
    result = (recipe spawn NutritionWalker(reference=references())).result;
    assert result is not None
        and result.status == "partial"
        and result.matched == 1
        and result.total_items == 3;
    assert result.values[0].total == 77.0;
    assert len(
        [
            row
            for row in result.items
            if row.reason
        ]
    )
        == 2;
    assert "not a measured meal" in result.disclosure;
}

test "missing nutrient values remain unavailable never fabricated zeros" {
    refs = references();
    potato = [
        ref
        for ref in refs
        if ref.name == "potato"
    ][0];
    potato.values[1] = None;
    recipe = Recipe(
        key="missing", name="Test", description="Test", minutes=10, servings=1
    );
    recipe +>:REQUIRES(quantity=100.0, unit="g"):+> Ingredient(name="potato");
    result = (recipe spawn NutritionWalker(reference=refs)).result;
    assert result is not None and result.status == "partial";
    assert result.values[1].total is None and result.values[1].per_serving is None;
    assert result.values[0].total == 77.0;
}

test "no references invalid masses or empty recipe do not show zero meal nutrition" {
    assert grams_for(1.0, "cup") is None and grams_for(-1.0, "g") is None;
    assert grams_for(float("nan"), "g") is None
        and grams_for(float("inf"), "g") is None;
    assert grams_for(1000.0, "mg") == 1.0;
    recipe = Recipe(
        key="empty", name="Test", description="Test", minutes=10, servings=1
    );
    result = (recipe spawn NutritionWalker(reference=references())).result;
    assert result is not None and result.status == "unavailable";
    assert all([value.total is None for value in result.values]);
    recipe +>:REQUIRES(quantity=100.0, unit="g"):+> Ingredient(name="cooked chickpea");
    unsupported = (recipe spawn NutritionWalker(reference=references())).result;
    assert unsupported is not None and unsupported.status == "unavailable";
    recipe.servings = 0;
    with testraises(ValueError) {
        recipe spawn NutritionWalker(reference=references());
    }
}

test "nutrition endpoint rejects unselected and stale recipes without inference" {
    with testraises(ValueError) {
        nutrition_for("unknown", "cooksy-demo-v1");
    }
    with testraises(ValueError) {
        nutrition_for("gamja-jeon-demo", "stale-version");
    }
    result = nutrition_for("gamja-jeon-demo", "cooksy-demo-v1");
    assert result.status == "partial"
        and result.matched == 2
        and result.total_items == 3;
}
