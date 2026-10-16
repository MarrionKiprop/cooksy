"""Public, process-lifetime culinary memory; never stores pantry or questions."""
import from graph.models { CulinaryCatalogue, Ingredient, Recipe }
node RecipeCandidate {
    has key: str,
        name: str,
        description: str,
        region: str,
        tradition: str,
        minutes: int,
        provenance: str;

    has verification: str = "AI-generated candidate / needs verification";
}

edge HAS_CANDIDATE: CulinaryCatalogue --> RecipeCandidate {}
edge CANDIDATE_REQUIRES: RecipeCandidate --> Ingredient {
    has essential: bool;
}

edge RESOLVES_TO: RecipeCandidate --> Recipe {}
