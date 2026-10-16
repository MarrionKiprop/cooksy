import from graph.models {
    CulinaryCatalogue,
    Region,
    CulinaryTradition,
    Recipe,
    Ingredient,
    IN_REGION,
    PART_OF,
    BELONGS_TO,
    REQUIRES,
    HAS_STEP
}
import from graph.seed { build_demo_graph }
import from walkers.discovery { DiscoveryWalker }
import from endpoints { discover }

test "region tradition recipe ingredient and step traversal" {
    catalogue = build_demo_graph();
    regions = [catalogue->:IN_REGION:->];
    assert len(regions) == 4;
    traditions = [regions<-:PART_OF:<-];
    assert len(traditions) == 8;
    recipes = [traditions<-:BELONGS_TO:<-];
    assert len(recipes) == 8;
    assert len([recipes->:REQUIRES:->]) == 16;
    assert len([recipes->:HAS_STEP:->]) == 16;
    traversal = catalogue spawn DiscoveryWalker();
    assert len(traversal.reports) == 1;
    view = traversal.reports[0];
    assert len(view.recipes) == 8;
    kinds = {event.kind for event in view.events};
    assert kinds
        == {"catalogue", "region", "tradition", "recipe", "ingredient", "step"};
    assert len(
        [
            event
            for event in view.events
            if event.kind == "ingredient"
        ]
    )
        == 16;
    for recipe in view.recipes {
        assert len(recipe.requirements) >= 3;
        assert [step.sequence for step in recipe.steps] == [1, 2];
        assert "demo" in recipe.provenance;
        assert "not a verified recipe" in recipe.verification;
    }
}

test "region and tradition filters traverse only eligible recipes" {
    catalogue = build_demo_graph();
    traversal = catalogue spawn DiscoveryWalker(region_key="east-asia");
    view = traversal.reports[0];
    assert len(view.regions) == 4;
    assert len(view.traditions) == 2;
    assert {recipe.name for recipe in view.recipes} == {"Gamja-jeon", "Tamagoyaki"};
    assert {
        event.label
        for event in view.events
        if event.kind == "region"
    }
        == {"East Asia"};
    filtered = catalogue spawn DiscoveryWalker(
        region_key="east-asia", tradition_key="korean"
    );
    assert len(filtered.reports[0].recipes) == 1;
    assert filtered.reports[0].recipes[0].name == "Gamja-jeon";
    all_regions = catalogue spawn DiscoveryWalker(tradition_key="korean");
    assert len(all_regions.reports[0].recipes) == 1;
    mismatch = catalogue spawn DiscoveryWalker(
        region_key="east-africa", tradition_key="korean"
    );
    assert mismatch.reports[0].recipes == [];
    unknown = catalogue spawn DiscoveryWalker(region_key="unknown");
    assert unknown.reports[0].recipes == [];
    assert unknown.reports[0].traditions == [];
}

test "requirements come from typed edges not copied fixture data" {
    catalogue = build_demo_graph();
    recipes = [catalogue->:IN_REGION:-><-:PART_OF:<-<-:BELONGS_TO:<-];
    recipe = [
        r
        for r in recipes
        if r.key == "gamja-jeon-demo"
    ][0];
    # Editing only relationship data must change the discovery projection.
    for relation in [edge recipe->:REQUIRES:->] {
        if relation.unit == "ml" {
            relation.quantity = 42.0;
        }
    }
    result = catalogue spawn DiscoveryWalker(tradition_key="korean");
    requirements = result.reports[0].recipes[0].requirements;
    assert [
        r.quantity
        for r in requirements
        if r.name == "cooking oil"
    ]
        == [42.0];
    assert [
        r.essential
        for r in requirements
        if r.name == "salt"
    ]
        == [False];
    assert [
        r.preparation
        for r in requirements
        if r.name == "potato"
    ]
        == ["peeled and grated"];
    # Same potato node is required by two different recipes.
    potato = [recipe->:REQUIRES:->][0];
    assert potato.name == "potato";
    assert len([potato<-:REQUIRES:<-]) == 2;
}

test "fixtures and walker collections are isolated across repeat runs" {
    first = build_demo_graph();
    second = build_demo_graph();
    assert jid(first) != jid(second);
    one = first spawn DiscoveryWalker(region_key="east-africa");
    two = first spawn DiscoveryWalker(region_key="east-africa");
    assert len(one.reports[0].recipes) == 2;
    assert len(two.reports[0].recipes) == 2;
    assert len(one.reports[0].events) == len(two.reports[0].events);
    # Function endpoint returns a typed view without requiring persistence or credentials.
    response = discover("east-asia", "japanese");
    assert len(response.recipes) == 1;
    assert response.recipes[0].name == "Tamagoyaki";
    assert response.mode == "demo_graph";
}
