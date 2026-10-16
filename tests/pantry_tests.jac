import from endpoints { match_pantry }
import from graph.seed {
    build_demo_graph,
    add_region,
    add_tradition,
    add_recipe,
    require,
    add_steps
}
import from graph.models {
    CulinaryCatalogue,
    Pantry,
    IntakeItem,
    Ingredient,
    PENDING_ITEM,
    HAS_INGREDIENT,
    CATALOGUE_RECIPE
}
import from walkers.intake { IntakeWalker }
import from walkers.matching { MatchingWalker }
import from pantry.normalisation { normalise_name }

test "normalises explicit aliases and rejects quantities" {
    assert normalise_name("  POTATOES  ") == "potato";
    assert normalise_name("  red   lentils ") == "red lentil";
    assert normalise_name("chickpeas") == "chickpea";
    assert normalise_name("cooked chickpeas") == "cooked chickpea";
    assert normalise_name("2 eggs") == "";
    assert normalise_name("<script>") == "";
    assert normalise_name(" ") == "";
    assert normalise_name("---") == "";
    result = match_pantry(["Potatoes, potato; EGGS\n eggs", "2 onions"]);
    assert result.intake.names == ["egg", "potato"];
    assert result.intake.rejected == ["2 onions"];
}

test "intake deduplicates graph edges and enforces confirmation" {
    catalogue = build_demo_graph();
    pantry = Pantry();
    pantry +>:PENDING_ITEM():+> IntakeItem(name="Potatoes");
    pantry +>:PENDING_ITEM():+> IntakeItem(name="potato");
    pantry +>:PENDING_ITEM():+> IntakeItem(
        name="onion", source="vision", confirmed=False
    );
    pantry +>:PENDING_ITEM():+> IntakeItem(name="egg", source="vision", confirmed=True);
    pantry +>:PENDING_ITEM():+> IntakeItem(name="tomato", source="unknown");
    first = pantry spawn IntakeWalker(pantry=pantry, catalogue=catalogue);
    assert first.names == ["egg", "potato"];
    assert first.ignored_suggestions == 1;
    assert len([pantry->:HAS_INGREDIENT:->]) == 2;
    for relation in [edge pantry->:HAS_INGREDIENT:->] {
        assert relation.quantity is None;
        assert relation.unit == "";
    }
    repeated = pantry spawn IntakeWalker(pantry=pantry, catalogue=catalogue);
    assert repeated.names == ["egg", "potato"];
    assert len([pantry->:HAS_INGREDIENT:->]) == 2;
}

test "direct essential coverage excludes missing optional ingredients" {
    response = match_pantry(["potato, oil"], "east-asia", "korean");
    candidate = response.matches[0];
    assert candidate.score == 100;
    assert candidate.essential_available == 2 and candidate.essential_total == 2;
    assert candidate.missing_essential == [];
    assert [item.name for item in candidate.missing_optional] == ["salt"];
    assert len(candidate.available) == 2;
    assert "Quantities not checked" in candidate.explanation;
    no_staples = match_pantry(["potato"], "east-asia", "korean").matches[0];
    assert no_staples.score == 50;
    assert [item.name for item in no_staples.missing_essential] == ["cooking oil"];
}

test "substitution suggestions never silently count as available" {
    response = match_pantry(["spinach, onion, tomato, oil"], "east-africa", "kenyan");
    candidate = response.matches[0];
    assert candidate.score == 75;
    assert [item.name for item in candidate.missing_essential] == ["kale"];
    assert len(candidate.substitutions) == 1;
    assert candidate.substitutions[0].required == "kale";
    assert candidate.substitutions[0].alternative == "spinach";
    assert "confirm" in candidate.substitutions[0].note;
}

test "ranking is deterministic and filters preserve pantry" {
    first = match_pantry(["eggs, oil"]);
    second = match_pantry(["oil", "EGGS", "eggs"]);
    assert [item.recipe.key for item in first.matches]
        == [item.recipe.key for item in second.matches];
    assert first.matches[0].recipe.name == "Tamagoyaki";
    assert first.matches[0].score == 100;
    empty = match_pantry([]);
    assert len(empty.matches) == 8;
    assert all([item.score == 0 for item in empty.matches]);
    unknown = match_pantry(["egg"], "unknown");
    assert unknown.matches == [];
    assert unknown.intake.names == ["egg"];
}

test "ties use time then recipe key and optional only recipes are defined" {
    catalogue = CulinaryCatalogue();
    region = add_region(catalogue, "test", "Test", "Fixture", "", "sage");
    tradition = add_tradition(region, "test", "Test");
    ingredient = Ingredient(name="salt");
    for key in ["z", "b", "a"] {
        recipe = add_recipe(tradition, key, key, "Test", 20 if key == "z" else 10);
        require(recipe, ingredient, 1.0, "g", essential=False);
        add_steps(recipe, "one", "two");
        catalogue +>:CATALOGUE_RECIPE():+> recipe;
    }
    pantry = Pantry();
    result = catalogue spawn MatchingWalker(pantry=pantry);
    assert [candidate.recipe.key for candidate in result.matches] == ["a", "b", "z"];
    assert all([candidate.score == 100 for candidate in result.matches]);
}

test "independent request pantries cannot see each other and inputs are bounded" {
    one = match_pantry(["egg"]);
    two = match_pantry(["potato"]);
    assert one.intake.names == ["egg"];
    assert two.intake.names == ["potato"];
    assert one.matches[0].recipe.name != two.matches[0].recipe.name;
    with testraises(ValueError) {
        match_pantry(["egg" for i in range(101)]);
    }
    with testraises(ValueError) {
        match_pantry(["x" * 8001]);
    }
}
