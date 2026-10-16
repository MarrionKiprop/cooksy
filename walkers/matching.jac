"""Deterministic name matching, explicit missing items, and stable ranking."""
import from graph.models {
    CulinaryCatalogue,
    Pantry,
    Ingredient,
    Region,
    CulinaryTradition,
    Recipe,
    IN_REGION,
    PART_OF,
    BELONGS_TO,
    HAS_INGREDIENT
}
import from graph.projections { recipe_view }
import from graph.views { RequirementView, TraversalEvent }
import from pantry.views { MatchView, SubstitutionView }

walker MatchingWalker {
    has pantry: Pantry;
    has region_key: str = "",
        tradition_key: str = "",
        names: list[str] = [],
        matches: list[MatchView] = [],
        events: list[TraversalEvent] = [],
        reports: list[list[MatchView]] = [];

    can begin with CulinaryCatalogue entry {
        visit self.pantry;
        visit [here->:IN_REGION:->];
    }

    can pantry with Pantry entry {
        self.events.append(
            TraversalEvent(
                kind="pantry", label="Read confirmed ingredient relationships"
            )
        );
        visit [here->:HAS_INGREDIENT:->];
    }

    can ingredient with Ingredient entry {
        self.names.append(here.name);
        self.events.append(TraversalEvent(kind="pantry ingredient", label=here.name));
    }

    can region with Region entry {
        if self.region_key and here.key != self.region_key {
            skip;
        }
        visit [here<-:PART_OF:<-];
    }

    can tradition with CulinaryTradition entry {
        if self.tradition_key and here.key != self.tradition_key {
            skip;
        }
        visit [here<-:BELONGS_TO:<-];
    }

    can recipe with Recipe entry {
        recipe = recipe_view(here);
        if not recipe.requirements {
            skip;
        }
        available: list[RequirementView] = [];
        missing: list[RequirementView] = [];
        optional: list[RequirementView] = [];
        substitutions: list[SubstitutionView] = [];
        total: int = 0;
        ready: int = 0;
        for item in recipe.requirements {
            if item.essential {
                total += 1;
            }
            if item.name in self.names {
                available.append(item);
                if item.essential {
                    ready += 1;
                }
            } else {
                if item.essential {
                    missing.append(item);
                } else {
                    optional.append(item);
                }
                for alternative in item.substitutes {
                    if alternative in self.names {
                        substitutions.append(
                            SubstitutionView(
                                required=item.name,
                                alternative=alternative,
                                note="Possible swap only; confirm suitability. Texture and cooking time may change."
                            )
                        );
                    }
                }
            }
        }
        score = (ready * 100) // total if total else 100;
        explanation = f"{ready} of {total} essential ingredient types available; {len(
            missing
        )} essential and {len(optional)} optional missing. Quantities not checked.";
        self.matches.append(
            MatchView(
                recipe=recipe,
                score=score,
                essential_available=ready,
                essential_total=total,
                available=available,
                missing_essential=missing,
                missing_optional=optional,
                substitutions=substitutions,
                explanation=explanation
            )
        );
        self.events.append(
            TraversalEvent(kind="candidate", label=recipe.name + ": " + explanation)
        );
    }

    can finish with CulinaryCatalogue exit {
        self.matches.sort(
            key=lambda (candidate: MatchView) { (
                len(candidate.missing_essential),
                -candidate.score,
                candidate.recipe.minutes,
                candidate.recipe.key
            ); }
        );
        report self.matches;
    }
}
