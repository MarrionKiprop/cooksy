# Nutrition estimates and reference provenance

Cooksy computes nutrition in Jac from declared **edible ingredient masses**, not
pantry presence or LLM nutrient claims. This is food-composition reference data,
not a static recipe catalogue. It does not change LLM-based culinary discovery.

The checked-in `nutrition/references.json` contains ten records extracted from the
[USDA FoodData Central SR Legacy April 2018 CSV archive](https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_csv_2018-04.zip),
retrieved 2026-10-16. Its source archive SHA256 is stored in the JSON. The archive
is not shipped. Every record retains its FDC identifier, exact description, source
link, and nutrient values. USDA describes the data as public domain in its
[API guide](https://fdc.nal.usda.gov/api-guide/). See the
[field definitions](https://fdc.nal.usda.gov/portal-data/external/dataDictionary)
for the per-100-gram basis. SR Legacy is historical reference data, not a claim of
new measurements in 2026.

Extraction uses `food.csv` for descriptions and `food_nutrient.csv` for amounts,
joining on fdc_id. Nutrient IDs, in stored order: 1008 energy (kcal), 1003 protein
(g), 1005 carbohydrate (g), 1004 total fat (g), 1079 fibre (g), 1093 sodium (mg).
Absent values remain null, never zero. Exact mappings:

| Ingredient name | FDC ID | Reference assumption |
| --- | --- | --- |
| potato | 170026 | Flesh and skin, raw |
| spinach | 168462 | Raw |
| cabbage | 169975 | Raw |
| onion | 170000 | Raw |
| carrot | 170393 | Raw |
| tomato | 170457 | Red, ripe, raw, year-round average |
| egg | 171287 | Whole, raw, fresh; edible portion |
| olive oil | 171413 | Olive oil, salad or cooking |
| salt | 173468 | Table salt |
| banana | 173944 | Raw, edible portion |

These are explicit assumptions, not fuzzy food matches. Generic cooking oil is
not assumed to be olive oil; raw chickpeas do not stand in for cooked chickpeas.
Unmapped foods remain unsupported. More references can be added with independently
checked records and tests; there is no live USDA request/key dependency.

For each supported nutrient: sum(mass_g / 100 × nutrient_per_100g). Divide the
unrounded sum by declared servings, then round each displayed value to one decimal.
Supported mass units: g/gram/grams, kg, mg. No assumed egg sizes, cup weights,
densities or millilitre-to-gram conversions. Nonpositive/nonfinite/oversized masses
and invalid servings are rejected or excluded. All listed ingredients, including
optional ones, are included when supported. Deselecting optional ingredients or
changing quantities is not currently a recipe-editing feature.

`NutritionWalker` visits actual REQUIRES ingredient relationships, creates
Recipe→HAS_NUTRITION→NutritionProfile→NUTRITION_ITEM→NutritionItem, and connects items
to original ingredients and reference nodes. These are request-local graphs; no
private pantry is attached to a shared root. Values are calculated from recipe
quantities regardless of whether the ingredient is present in the pantry.

A complete supported set is an estimate. An incomplete set shows only a clearly
labelled **known-ingredient subtotal**, not whole-meal nutrition. Its exclusions
are listed. A missing nutrient value is unavailable, even when other nutrient
values can be calculated. No supported items means no zero-valued meal table.

Cooking losses, moisture/yield changes, discarded or absorbed oil, ingredient
variety, actual edible weights and unequal portions are not modeled. Estimates
are not dietary, allergy or culinary verification. Demo recipe quantities remain
unverified fixtures; real reference numbers do not make them verified recipes.
