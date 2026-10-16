"""Graph-first discovery; no LLM, pantry ranking, or persistence in this fixture."""
import from graph.models {
    CulinaryCatalogue,
    Region,
    CulinaryTradition,
    Recipe,
    Ingredient,
    RecipeStep,
    IN_REGION,
    PART_OF,
    BELONGS_TO,
    REQUIRES,
    HAS_STEP
}
import from graph.views {
    RegionView,
    TraditionView,
    RequirementView,
    StepView,
    RecipeView,
    TraversalEvent,
    DiscoveryResult
}

walker DiscoveryWalker {
    has region_key: str = "",
        tradition_key: str = "";

    has regions: list[RegionView] = [],
        traditions: list[TraditionView] = [],
        recipes: list[RecipeView] = [],
        events: list[TraversalEvent] = [],
        seen: set[str] = set(),
        reports: list[DiscoveryResult] = [];

    can begin with CulinaryCatalogue entry {
        self.events.append(TraversalEvent(kind="catalogue", label=here.version));
        # Always enumerate the region choices, even for a filtered discovery.
        for region in [here->:IN_REGION:->] {
            self.regions.append(
                RegionView(
                    key=region.key,
                    name=region.name,
                    subtitle=region.subtitle,
                    motif=region.motif,
                    tone=region.tone
                )
            );
        }
        visit [here->:IN_REGION:->];
    }

    can region with Region entry {
        if self.region_key and here.key != self.region_key {
            skip;
        }
        self.events.append(TraversalEvent(kind="region", label=here.name));
        visit [here<-:PART_OF:<-];
    }

    can tradition with CulinaryTradition entry {
        region = [here->:PART_OF:->][0];
        self.traditions.append(
            TraditionView(key=here.key, name=here.name, region_key=region.key)
        );
        if self.tradition_key and here.key != self.tradition_key {
            skip;
        }
        self.events.append(TraversalEvent(kind="tradition", label=here.name));
        visit [here<-:BELONGS_TO:<-];
    }

    can recipe with Recipe entry {
        tradition = [here->:BELONGS_TO:->][0];
        region = [tradition->:PART_OF:->][0];
        requirements: list[RequirementView] = [];
        for ingredient in [here->:REQUIRES:->] {
            for relation in [edge here->:REQUIRES:->ingredient] {
                requirements.append(
                    RequirementView(
                        name=ingredient.name,
                        quantity=relation.quantity,
                        unit=relation.unit,
                        essential=relation.essential,
                        preparation=relation.preparation,
                        substitution_notes=relation.substitution_notes
                    )
                );
            }
        }
        steps: list[StepView] = [];
        for step in [here->:HAS_STEP:sequence:->] {
            for relation in [edge here->:HAS_STEP:->step] {
                steps.append(
                    StepView(sequence=relation.sequence, instruction=step.instruction)
                );
            }
        }
        steps.sort(key=lambda (step: StepView) { step.sequence; });
        self.recipes.append(
            RecipeView(
                key=here.key,
                name=here.name,
                description=here.description,
                minutes=here.minutes,
                servings=here.servings,
                region=region.name,
                tradition=tradition.name,
                provenance=here.provenance,
                verification=here.verification,
                requirements=requirements,
                steps=steps
            )
        );
        self.events.append(TraversalEvent(kind="recipe", label=here.name));
        visit [here->:REQUIRES:->];
        visit [here->:HAS_STEP:sequence:->];
    }

    can ingredient with Ingredient entry {
        if jid(here) in self.seen {
            skip;
        }
        self.seen.add(jid(here));
        self.events.append(TraversalEvent(kind="ingredient", label=here.name));
    }

    can step with RecipeStep entry {
        self.events.append(TraversalEvent(kind="step", label=here.instruction));
    }

    can finish with CulinaryCatalogue exit {
        report DiscoveryResult(
            regions=self.regions,
            traditions=self.traditions,
            recipes=self.recipes,
            events=self.events
        );
    }
}
