"""Small sourced nutrient reference, deterministic mass arithmetic and explicit gaps."""
import json;
import from pathlib { Path }
import from math { isfinite }
import from graph.models { Recipe, Ingredient, REQUIRES }
import from .models {
    FoodReference,
    NutritionProfile,
    NutritionItem,
    HAS_NUTRITION,
    NUTRITION_ITEM,
    USES_REFERENCE,
    SOURCE_INGREDIENT
}
import from .views { NutritionView, NutritionItemView, NutrientValue }
import from ai.memory { request_catalogue }
import from walkers.recipe { RecipeWalker }

glob nutrient_names: list[str] = [
         "Energy",
         "Protein",
         "Carbohydrate",
         "Fat",
         "Fibre",
         "Sodium"
     ];
glob nutrient_units: list[str] = ["kcal", "g", "g", "g", "g", "mg"];
glob disclosure: str = "Reference-based estimate from declared edible ingredient masses, not a measured meal. Includes every listed ingredient, including optional items. Raw USDA reference assumptions are shown below. Cooking losses, absorbed/discarded oil, moisture and yield changes are not adjusted. Equal servings are assumed. Missing foods, measures or nutrient values are omitted, never treated as zero. This does not verify dietary or allergy suitability.";

def references() -> list[FoodReference] {
    raw = json.loads((Path(__file__).parent / "references.json").read_text()) as dict[
        str,
        any
    ];
    result: list[FoodReference] = [];
    for item in raw["foods"] {
        values: list[float | None] = [
            None if value is None else float(value) for value in item["values"]
        ];
        if len(values) != 6
            or any(
                [
                    value is not None and (not isfinite(value) or value < 0)
                    for value in values
                ]
            ) {
            raise ValueError("Invalid nutrition reference values.");
        }
        result.append(
            FoodReference(
                name=str(item["name"]),
                fdc_id=str(item["fdc_id"]),
                description=str(item["description"]),
                source_url=str(item["source_url"]),
                values=values
            )
        );
    }
    return result;
}

def grams_for(quantity: float, unit: str) -> float | None {
    factors: dict[str, float] = {
        "g": 1.0,
        "gram": 1.0,
        "grams": 1.0,
        "kg": 1000.0,
        "mg": 0.001
    };
    if not isfinite(quantity) or quantity <= 0 or unit.strip().lower() not in factors {
        return None;
    }
    grams = quantity * factors[unit.strip().lower()];
    return grams if isfinite(grams) and grams <= 1000000 else None;
}

walker NutritionWalker {
    has reference: list[FoodReference];
    has selected: Recipe | None = None,
        profile: NutritionProfile | None = None,
        result: NutritionView | None = None;

    has rows: list[NutritionItemView] = [],
        totals: list[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        missing: list[bool] = [False, False, False, False, False, False],
        matched: int = 0;

    can begin with Recipe entry {
        if here.servings < 1 or here.servings > 100 {
            raise ValueError("Invalid serving count.");
        }
        self.selected = here;
        self.profile = NutritionProfile(
            recipe_version=here.version, servings=here.servings
        );
        here +>:HAS_NUTRITION():+> self.profile;
        visit [here->:REQUIRES:->];
    }

    can ingredient with Ingredient entry {
        recipe = self.selected;
        profile = self.profile;
        if recipe is None or profile is None {
            raise ValueError("Nutrition needs a selected recipe.");
        }
        for requirement in [edge recipe->:REQUIRES:->here] {
            grams = grams_for(requirement.quantity, requirement.unit);
            found: FoodReference | None = None;
            for ref in self.reference {
                if ref.name == here.name {
                    found = ref;
                    break;
                }
            }
            reason = "";
            if found is None {
                reason = "No exact supported food reference; excluded.";
            }
            if grams is None {
                reason += " No supported edible mass; counts and volumes are not guessed.";
            }
            item = NutritionItem(name=here.name, grams=grams, reason=reason.strip());
            profile +>:NUTRITION_ITEM():+> item;
            item +>:SOURCE_INGREDIENT():+> here;
            if found is not None {
                item +>:USES_REFERENCE():+> found;
            }
            self.rows.append(
                NutritionItemView(
                    name=here.name,
                    grams=grams,
                    reference=found.description if found is not None else "",
                    source_url=found.source_url if found is not None else "",
                    reason=reason.strip()
                )
            );
            if found is None or grams is None {
                continue;
            }
            self.matched += 1;
            for index in range(6) {
                amount = found.values[index];
                if amount is None {
                    self.missing[index] = True;
                } else {
                    self.totals[index] += grams / 100.0 * amount;
                }
            }
        }
    }

    can finish with Recipe exit {
        profile = self.profile;
        if profile is None {
            raise ValueError("No nutrition profile.");
        }
        complete = len(self.rows) > 0
            and self.matched == len(self.rows)
            and not any(self.missing);
        status = "estimate"
            if complete
            else ("partial" if self.matched > 0 else "unavailable");
        profile.status = status;
        values: list[NutrientValue] = [];
        for index in range(6) {
            supported = self.matched > 0 and not self.missing[index];
            values.append(
                NutrientValue(
                    name=nutrient_names[index],
                    unit=nutrient_units[index],
                    total=round(self.totals[index], 1) if supported else None,
                    per_serving=round(self.totals[index] / here.servings, 1)
                        if supported
                        else None
                )
            );
        }
        profile.values = values;
        self.result = NutritionView(
            status=status,
            servings=here.servings,
            matched=self.matched,
            total_items=len(self.rows),
            values=values,
            items=sorted(
                self.rows,
                key=lambda (row: NutritionItemView) -> str { return row.name; }
            ),
            disclosure=disclosure
        );
    }
}

def nutrition_for(recipe_key: str, version: str) -> NutritionView {
    if len(recipe_key) > 100 or len(version) > 100 {
        raise ValueError("Invalid recipe identity.");
    }
    selection = request_catalogue() spawn RecipeWalker(recipe_key=recipe_key);
    recipe = selection.selected_node;
    if recipe is None or recipe.version != version {
        raise ValueError("Recipe unavailable or changed. Reload the selected recipe.");
    }
    calculation = recipe spawn NutritionWalker(reference=references());
    if calculation.result is None {
        raise ValueError("Nutrition calculation unavailable.");
    }
    return calculation.result;
}
