import from unittest.mock { patch }
import vision.service as photos;
import from vision.models { IngredientImage, DetectionResult, DETECTS, CONFIRMED_AS }
import from vision.service { ConfirmPhotoWalker }
import from graph.models { Pantry, Ingredient, HAS_INGREDIENT }

def fixture() -> dict[str, any] {
    return {
        "status": "predictions_available",
        "model": "test-mobile",
        "message": "Review",
        "width": 40,
        "height": 30,
        "predictions": [
            {"label": "potato raw", "ingredient": "potato", "confidence": 0.8},
            {"label": "tomato raw", "ingredient": "tomato", "confidence": 0.6}
        ]
    };
}

test "photo review cannot mutate pantry and explicit confirmation edits rejects merges" {
    with patch.object(photos, "worker", return_value=fixture()) {
        review = photos.review("test-image", False);
        assert review.requires_user_confirmation and len(review.predictions) == 2;
        with testraises(ValueError) {
            photos.confirm(review.receipt, ["potato", "tomato"], [], False);
        }
        result = photos.confirm(review.receipt, ["sweet potato", ""], ["egg"], True);
        assert result.names == ["egg", "sweet potato"];
        assert "Confirmed ingredient: sweet potato" in result.events;
        assert "Confirmed ingredient: tomato" not in result.events;
    }
}

test "photo receipt tampering stale expiry invalid edits and size fail" {
    with patch.object(photos, "worker", return_value=fixture()) {
        review = photos.review("image", False);
        with testraises(ValueError) {
            photos.confirm("x" + review.receipt, ["potato", ""], [], True);
        }
        with testraises(ValueError) {
            photos.confirm(review.receipt, ["potato"], [], True);
        }
        with testraises(ValueError) {
            photos.confirm(review.receipt, ["2 potatoes", ""], [], True);
        }
        with testraises(ValueError) {
            photos.confirm(review.receipt, ["", ""], [], True);
        }
        with patch.object(
            photos.time, "time", return_value=photos.time.time() + 1000
        ) {
            with testraises(ValueError) {
                photos.confirm(review.receipt, ["potato", ""], [], True);
            }
        }
    }
    with testraises(ValueError) {
        photos.worker("x" * 7000001, "demo");
    }
}

test "photo graph links retain original suggestion and confirmed edit despite traversal order" {
    pantry = Pantry();
    image = IngredientImage(
        digest="test", model="mock", width=20, height=20, demo=False
    );
    first = DetectionResult(
        label="raw cabbage", suggested="cabbage", confidence=0.8, position=0
    );
    second = DetectionResult(
        label="raw apple", suggested="apple", confidence=0.2, position=1
    );
    image +>:DETECTS():+> second;
    image +>:DETECTS():+> first;
    image spawn ConfirmPhotoWalker(pantry=pantry, selections=["spinach", ""]);
    assert [i.name for i in [pantry->:HAS_INGREDIENT:->]] == ["spinach"];
    assert [i.name for i in [first->:CONFIRMED_AS:->]] == ["spinach"];
    assert len([second->:CONFIRMED_AS:->]) == 0;
    assert first.suggested == "cabbage";
}

test "unavailable vision is not demo and timeouts do not expose errors" {
    with patch.object(
        photos.subprocess, "run", side_effect=RuntimeError("private path")
    ) {
        result = photos.worker("image", "local");
        assert result["status"] == "unavailable" and result["predictions"] == [];
        assert "private path" not in result["message"];
    }
    with patch.object(
        photos,
        "worker",
        return_value={
            "status": "no_match",
            "model": "test",
            "message": "No supported ingredient",
            "predictions": []
        }
    ) {
        reviewed = photos.review("image", False);
        assert reviewed.receipt == "" and reviewed.predictions == [];
    }
}
