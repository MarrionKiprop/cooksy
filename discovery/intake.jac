"""Natural language yields proposals; only explicit confirmation changes the pantry."""
import ai.provider as provider;
import from pantry.normalisation { normalise_name, split_names }
import from .views { IntakeReview }

def review_text(text: str) -> IntakeReview {
    if not text.strip() or len(text) > 8000 {
        raise ValueError("Enter 1–8000 characters.");
    }
    tokens = [
        token.strip()
        for token in split_names(text)
        if token.strip()
    ];
    if len(tokens) > 100 {
        raise ValueError("Use at most 100 ingredient entries.");
    }
    simple = all([bool(normalise_name(token)) for token in tokens]);
    lowered = text.lower();
    if any(
        [
            phrase in lowered
            for phrase in [
                "i have",
                "i've",
                "ive got",
                "we have",
                "there is",
                "there are",
                " and "
            ]
        ]
    ) {
        simple = False;
    }
    if simple {
        names = sorted(set([normalise_name(token) for token in tokens]));
        return IntakeReview(
            names=names,
            uncertain=[],
            status="review",
            message="Review these names before saving. Quantities are not tracked yet."
        );
    }
    if not provider.enabled() {
        return IntakeReview(
            names=[],
            uncertain=[],
            status="unavailable",
            message="Language interpretation is unavailable. Try a comma-separated list of ingredient names; your saved pantry is unchanged."
        );
    }
    try {
        extraction = provider.extract_ingredients(text);
        if len(extraction.names) > 100 or len(extraction.uncertain) > 20 {
            raise ValueError("Too many extracted items");
        }
        extracted_names: set[str] = set();
        for raw in extraction.names {
            name = normalise_name(raw);
            if not name {
                raise ValueError("Invalid extracted name");
            }
            extracted_names.add(name);
        }
        if any([len(item) > 200 for item in extraction.uncertain]) {
            raise ValueError("Invalid ambiguity note");
        }
        return IntakeReview(
            names=sorted(extracted_names),
            uncertain=extraction.uncertain,
            status="review",
            message="AI interpreted your text. Correct any mistakes and confirm; nothing has been saved. Quantities are not tracked yet."
        );
    } except Exception {
        return IntakeReview(
            names=[],
            uncertain=[],
            status="unavailable",
            message="We could not validate the interpretation. Your pantry is unchanged. Try again or use comma-separated names."
        );
    }
}
