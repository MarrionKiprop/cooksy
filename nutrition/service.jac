"""Small sourced nutrient reference, deterministic mass arithmetic and explicit gaps."""
import json;
import from pathlib { Path }
import from math { isfinite }
import from threading { RLock }
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
import from .views {
    NutritionView,
    NutritionItemView,
    NutrientValue,
    EstimatedFood,
    NutritionProposal
}
import ai.provider as provider;
import from ai.memory { request_catalogue }
import from walkers.recipe { RecipeWalker }
import from graph.projections { recipe_view }

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
glob ai_cache: dict[str, NutritionView] = {},
     ai_lock = RLock();

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
    has estimates: list[EstimatedFood] = [],
        used_ai: bool = False;
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
            estimate: EstimatedFood | None = None;
            for proposal in self.estimates {
                if proposal.name == here.name {
                    estimate = proposal;
                    break;
                }
            }
            item_ai: bool = False;
            values: list[float | None] = found.values
                if found is not None
                else [None for _ in range(6)];
            if estimate is not None {
                if grams is None and estimate.grams is not None {
                    grams = estimate.grams;
                    item_ai = True;
                    reason = "AI-estimated edible mass. ";
                }
                if found is None and any([v is not None for v in estimate.values]) {
                    found = FoodReference(
                        name=here.name,
                        fdc_id="",
                        description="AI food-composition estimate; not a retrieved reference",
                        source_url="",
                        values=estimate.values
                    );
                    values = estimate.values;
                    item_ai = True;
                    reason += "AI-estimated nutrient values. ";
                } elif found is not None {
                    values = [v for v in found.values];
                    for index in range(6) {
                        if values[index] is None
                            and estimate.values[index] is not None {
                            values[index] = estimate.values[index];
                            item_ai = True;
                        }
                    }
                }
                if item_ai {
                    reason += "AI assumptions: " + estimate.assumptions + " ";
                }
            }
            if found is None {
                reason += "No exact supported food reference; excluded.";
            }
            if grams is None {
                reason += " No supported edible mass; counts and volumes are not guessed.";
            }
            if any([value is None for value in values]) {
                reason += " Some nutrient values are unavailable.";
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
            self.used_ai = self.used_ai or item_ai;
            self.matched += 1;
            for index in range(6) {
                amount = values[index];
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
        if self.used_ai {
            status = "ai_estimate" if complete else "ai_partial";
        }
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
            disclosure=(
                "Includes approximate AI food composition or portion-mass estimates, not verified USDA values or measured nutrition. Assumptions are listed per ingredient. "
                    if self.used_ai
                    else ""
            )
                + disclosure
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
    key = recipe_key + "|" + version;
    with ai_lock {
        if key in ai_cache {
            return ai_cache[key];
        }
    }
    calculation = recipe spawn NutritionWalker(reference=references());
    if calculation.result is None {
        raise ValueError("Nutrition calculation unavailable.");
    }
    return calculation.result;
}

def validate_estimates(
    proposal: NutritionProposal, requested: list[str]
) -> list[EstimatedFood] {
    if len(proposal.items) > len(requested) {
        raise ValueError("Too many nutrition estimates.");
    }
    seen: set[str] = set();
    limits: list[float] = [1000.0, 100.0, 100.0, 100.0, 100.0, 100000.0];
    for item in proposal.items {
        if item.name not in requested or item.name in seen or len(item.values) != 6 {
            raise ValueError("Invalid nutrition ingredient identity.");
        }
        seen.add(item.name);
        if not item.assumptions.strip() or len(item.assumptions) > 600 {
            raise ValueError("Nutrition assumptions required.");
        }
        if item.grams is not None
            and (not isfinite(item.grams) or not 0 < item.grams <= 1000000) {
            raise ValueError("Invalid estimated mass.");
        }
        for index in range(6) {
            value = item.values[index];
            if value is not None
                and (not isfinite(value) or not 0 <= value <= limits[index]) {
                raise ValueError("Invalid estimated nutrient value.");
            }
        }
        macros = item.values[1:4];
        if all([v is not None for v in macros])
            and sum(
                [
                    v
                    for v in macros
                    if v is not None
                ]
            )
                > 105 {
            raise ValueError("Invalid estimated macronutrient mass.");
        }
    }
    return proposal.items;
}

def estimate_for(recipe_key: str, version: str) -> NutritionView {
    baseline = nutrition_for(recipe_key, version);
    if baseline.status == "estimate" {
        return baseline;
    }
    selection = request_catalogue() spawn RecipeWalker(recipe_key=recipe_key);
    recipe = selection.selected_node;
    if recipe is None or recipe.version != version {
        raise ValueError("Recipe unavailable or changed.");
    }
    key = recipe_key + "|" + version;
    with ai_lock {
        if key in ai_cache {
            return ai_cache[key];
        }
        if not provider.enabled() {
            raise ValueError("Nutrition AI is unavailable.");
        }
        requested = [
            row.name
            for row in baseline.items
            if row.reason
        ];
        context: list[dict[str, any]] = [];
        for ingredient in [recipe->:REQUIRES:->] {
            if ingredient.name not in requested {
                continue;
            }
            for amount in [edge recipe->:REQUIRES:->ingredient] {
                context.append(
                    {
                        "name": ingredient.name,
                        "quantity": amount.quantity,
                        "unit": amount.unit,
                        "preparation": amount.preparation
                    }
                );
            }
        }
        if len(requested) > 24 or not requested {
            raise ValueError("Nutrition estimation is unavailable for these gaps.");
        }
        view = recipe_view(recipe);
        proposal = provider.estimate_foods(
            json.dumps(
                {
                    "recipe": recipe.name,
                    "description": recipe.description,
                    "region": view.region,
                    "tradition": view.tradition,
                    "ingredients": context
                }
            )
        );
        estimates = validate_estimates(proposal, requested);
        calculation = recipe spawn NutritionWalker(
            reference=references(), estimates=estimates
        );
        result = calculation.result;
        if result is None or result.status not in ["ai_estimate", "ai_partial"] {
            raise ValueError("No usable AI nutrition estimates.");
        }
        if len(ai_cache) >= 16 {
            ai_cache.pop(list(ai_cache.keys())[0]);
        }
        ai_cache[key] = result;
        return result;
    }
}
