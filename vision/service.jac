"""Private request-local photo topology; signed review receipts contain no image bytes."""
import os;
import sys;
import json;
import hmac;
import hashlib;
import secrets;
import time;
import subprocess;
import from pathlib { Path }
import from .views { PredictionView, PhotoReview, PhotoCommit }
import from .models {
    IngredientImage,
    DetectionResult,
    DETECTS,
    CONFIRMED_AS,
    PANTRY_IMAGE
}
import from graph.models { Pantry, Ingredient, HAS_INGREDIENT }
import from pantry.normalisation { normalise_name }

glob signing_key: bytes = secrets.token_bytes(32);

def worker(data: str, mode: str) -> dict[str, any] {
    if len(data) > 7000000 {
        raise ValueError("Photo exceeds the 5 MiB limit.");
    }
    executable = os.environ.get("COOKSY_VISION_PYTHON", "") or sys.executable;
    script = str(
        Path(__file__).resolve().parent.parent / "adapters" / "vision_adapter.py"
    );
    try {
        result = subprocess.run(
            [executable, script],
            input=json.dumps(
                {
                    "data": data,
                    "mode": mode,
                    "weights": os.environ.get("COOKSY_VISION_MODEL_PATH", "")
                }
            ),
            capture_output=True,
            text=True,
            timeout=25,
            check=True
        );
        return json.loads(result.stdout) as dict[str, any];
    } except Exception {
        return {
            "status": "unavailable",
            "model": "mobilenet_v3_small",
            "message": "Vision unavailable or timed out. Use typed ingredients.",
            "predictions": [],
            "width": 0,
            "height": 0
        };
    }
}

def review(data: str, demo: bool) -> PhotoReview {
    mode = "demo" if demo else os.environ.get("COOKSY_VISION_MODE", "local");
    # Demo is always an explicit UI action, never an implicit fallback.
    if not demo and mode == "demo" {
        mode = "off";
    }
    raw = worker(data, mode);
    status = str(raw["status"]);
    model = str(raw["model"]);
    predictions: list[PredictionView] = [];
    receipt = "";
    if status in ["demo", "predictions_available"] {
        for item in raw["predictions"] {
            name = normalise_name(str(item["ingredient"]));
            confidence = float(item["confidence"]);
            if not name or not 0 <= confidence <= 1 or len(str(item["label"])) > 100 {
                raise ValueError("Invalid vision output.");
            }
            predictions.append(
                PredictionView(
                    label=str(item["label"]), ingredient=name, confidence=confidence
                )
            );
        }
        if len(predictions) > 5 {
            raise ValueError("Too many predictions.");
        }
        payload = json.dumps(
            {
                "digest": hashlib.sha256(data.encode()).hexdigest(),
                "model": model,
                "width": int(raw["width"]),
                "height": int(raw["height"]),
                "demo": status == "demo",
                "expires": int(time.time()) + 900,
                "predictions": [
                    {
                        "label": p.label,
                        "ingredient": p.ingredient,
                        "confidence": p.confidence
                    } for p in predictions
                ]
            }
        );
        signature = hmac.new(signing_key, payload.encode(), hashlib.sha256).hexdigest();
        receipt = signature + "." + payload;
    }
    return PhotoReview(
        status=status,
        model=model,
        message=str(raw["message"]),
        predictions=predictions,
        receipt=receipt
    );
}

walker ConfirmPhotoWalker {
    has pantry: Pantry,
        selections: list[str];

    has index: int = 0,
        events: list[str] = [];

    can start with IngredientImage entry {
        self.events.append("Visited image metadata; no photo bytes retained.");
        visit [here->:DETECTS:->];
    }

    can accept with DetectionResult entry {
        # Stable association is stored on the detection label through supplied order.
        self.events.append("Reviewed prediction: " + here.label);
        name = self.selections[here.position];
        self.index += 1;
        if not name {
            skip;
        }
        ingredient = Ingredient(name=name);
        for existing in [self.pantry->:HAS_INGREDIENT:->] {
            if existing.name == name {
                ingredient = existing;
            }
        }
        if ingredient not in [self.pantry->:HAS_INGREDIENT:->] {
            self.pantry +>:HAS_INGREDIENT():+> ingredient;
        }
        here +>:CONFIRMED_AS():+> ingredient;
        self.events.append("Confirmed ingredient: " + name);
    }
}

def confirm(
    receipt: str, selections: list[str], existing: list[str], confirmed: bool
) -> PhotoCommit {
    if not confirmed {
        raise ValueError("Explicit photo confirmation is required.");
    }
    if len(receipt) > 10000 or len(existing) > 100 {
        raise ValueError("Request too large.");
    }
    parts = receipt.split(".", 1);
    if len(parts) != 2
        or not hmac.compare_digest(
            parts[0],
            hmac.new(signing_key, parts[1].encode(), hashlib.sha256).hexdigest()
        ) {
        raise ValueError("Photo review expired or invalid. Review the photo again.");
    }
    payload = json.loads(parts[1]) as dict[str, any];
    if int(payload["expires"]) < time.time() {
        raise ValueError("Photo review expired. Review again.");
    }
    predictions = payload["predictions"];
    if len(selections) != len(predictions) {
        raise ValueError("Review every prediction.");
    }
    names: list[str] = [];
    for raw in selections {
        name = normalise_name(raw) if raw.strip() else "";
        if raw.strip() and not name {
            raise ValueError("Use ingredient names only.");
        }
        names.append(name);
    }
    if not any(names) {
        raise ValueError("Accept at least one suggestion, or use typed entry.");
    }
    pantry = Pantry();
    for raw in existing {
        name = normalise_name(raw);
        if not name {
            raise ValueError("Invalid existing pantry name.");
        }
        if name not in [i.name for i in [pantry->:HAS_INGREDIENT:->]] {
            pantry +>:HAS_INGREDIENT():+> Ingredient(name=name);
        }
    }
    image = IngredientImage(
        digest=str(payload["digest"]),
        model=str(payload["model"]),
        width=int(payload["width"]),
        height=int(payload["height"]),
        demo=bool(payload["demo"])
    );
    pantry +>:PANTRY_IMAGE():+> image;
    for (position, item) in enumerate(predictions) {
        image +>:DETECTS():+> DetectionResult(
            label=str(item["label"]),
            suggested=str(item["ingredient"]),
            confidence=float(item["confidence"]),
            position=position
        );
    }
    walking = image spawn ConfirmPhotoWalker(pantry=pantry, selections=names);
    result = sorted(set([i.name for i in [pantry->:HAS_INGREDIENT:->]]));
    if len(result) > 100 {
        raise ValueError("Pantry limit is 100 names.");
    }
    return PhotoCommit(
        names=result,
        message="Photo suggestions confirmed. Your shared pantry is updated.",
        events=walking.events
    );
}
