"""M5 workflow contracts. All model calls use real byllm parsing with MockLLM."""
import from unittest.mock { patch }
import from jaclang.byllm.lib { MockLLM }
import ai.provider as provider;
import discovery.service as service;
import ai.memory as store;
import from discovery.intake { review_text }
import from discovery.taxonomy {
    navigation,
    build_taxonomy,
    REGION_DATA,
    validate_scope,
    in_scope
}
import from discovery.service { plan, restore }
import from discovery.views { IngredientExtraction }
import from discovery.selection { choose_five }
import from ai.views {
    CandidateBatch,
    CandidateProposal,
    IngredientProposal,
    CandidateView
}
import from ai.memory { insert_candidate }
import from ai.models { HAS_CANDIDATE, RESOLVES_TO }
import from graph.models {
    CulinaryCatalogue,
    IN_REGION,
    CATALOGUE_TRADITION,
    CATALOGUE_RECIPE
}

def dish(
    index: int, region: str = "West Africa", tradition: str = "Nigerian"
) -> CandidateProposal {
    return CandidateProposal(
        name="Contract dish " + str(index),
        description="Unverified test adaptation.",
        region=region,
        tradition=tradition,
        minutes=10 + index,
        ingredients=[
            IngredientProposal(name="potato", essential=True),
            IngredientProposal(name="onion", essential=False)
        ]
    );
}

test "fifteen navigation regions and their traditions are real graph metadata not recipes" {
    catalogue = build_taxonomy();
    assert len([catalogue->:IN_REGION:->]) == 15;
    assert len([catalogue->:CATALOGUE_TRADITION:->]) == 45;
    assert len([catalogue->:CATALOGUE_RECIPE:->]) == 0;
    metadata = navigation();
    assert len(metadata.regions) == 15 and len(metadata.traditions) == 45;
    for row in REGION_DATA {
        validate_scope("explore", row[0], row[3][0][0]);
        assert in_scope(row[1], row[3][0][1], row[0], row[3][0][0]);
    }
    with testraises(ValueError) {
        validate_scope("explore", "west-africa", "japanese");
    }
    with testraises(ValueError) {
        validate_scope("discover", "west-africa", "");
    }
}

test "natural sentence becomes review proposals without mutating any pantry" {
    model = MockLLM(
        outputs=[
            IngredientExtraction(
                names=["potatoes", "eggs", "spinach", "onions"], uncertain=[]
            )
        ]
    );
    with patch.object(provider, "llm", model), patch.object(
        provider, "enabled", return_value=True
    ) {
        reviewed = review_text("I have potatoes, eggs, spinach and onions.");
        assert reviewed.status == "review";
        assert reviewed.names == ["egg", "onion", "potato", "spinach"];
        assert "nothing has been saved" in reviewed.message;
        assert "I have potatoes" in str(model.sent("messages"));
    }
}

test "simple lists avoid inference while ambiguous and malformed text stays unconfirmed" {
    with patch.object(provider, "extract_ingredients") as call {
        reviewed = review_text("POTATOES; eggs\n carrots");
        assert reviewed.names == ["carrot", "egg", "potato"];
        call.assert_not_called();
    }
    with patch.object(provider, "enabled", return_value=False) {
        reviewed = review_text("I have eggs and spinach");
        assert reviewed.status == "unavailable" and reviewed.names == [];
    }
    with patch.object(provider, "enabled", return_value=True), patch.object(
        provider, "llm", MockLLM(outputs=["not structured output"])
    ) {
        reviewed = review_text("I have eggs and spinach");
        assert reviewed.status == "unavailable" and reviewed.names == [];
    }
}

test "nonseed region produces five candidates and selected full recipes are deferred" {
    cache = CulinaryCatalogue();
    model = MockLLM(
        outputs=[CandidateBatch(candidates=[dish(index) for index in range(5)])]
    );
    with patch.object(service, "memory", cache), patch.object(store, "memory", cache), patch.object(
        provider, "enabled", return_value=True
    ), patch.object(provider, "llm", model) {
        result = plan(["potato"], "explore", "west-africa", "nigerian", False);
        assert result.ready and len(result.choices) == 5 and not result.demo;
        assert all([choice.readiness == "Cook now" for choice in result.choices]);
        assert result.choices[0].available == ["potato"];
        assert result.choices[0].optional == ["onion"];
        for candidate in [cache->:HAS_CANDIDATE:->] {
            assert not [candidate->:RESOLVES_TO:->];
        }
        assert "West Africa" in str(model.sent("messages"));
        assert "Nigerian" in str(model.sent("messages"));
        with patch.object(provider, "propose_options") as call {
            reused = plan(["potato"], "explore", "west-africa", "nigerian", False);
            assert reused.ready;
            call.assert_not_called();
        }
        keys = [choice.candidate.key for choice in result.choices];
        with patch.object(provider, "propose_options") as call {
            restored = restore(
                ["potato"], keys, "explore", "west-africa", "nigerian", False
            );
            assert [choice.candidate.key for choice in restored.choices] == keys;
            call.assert_not_called();
        }
    }
}

