import from unittest.mock { patch }
import from jaclang.byllm.lib { MockLLM }
import ai.provider as provider;
import from ai.views {
    CandidateBatch,
    CandidateProposal,
    IngredientProposal,
    PreparedRecipe,
    QuantityProposal,
    HelpProposal
}
import from ai.memory {
    valid_candidate,
    insert_candidate,
    resolve_candidate,
    candidate_view
}
import from ai.models { HAS_CANDIDATE, CANDIDATE_REQUIRES, RESOLVES_TO }
import from ai.service { prepare_selected, assist }
import from graph.models { CulinaryCatalogue, REQUIRES, HAS_STEP }
import from graph.seed { build_demo_graph }
import from walkers.enrichment { EnrichmentWalker }

def proposal() -> CandidateProposal {
    return CandidateProposal(
        name="Tomato rice adaptation",
        description="A simple Italian-inspired adaptation.",
        region="Southern Europe",
        tradition="Italian",
        minutes=25,
        ingredients=[
            IngredientProposal(name="rice", essential=True),
            IngredientProposal(name="tomato", essential=True)
        ]
    );
}

test "graph coverage skips model and deterministically ranks" {
    cache = CulinaryCatalogue();
    with patch.object(provider, "propose") as call {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache, pantry=["potato", "cooking oil"], cuisine=""
        );
        result = found.reports[0];
        assert result.status == "graph" and len(result.candidates) == 5;
        assert result.candidates[0].key == "gamja-jeon-demo";
        call.assert_not_called();
    }
}

test "real byllm mock accepts proposals rejects duplicates and builds edges" {
    cache = CulinaryCatalogue();
    model = MockLLM(outputs=[CandidateBatch(candidates=[proposal(), proposal()])]);
    with patch.object(provider, "llm", model), patch.object(
        provider, "enabled", return_value=True
    ) {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache, pantry=["tomato"], cuisine="Italian"
        );
        result = found.reports[0];
        assert result.status == "enriched" and len(result.candidates) == 1;
        assert result.candidates[0].score == 50;
        assert result.candidates[0].missing == ["rice"];
        assert "needs verification" in result.candidates[0].verification;
        assert len([cache->:HAS_CANDIDATE:->]) == 1;
        candidate = [cache->:HAS_CANDIDATE:->][0];
        assert len([candidate->:CANDIDATE_REQUIRES:->]) == 2;
        assert not [candidate->:RESOLVES_TO:->];
        assert "Italian" in str(model.sent("messages"));
    }
}

test "malformed and unavailable preserve existing graph and cache" {
    cache = CulinaryCatalogue();
    with patch.object(provider, "llm", MockLLM(outputs=["not json"])), patch.object(
        provider, "enabled", return_value=True
    ) {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache, pantry=[], cuisine="Italian"
        );
        assert found.reports[0].status == "unavailable";
        assert not [cache->:HAS_CANDIDATE:->];
    }
    with patch.object(provider, "enabled", return_value=False), patch.object(
        provider, "propose"
    ) as call {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache, pantry=[], cuisine="Korean"
        );
        assert found.reports[0].status == "unavailable";
        assert len(found.reports[0].candidates) == 1;
        call.assert_not_called();
    }
}

test "semantic validation rejects invalid fields and ingredient duplication" {
    draft = proposal();
    assert valid_candidate(draft);
    draft.minutes = -1;
    assert not valid_candidate(draft);
    draft.minutes = 20;
    draft.ingredients.append(IngredientProposal(name="Tomatoes", essential=True));
    assert not valid_candidate(draft);
}

test "full recipe only on selection exact ingredients then graph reuse" {
    cache = CulinaryCatalogue();
    candidate = insert_candidate(cache, proposal(), "test mock / unverified");
    draft = PreparedRecipe(
        servings=2,
        quantities=[
            QuantityProposal(name="rice", quantity=100.0, unit="g"),
            QuantityProposal(name="tomato", quantity=200.0, unit="g")
        ],
        steps=[
            "Rinse rice and chop tomato.",
            "Simmer rice and tomato in their juices until tender."
        ]
    );
    with patch.object(provider, "llm", MockLLM(outputs=[draft])), patch.object(
        provider, "enabled", return_value=True
    ) {
        response = prepare_selected(cache, candidate.key);
        assert response.ready;
        recipe = [candidate->:RESOLVES_TO:->][0];
        assert len([recipe->:REQUIRES:->]) == 2 and len([recipe->:HAS_STEP:->]) == 2;
        with patch.object(provider, "prepare") as call {
            assert prepare_selected(cache, candidate.key).ready;
            call.assert_not_called();
        }
    }
    other = insert_candidate(cache, proposal(), "test mock");
    draft.quantities[0].name = "unknown";
    with testraises(ValueError) {
        resolve_candidate(other, draft);
    }
    assert not [other->:RESOLVES_TO:->];
}

