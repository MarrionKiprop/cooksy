"""Select an existing graph recipe before any cooking or later model enrichment."""
import from graph.models {
    CulinaryCatalogue,
    Region,
    CulinaryTradition,
    Recipe,
    IN_REGION,
    PART_OF,
    BELONGS_TO
}
import from graph.projections { recipe_view }
import from graph.views { RecipeView }

walker RecipeWalker {
    has recipe_key: str;
    has selected_node: Recipe | None = None,
        details: RecipeView | None = None,
        reports: list[RecipeView | None] = [];

    can begin with CulinaryCatalogue entry {
        visit [here->:IN_REGION:->];
    }

    can region with Region entry {
        visit [here<-:PART_OF:<-];
    }

    can tradition with CulinaryTradition entry {
        visit [here<-:BELONGS_TO:<-];
    }

    can recipe with Recipe entry {
        if here.key == self.recipe_key {
            self.selected_node = here;
            self.details = recipe_view(here);
        }
    }

    can finish with CulinaryCatalogue exit {
        report self.details;
    }
}