test "one bounded repair fills rejected duplicate and out of scope output" {
    cache = CulinaryCatalogue();
    invalid = dish(9);
    invalid.minutes = -3;
    foreign = dish(8, "East Asia", "Japanese");
    initial = CandidateBatch(candidates=[dish(0), dish(1), dish(1), foreign, invalid]);
    repair = CandidateBatch(candidates=[dish(2), dish(3), dish(4)]);
    model = MockLLM(outputs=[initial, repair]);
    with patch.object(service, "memory", cache), patch.object(
        provider, "enabled", return_value=True
    ), patch.object(provider, "llm", model) {
        result = plan(["potato"], "explore", "west-africa", "", False);
        assert result.ready and len(result.choices) == 5;
        assert len(model.seen) == 2;
        assert len([cache->:HAS_CANDIDATE:->]) == 5;
    }
}

test "shortfall never fabricates five or silently selects developer fixtures" {
    cache = CulinaryCatalogue();
    model = MockLLM(
        outputs=[
            CandidateBatch(candidates=[dish(0)]),
            CandidateBatch(candidates=[dish(0)])
        ]
    );
    with patch.object(service, "memory", cache), patch.object(
        provider, "enabled", return_value=True
    ), patch.object(provider, "llm", model) {
        result = plan(["potato"], "explore", "west-africa", "", False);
        assert not result.ready and len(result.choices) == 1;
        assert len(model.seen) == 2 and "1 of 5" in result.message;
    }
    with patch.object(service, "memory", CulinaryCatalogue()), patch.object(
        provider, "enabled", return_value=False
    ) {
        result = plan(["potato"], "discover", "", "", False);
        assert not result.ready and result.choices == [] and not result.demo;
    }
}

test "explicit demo fallback is labelled restores five and makes no model call" {
    with patch.object(service, "memory", CulinaryCatalogue()), patch.object(
        provider, "propose_options"
    ) as call {
        result = plan(["potato"], "discover", "", "", True);
        assert result.ready and result.demo and "DEMO" in result.message;
        keys = [choice.candidate.key for choice in result.choices];
        restored = restore(["potato"], keys, "discover", "", "", True);
        assert restored.ready
            and [choice.candidate.key for choice in restored.choices] == keys;
        call.assert_not_called();
    }
}

test "worldwide choices prefer several regions without overriding readiness" {
    cache = CulinaryCatalogue();
    traditions = [
        ("East Africa", "Kenyan"),
        ("East Asia", "Japanese"),
        ("Mediterranean", "Greek"),
        ("Latin America", "Mexican"),
        ("South Asia", "Indian")
    ];
    for index in range(5) {
        insert_candidate(
            cache,
            dish(index, traditions[index][0], traditions[index][1]),
            "Mock / unverified"
        );
    }
    with patch.object(service, "memory", cache), patch.object(
        provider, "propose_options"
    ) as call {
        result = plan(["potato"], "discover", "", "", False);
        assert result.ready;
        assert len(set([choice.candidate.region for choice in result.choices])) == 5;
        call.assert_not_called();
    }
    choices: list[CandidateView] = [];
    for index in range(6) {
        choices.append(
            CandidateView(
                key=str(index),
                name="Rank dish " + str(index),
                description="mock",
                region="West Africa" if index < 5 else "East Asia",
                tradition="Nigerian" if index < 5 else "Japanese",
                minutes=20,
                score=100 if index < 5 else 0,
                missing=[] if index < 5 else ["potato"],
                provenance="Mock",
                verification="Unverified",
                prepared=False
            )
        );
    }
    assert all([item.score == 100 for item in choose_five(choices, True)]);
}

test "restore rejects expired duplicate and wrong scope candidate keys without inference" {
    with patch.object(service, "memory", CulinaryCatalogue()), patch.object(
        provider, "propose_options"
    ) as call {
        with testraises(ValueError) {
            restore(["potato"], ["a", "b", "c", "d", "e"], "discover", "", "", False);
        }
        with testraises(ValueError) {
            restore(["potato"], ["a", "a", "a", "a", "a"], "discover", "", "", False);
        }
        with testraises(ValueError) {
            plan([], "discover", "", "", False);
        }
        call.assert_not_called();
    }
}


test "demo choices cannot be replaced by cached AI candidates" {
    cache = CulinaryCatalogue();
    for index in range(5) {
        insert_candidate(cache, dish(index), "Mock AI cache");
    }
    with patch.object(service, "memory", cache), patch.object(
        provider, "propose_options"
    ) as call {
        result = plan(["potato"], "discover", "", "", True);
        assert result.ready
            and all(
                [choice.candidate.key.endswith("-demo") for choice in result.choices]
            );
        with testraises(ValueError) {
            restore(
                ["potato"],
                [candidate.key for candidate in [cache->:HAS_CANDIDATE:->]],
                "discover",
                "",
                "",
                True
            );
        }
        call.assert_not_called();
    }
}
