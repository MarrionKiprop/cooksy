obj PredictionView {
    has label: str,
        ingredient: str,
        confidence: float;
}

obj PhotoReview {
    has status: str,
        model: str,
        message: str,
        predictions: list[PredictionView],
        receipt: str;

    has requires_user_confirmation: bool = True;
}

obj PhotoCommit {
    has names: list[str],
        message: str,
        events: list[str];
}
