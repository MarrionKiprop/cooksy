"""Bounded culinary proposals and assistance wire contracts."""
obj IngredientProposal {
    has name: str,
        essential: bool;
}

obj CandidateProposal {
    has name: str,
        description: str,
        region: str,
        tradition: str,
        minutes: int,
        ingredients: list[IngredientProposal];
}

obj CandidateBatch {
    has candidates: list[CandidateProposal];
}

obj QuantityProposal {
    has name: str,
        quantity: float,
        unit: str;
}

obj PreparedRecipe {
    has servings: int,
        quantities: list[QuantityProposal],
        steps: list[str];
}

obj HelpProposal {
    has quotes: list[str];
}

obj CandidateView {
    has key: str,
        name: str,
        description: str,
        region: str,
        tradition: str,
        minutes: int,
        score: int,
        missing: list[str],
        provenance: str,
        verification: str,
        prepared: bool;
}

obj EnrichmentResult {
    has candidates: list[CandidateView],
        status: str,
        message: str,
        events: list[str];
}

obj PreparationResult {
    has key: str,
        ready: bool,
        message: str;
}

obj AssistanceResult {
    has quotes: list[str],
        status: str,
        message: str,
        recipe_key: str,
        sequence: int;
}

sem IngredientProposal.name = "Lowercase simple ingredient name, no quantity.";
sem IngredientProposal.essential = "Whether required rather than optional.";
sem CandidateProposal.name = "Established local dish name where appropriate; adaptations labelled explicitly.";
sem CandidateProposal.description = "Brief description with adaptation uncertainty, no private user text.";
sem CandidateProposal.region = "Geographical culinary region.";
sem CandidateProposal.tradition = "Culinary tradition, not a claim of verified authenticity.";
sem CandidateProposal.minutes = "Estimated total minutes between 1 and 240.";
sem CandidateProposal.ingredients = "Between 1 and 16 distinct simple ingredient names with essential flags.";
sem CandidateBatch.candidates = "At most five distinct culinary proposals.";
sem QuantityProposal.name = "Exact ingredient name from selected candidate.";
sem QuantityProposal.quantity = "Positive finite quantity no greater than 10000.";
sem QuantityProposal.unit = "Short unit such as g, ml, tsp, tbsp, or piece.";
sem PreparedRecipe.servings = "Portions between 1 and 12.";
sem PreparedRecipe.quantities = "Exactly one positive quantity per candidate ingredient, no new names.";
sem PreparedRecipe.steps = "Two to twelve ordered instructions, each under 800 characters.";
sem HelpProposal.quotes = "Zero to three verbatim quotations only from the current instruction.";
