"""Confirmed inputs become pantry relationships through real node encounters."""
import from graph.models {
    Pantry,
    IntakeItem,
    Ingredient,
    CulinaryCatalogue,
    PENDING_ITEM,
    HAS_INGREDIENT,
    CATALOGUE_RECIPE,
    REQUIRES
}
import from pantry.normalisation { normalise_name }
import from pantry.views { IntakeResult }

walker IntakeWalker {
    has pantry: Pantry,
        catalogue: CulinaryCatalogue;

    has names: list[str] = [],
        rejected: list[str] = [],
        ignored_suggestions: int = 0,
        reports: list[IntakeResult] = [];

    can begin with Pantry entry {
        self.names = [item.name for item in [here->:HAS_INGREDIENT:->]];
        visit [here->:PENDING_ITEM:->];
    }

    can consume with IntakeItem entry {
        if here.source not in ["manual", "vision"] {
            self.rejected.append(here.name);
            skip;
        }
        if not here.confirmed {
            self.ignored_suggestions += 1;
            skip;
        }
        name = normalise_name(here.name);
        if not name {
            if here.name.strip() {
                self.rejected.append(here.name);
            }
            skip;
        }
        if name in self.names {
            skip;
        }
        # Reuse a catalogue ingredient where one exists. Unknown names remain valid pantry items.
        item = Ingredient(name=name);
        for existing in [self.catalogue->:CATALOGUE_RECIPE:->->:REQUIRES:->] {
            if existing.name == name {
                item = existing;
                break;
            }
        }
        self.pantry +>:HAS_INGREDIENT():+> item;
        self.names.append(name);
    }

    can finish with Pantry exit {
        self.names.sort();
        report IntakeResult(
            names=self.names,
            rejected=self.rejected,
            ignored_suggestions=self.ignored_suggestions
        );
    }
}
