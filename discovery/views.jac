"""Contracts for the shared pantry and one five-choice decision screen."""
import from ai.views { CandidateView }
import from graph.views { RegionView, TraditionView }

obj IngredientExtraction {
    has names: list[str],
        uncertain: list[str];
}

sem IngredientExtraction.names = "Explicitly mentioned edible ingredients only, lowercase singular names where unambiguous; preserve preparation state. No inferred staples or quantities.";
sem IngredientExtraction.uncertain = "Ambiguous phrases requiring the user's clarification; never silently guess them.";

obj IntakeReview {
    has names: list[str],
        uncertain: list[str],
        status: str,
        message: str;
}

obj NavigationCatalogue {
    has regions: list[RegionView],
        traditions: list[TraditionView];
}

obj MealChoice {
    has candidate: CandidateView,
        available: list[str],
        optional: list[str],
        readiness: str;
}

obj MealPlan {
    has choices: list[MealChoice],
        ready: bool,
        status: str,
        message: str,
        mode: str,
        region_key: str,
        tradition_key: str,
        demo: bool,
        events: list[str];
}
