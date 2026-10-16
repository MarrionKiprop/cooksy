import from graph.views { RecipeView, RequirementView, TraversalEvent }

obj IntakeResult {
    has names: list[str],
        rejected: list[str],
        ignored_suggestions: int;
}

obj SubstitutionView {
    has required: str,
        alternative: str,
        note: str;
}

obj MatchView {
    has recipe: RecipeView,
        score: int,
        essential_available: int,
        essential_total: int,
        available: list[RequirementView],
        missing_essential: list[RequirementView],
        missing_optional: list[RequirementView],
        substitutions: list[SubstitutionView],
        explanation: str;
}

obj PantryMatches {
    has intake: IntakeResult,
        matches: list[MatchView],
        events: list[TraversalEvent];

    has score_basis: str = "Direct essential ingredient coverage; quantities are not checked. Substitutions need confirmation and do not count as available.";
}