test "help rejects hallucinations wrong step and out of bounds" {
    catalogue = build_demo_graph();
    with patch.object(
        provider,
        "llm",
        MockLLM(outputs=[HelpProposal(quotes=["Invented timing 600 degrees"])])
    ), patch.object(provider, "enabled", return_value=True) {
        answer = assist(
            catalogue, "gamja-jeon-demo", 1, False, catalogue.version, "How long?"
        );
        assert answer.status == "unavailable" and answer.quotes == [];
    }
    with patch.object(provider, "llm", MockLLM(outputs=[HelpProposal(quotes=[])])), patch.object(
        provider, "enabled", return_value=True
    ) {
        answer = assist(
            catalogue,
            "gamja-jeon-demo",
            1,
            False,
            catalogue.version,
            "Explain quantum mechanics"
        );
        assert answer.status == "insufficient_context";
    }
    with testraises(ValueError) {
        assist(catalogue, "gamja-jeon-demo", 99, False, catalogue.version, "Help");
    }
    with testraises(ValueError) {
        assist(catalogue, "unknown", 1, False, catalogue.version, "Help");
    }
}


test "grounded help returns exact current quotations and never changes progress" {
    catalogue = build_demo_graph();
    model = MockLLM(outputs=[HelpProposal(quotes=["Grate the potato"])]);
    with patch.object(provider, "llm", model), patch.object(
        provider, "enabled", return_value=True
    ) {
        response = assist(
            catalogue,
            "gamja-jeon-demo",
            1,
            False,
            catalogue.version,
            "What do I grate?"
        );
        assert response.status == "grounded";
        assert response.quotes == ["Grate the potato"];
        assert response.sequence == 1;
        sent = str(model.sent("messages"));
        assert "Grate the potato and drain excess water." in sent;
        assert "Form a thin pancake" not in sent;
    }
}

test "five cached candidates reuse graph without any model call" {
    cache = CulinaryCatalogue();
    for index in range(5) {
        draft = proposal();
        draft.name = "Tomato rice " + str(index);
        insert_candidate(cache, draft, "Mock / unverified");
    }
    with patch.object(provider, "propose") as call {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache, pantry=["rice"], cuisine="Italian"
        );
        assert found.reports[0].status == "graph";
        assert len(found.reports[0].candidates) == 5;
        call.assert_not_called();
    }
}


test "measured cooking water cannot appear silently in selected instructions" {
    cache = CulinaryCatalogue();
    candidate = insert_candidate(cache, proposal(), "Mock / unverified");
    draft = PreparedRecipe(
        servings=2,
        quantities=[
            QuantityProposal(name="rice", quantity=100.0, unit="g"),
            QuantityProposal(name="tomato", quantity=200.0, unit="g")
        ],
        steps=[
            "Rinse rice and chop tomato.",
            "Add 400 ml of water and simmer until tender."
        ]
    );
    with testraises(ValueError) {
        resolve_candidate(candidate, draft);
    }
    assert not [candidate->:RESOLVES_TO:->];
}


test "generated recipe content versions survive projection and reject stale progress" {
    import ai.memory as store;
    import from endpoints { cook_session }
    cache = CulinaryCatalogue();
    candidate = insert_candidate(cache, proposal(), "Mock / unverified");
    draft = PreparedRecipe(
        servings=2,
        quantities=[
            QuantityProposal(name="rice", quantity=100.0, unit="g"),
            QuantityProposal(name="tomato", quantity=200.0, unit="g")
        ],
        steps=[
            "Rinse rice and chop tomato.",
            "Cook gently in tomato juices until tender."
        ]
    );
    recipe = resolve_candidate(candidate, draft);
    assert recipe.version != "cooksy-demo-v1";
    with patch.object(store, "memory", cache) {
        state = cook_session(recipe.key, 1, False, "start", recipe.version);
        assert state.version == recipe.version;
        with testraises(ValueError) {
            cook_session(recipe.key, 1, False, "resume", "cooksy-demo-v1");
        }
    }
    second = insert_candidate(CulinaryCatalogue(), proposal(), "Mock / unverified");
    draft.steps[1] = "Cook slowly in tomato juices until tender.";
    assert resolve_candidate(second, draft).version != recipe.version;
}


test "pantry discovery requires covered essentials rather than five unrelated cached dishes" {
    cache = CulinaryCatalogue();
    with patch.object(provider, "enabled", return_value=True), patch.object(
        provider, "propose", return_value=CandidateBatch(candidates=[])
    ) as call {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache, pantry=["banana"], cuisine="", coverage_score=100
        );
        assert found.reports[0].status == "no_new_candidates";
        assert len(found.reports[0].candidates) == 5;
        call.assert_called_once();
    }
    for index in range(5) {
        draft = proposal();
        draft.name = "Rice adaptation " + str(index);
        insert_candidate(cache, draft, "Mock / unverified");
    }
    with patch.object(provider, "propose") as call {
        found = build_demo_graph() spawn EnrichmentWalker(
            cache=cache,
            pantry=["rice", "tomato"],
            cuisine="Italian",
            coverage_score=100
        );
        assert found.reports[0].status == "graph";
        call.assert_not_called();
    }
}
