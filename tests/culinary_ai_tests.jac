import from unittest.mock { patch }
import from jaclang.byllm.lib { MockLLM }
import ai.provider as provider;
import nutrition.service as nutrition;
import from nutrition.views { EstimatedFood, NutritionProposal }
import from graph.models { Recipe, Ingredient, REQUIRES, CulinaryCatalogue }
import from nutrition.models { HAS_NUTRITION, NUTRITION_ITEM, USES_REFERENCE }
import from discovery.taxonomy { build_taxonomy }
import from walkers.enrichment { EnrichmentWalker }
import from ai.views { CandidateBatch, CandidateProposal, IngredientProposal }


test "regional proposal uses local dish names and sends traditional recognition instructions" {
    batch = CandidateBatch(
        candidates=[
            CandidateProposal(
                name="Githeri",
                description="A Kenyan maize and bean preparation.",
                region="East Africa",
                tradition="Kenyan",
                minutes=60,
                ingredients=[
                    IngredientProposal(name="maize", essential=True),
                    IngredientProposal(name="bean", essential=True),
                    IngredientProposal(name="water", essential=True)
                ]
            )
        ]
    );
    mock = MockLLM(outputs=[batch]);
    with patch.object(provider, "llm", mock), patch.object(
        provider, "enabled", return_value=True
    ) {
        walk = build_taxonomy() spawn EnrichmentWalker(
            cache=CulinaryCatalogue(),
            pantry=["maize", "bean", "water"],
            cuisine="",
            scoped=True,
            region_key="east-africa",
            tradition_key="kenyan",
            coverage_score=100
        );
        assert walk.result is not None;
        assert walk.result.candidates[0].name == "Githeri";
        assert walk.result.candidates[0].score == 100;
        sent = str(mock.sent("messages"));
        assert "local names" in sent and "githeri" in sent and "maize" in sent;
    }
}

test "AI nutrition preserves known reference values and derives totals in Jac" {
    recipe = Recipe(
        key="regional-nutrition",
        name="Test meal",
        description="Test",
        minutes=10,
        servings=2
    );
    recipe +>:REQUIRES(quantity=100.0, unit="g"):+> Ingredient(name="potato");
    recipe +>:REQUIRES(quantity=1.0, unit="cup"):+> Ingredient(name="milk");
    estimates = [
        EstimatedFood(
            name="potato",
            grams=9999.0,
            values=[900.0, 1.0, 1.0, 99.0, 0.0, 0.0],
            assumptions="Ignored known values."
        ),
        EstimatedFood(
            name="milk",
            grams=200.0,
            values=[100.0, 4.0, 10.0, 4.0, None, 40.0],
            assumptions="Assume one cup is approximately 200 g; generic milk composition."
        )
    ];
    result = (
        recipe spawn nutrition.NutritionWalker(
            reference=nutrition.references(), estimates=estimates
        )
    ).result;
    assert result is not None and result.status == "ai_partial";
    assert result.values[0].total == 277.0 and result.values[0].per_serving == 138.5;
    assert result.values[4].total is None;
    assert "AI" in result.disclosure;
    milk = [
        row
        for row in result.items
        if row.name == "milk"
    ][0];
    assert milk.grams == 200.0
        and milk.source_url == ""
        and "AI assumptions" in milk.reason;
    assert len([recipe->:HAS_NUTRITION:->->:NUTRITION_ITEM:->->:USES_REFERENCE:->])
        == 2;
}

test "AI nutrient schema rejects invented identities duplicates nonfinite and impossible values" {
    for item in [
        EstimatedFood(
            name="other", grams=10.0, values=[1.0 for _ in range(6)], assumptions="Test"
        ),
        EstimatedFood(
            name="oil",
            grams=float("nan"),
            values=[1.0 for _ in range(6)],
            assumptions="Test"
        ),
        EstimatedFood(
            name="oil",
            grams=10.0,
            values=[float("inf"), 0.0, 0.0, 0.0, 0.0, 0.0],
            assumptions="Test"
        ),
        EstimatedFood(
            name="oil",
            grams=10.0,
            values=[900.0, 90.0, 90.0, 90.0, 0.0, 0.0],
            assumptions="Test"
        )
    ] {
        with testraises(ValueError) {
            nutrition.validate_estimates(NutritionProposal(items=[item]), ["oil"]);
        }
    }
}

test "AI nutrition call is explicit cached and recipe scoped with real byllm parsing" {
    proposal = NutritionProposal(
        items=[
            EstimatedFood(
                name="cooking oil",
                grams=13.5,
                values=[900.0, 0.0, 0.0, 100.0, 0.0, 0.0],
                assumptions="Assume generic oil density 0.9 g/ml, not olive oil."
            )
        ]
    );
    mock = MockLLM(outputs=[proposal]);
    with patch.dict(nutrition.ai_cache, {}, clear=True), patch.object(
        provider, "llm", mock
    ), patch.object(provider, "enabled", return_value=True) {
        baseline = nutrition.nutrition_for("gamja-jeon-demo", "cooksy-demo-v1");
        assert baseline.status == "partial";
        assert len(mock.sent("messages")) == 0;
        result = nutrition.estimate_for("gamja-jeon-demo", "cooksy-demo-v1");
        assert result.status == "ai_estimate";
        assert result.values[0].total == 352.5;
        assert nutrition.estimate_for("gamja-jeon-demo", "cooksy-demo-v1").status
            == "ai_estimate";
        assert nutrition.nutrition_for("gamja-jeon-demo", "cooksy-demo-v1").status
            == "ai_estimate";
        assert len(mock.sent("messages")) == 1;
        with testraises(ValueError) {
            nutrition.estimate_for("gamja-jeon-demo", "stale");
        }
    }
}

test "disabled nutrition AI makes no call and keeps reference-only nutrition" {
    mock = MockLLM(outputs=[]);
    with patch.dict(nutrition.ai_cache, {}, clear=True), patch.object(
        provider, "llm", mock
    ), patch.object(provider, "enabled", return_value=False) {
        with testraises(ValueError) {
            nutrition.estimate_for("gamja-jeon-demo", "cooksy-demo-v1");
        }
        assert nutrition.nutrition_for("gamja-jeon-demo", "cooksy-demo-v1").status
            == "partial";
        assert len(mock.sent("messages")) == 0 and len(nutrition.ai_cache) == 0;
    }
}
