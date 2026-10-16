"""Culinary topology. Requirements and ordering live on relationships."""
node CulinaryCatalogue {
    has version: str = "cooksy-demo-v1";
}

node Region {
    has key: str,
        name: str,
        subtitle: str,
        motif: str,
        tone: str;
}

node CulinaryTradition {
    has key: str,
        name: str;
}

node Ingredient {
    has name: str;
}

node Recipe {
    has key: str,
        name: str,
        description: str,
        minutes: int,
        servings: int;

    has provenance: str = "Cooksy developer demo fixture",
        verification: str = "Illustrative adaptation; not a verified recipe";
}

node RecipeStep {
    has instruction: str;
}

edge CATALOGUE_TRADITION: CulinaryCatalogue --> CulinaryTradition {}
edge CATALOGUE_RECIPE: CulinaryCatalogue --> Recipe {}
edge IN_REGION: CulinaryCatalogue --> Region {}
edge PART_OF: CulinaryTradition --> Region {}
edge BELONGS_TO: Recipe --> CulinaryTradition {}
edge REQUIRES: Recipe --> Ingredient {
    has quantity: float,
        unit: str;

    has essential: bool = True,
        preparation: str = "",
        substitution_notes: str = "",
        substitutes: list[str] = [];
}

edge HAS_STEP: Recipe --> RecipeStep {
    has sequence: int;
}

node Pantry {
    has scope: str = "browser-tab request";
}

node IntakeItem {
    has name: str;
    has source: str = "manual",
        confirmed: bool = True;
}

edge PENDING_ITEM: Pantry --> IntakeItem {}
edge HAS_INGREDIENT: Pantry --> Ingredient {
    has quantity: float | None = None,
        unit: str = "",
        notes: str = "Quantity not supplied";
}
