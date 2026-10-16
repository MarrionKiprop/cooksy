import from unittest.mock { patch }
import previews.service as previews;
import from previews.models { PreviewCache, CACHED_IMAGE, GENERATED_FOR, HAS_PREVIEW }
import from graph.seed { build_demo_graph }
import from graph.models { Recipe, HAS_STEP }
import from graph.projections { recipe_view }
import from walkers.recipe { RecipeWalker }
import from previews.service { VisualisationWalker, prompt_for, key_for }

def chosen() -> Recipe {
    result = build_demo_graph() spawn RecipeWalker(recipe_key="gamja-jeon-demo");
    assert result.selected_node is not None;
    return result.selected_node as Recipe;
}

def demo_result() -> dict[str, any] {
    return {
        "status": "demo",
        "image": "",
        "model": "No inference",
        "provider": "Test demo",
        "message": "Demo only"
    };
}

test "preview prompt is grounded in graph recipe with stable version-sensitive key" {
    recipe = chosen();
    prompt = prompt_for(recipe);
    assert recipe.name in prompt and "potato" in prompt and "servings" in prompt;
    for step in [recipe->:HAS_STEP:->] {
        assert step.instruction in prompt;
    }
    first = key_for(recipe, prompt, "demo");
    assert first == key_for(recipe, prompt_for(recipe), "demo");
    assert first != key_for(recipe, prompt, "hosted");
    recipe.version = "changed";
    assert first != key_for(recipe, prompt, "demo");
    recipe.name += " edited";
    assert prompt_for(recipe) != prompt;
}

test "cache-only load never infers while explicit request caches graph metadata and reuses" {
    recipe = chosen();
    store = PreviewCache();
    with patch.object(
        previews, "run_adapter", return_value=demo_result()
    ) as provider {
        before = recipe spawn VisualisationWalker(
            store=store, mode="demo", generate=False
        );
        assert before.result is not None and before.result.status == "not_requested";
        provider.assert_not_called();
        first = recipe spawn VisualisationWalker(
            store=store, mode="demo", generate=True
        );
        assert first.result is not None
            and first.result.status == "demo"
            and not first.result.cached;
        assert len([store->:CACHED_IMAGE:->]) == 1;
        image = [store->:CACHED_IMAGE:->][0];
        assert image.recipe_key == recipe.key
            and image.recipe_version == recipe.version;
        assert [image->:GENERATED_FOR:->][0] == recipe;
        assert [recipe->:HAS_PREVIEW:->][0] == image;
        second = recipe spawn VisualisationWalker(
            store=store, mode="demo", generate=True
        );
        assert second.result is not None and second.result.cached;
        assert second.result.cache_key == first.result.cache_key;
        assert provider.call_count == 1;
    }
}

test "unavailable and failure are not cached and can retry without losing recipe" {
    recipe = chosen();
    store = PreviewCache();
    with patch.object(
        previews,
        "run_adapter",
        return_value={
            "status": "unavailable",
            "image": "",
            "model": "SDXL",
            "provider": "none",
            "message": "Not configured"
        }
    ) as provider {
        for index in range(2) {
            result = recipe spawn VisualisationWalker(
                store=store, mode="off", generate=True
            );
            assert result.result is not None and result.result.status == "unavailable";
        }
        assert provider.call_count == 2 and len([store->:CACHED_IMAGE:->]) == 0;
        assert len([recipe->:HAS_STEP:->]) > 0;
    }
    with patch.object(
        previews.subprocess, "run", side_effect=RuntimeError("secret-path")
    ) {
        failure = previews.run_adapter("recipe", 42, "local");
        assert failure["status"] == "error" and "secret-path" not in failure["message"];
    }
}

test "only existing full selected recipe and actual version permit preview" {
    with patch.object(previews, "run_adapter") as provider {
        with testraises(ValueError) {
            previews.selected_preview(
                "unknown-candidate", "cooksy-demo-v1", True, True
            );
        }
        with testraises(ValueError) {
            previews.selected_preview("gamja-jeon-demo", "old-version", True, True);
        }
        provider.assert_not_called();
    }
}

test "bounded preview cache and prompt edits invalidate previous image" {
    recipe = chosen();
    store = PreviewCache();
    with patch.object(
        previews, "run_adapter", return_value=demo_result()
    ) as provider {
        for index in range(18) {
            recipe.version = "fixture-version-" + str(index);
            result = recipe spawn VisualisationWalker(
                store=store, mode="demo", generate=True
            );
            assert result.result is not None and not result.result.cached;
        }
        assert provider.call_count == 18 and len([store->:CACHED_IMAGE:->]) == 16;
    }
}

test "canonical preview prompt ignores ingredient traversal order" {
    recipe = chosen();
    view = recipe_view(recipe);
    original = prompt_for(recipe);
    view.requirements.reverse();
    with patch.object(previews, "recipe_view", return_value=view) {
        assert prompt_for(recipe) == original;
    }
}

test "preview demo worker uses actual python instead of packaged jac executable" {
    with patch.dict(previews.os.environ, {"COOKSY_SDXL_PYTHON": ""}) {
        result = previews.run_adapter("A cooked potato pancake", 42, "demo");
        assert result["status"] == "demo" and result["image"] == "";
    }
}
