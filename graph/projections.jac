"""Single relationship-backed recipe projection reused by discovery and matching."""
import from graph.models { Recipe, PART_OF, BELONGS_TO, REQUIRES, HAS_STEP }
import from graph.views { RecipeView, RequirementView, StepView }

def recipe_view(recipe: Recipe) -> RecipeView {
    tradition = [recipe->:BELONGS_TO:->][0];
    region = [tradition->:PART_OF:->][0];
    requirements: list[RequirementView] = [];
    for ingredient in [recipe->:REQUIRES:->] {
        for relation in [edge recipe->:REQUIRES:->ingredient] {
            requirements.append(
                RequirementView(
                    name=ingredient.name,
                    quantity=relation.quantity,
                    unit=relation.unit,
                    essential=relation.essential,
                    preparation=relation.preparation,
                    substitution_notes=relation.substitution_notes,
                    substitutes=relation.substitutes
                )
            );
        }
    }
    steps: list[StepView] = [];
    for step in [recipe->:HAS_STEP:->] {
        for relation in [edge recipe->:HAS_STEP:->step] {
            steps.append(
                StepView(sequence=relation.sequence, instruction=step.instruction)
            );
        }
    }
    steps.sort(key=lambda (step: StepView) { step.sequence; });
    return RecipeView(
        key=recipe.key,
        name=recipe.name,
        description=recipe.description,
        minutes=recipe.minutes,
        servings=recipe.servings,
        region=region.name,
        tradition=tradition.name,
        provenance=recipe.provenance,
        verification=recipe.verification,
        requirements=requirements,
        steps=steps,
        version=recipe.version
    );
}
