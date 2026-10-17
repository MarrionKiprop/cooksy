"""Validated MobileNet worker: offline local inference or explicit hosted review."""
import base64
import io
import hashlib
import json
import os
import math
import sys
import urllib.parse
import warnings

MAX_BYTES = 5 * 1024 * 1024
MAX_PIXELS = 16_000_000
# Conservative ImageNet label mapping; never map dishes/animals to raw ingredients.
FOOD = {"banana": "banana", "orange": "orange", "lemon": "lemon",
        "Granny Smith": "apple", "pineapple": "pineapple", "strawberry": "strawberry",
        "pomegranate": "pomegranate", "fig": "fig", "jackfruit": "jackfruit",
        "broccoli": "broccoli", "cauliflower": "cauliflower", "head cabbage": "cabbage",
        "cucumber": "cucumber", "zucchini": "zucchini", "bell pepper": "bell pepper",
        "artichoke": "artichoke", "butternut squash": "butternut squash",
        "acorn squash": "acorn squash", "spaghetti squash": "spaghetti squash",
        "corn": "corn", "mushroom": "mushroom"}


def classify(data_url: str, mode: str, weights_path: str) -> dict:
    result = dict(status="invalid", model="mobilenet_v3_small/IMAGENET1K_V1",
                  predictions=[], requires_user_confirmation=True, width=0, height=0,
                  message="Use a valid JPEG or PNG image up to 5 MiB and 16 megapixels.")
    try:
        if not isinstance(data_url, str) or len(data_url) > 7_000_000:
            return result
        header, encoded = data_url.split(",", 1)
        if header not in ("data:image/jpeg;base64", "data:image/png;base64"):
            return result
        blob = base64.b64decode(encoded, validate=True)
        if not 0 < len(blob) <= MAX_BYTES:
            return result
        from PIL import Image, ImageOps
        Image.MAX_IMAGE_PIXELS = MAX_PIXELS
        with warnings.catch_warnings():
            warnings.simplefilter("error", Image.DecompressionBombWarning)
            with Image.open(io.BytesIO(blob)) as check:
                expected = "JPEG" if "jpeg" in header else "PNG"
                if check.format != expected or getattr(check, "n_frames", 1) != 1:
                    return result
                if check.width * check.height > MAX_PIXELS:
                    return result
                check.verify()
            with Image.open(io.BytesIO(blob)) as source:
                image = ImageOps.exif_transpose(source).convert("RGB")
                image.load()
        result.update(width=image.width, height=image.height)
    except ImportError:
        result.update(status="unavailable", message="Image decoder unavailable. Use typed ingredients.")
        return result
    except Exception:
        return result
    if mode == "validate":
        result.update(status="valid", message="Image validated.")
        return result
    if mode == "demo":
        result.update(status="demo", model="Cooksy demo fixture / no inference",
                      predictions=[dict(label="demo potato", ingredient="potato", confidence=0.87),
                                   dict(label="demo tomato", ingredient="tomato", confidence=0.64)],
                      message="DEMO: fixed potato/tomato suggestions; not recognized from your photo.")
        return result
    if mode == "hosted":
        endpoint = os.environ.get('COOKSY_VISION_ENDPOINT', '')
        parsed = urllib.parse.urlsplit(endpoint)
        if (parsed.scheme != 'https' or not (parsed.hostname or '').endswith('.hf.space')
                or parsed.path != '/gradio_api/call/review_photo' or parsed.username
                or parsed.password or parsed.query or parsed.fragment):
            result.update(status='unavailable', message='Hosted photo recognition is not configured. Use typed ingredients.')
            return result
        try:
            from sdxl_adapter import gradio_payload
            headers = {'Content-Type': 'application/json'}
            key = os.environ.get('COOKSY_VISION_API_KEY', '')
            if key: headers['Authorization'] = 'Bearer ' + key
            payload = gradio_payload(endpoint, {}, headers, data=[data_url], outputs=1, index=0)
            if (payload.get('model') != result['model']
                    or payload.get('requires_user_confirmation') is not True
                    or payload.get('width') != image.width or payload.get('height') != image.height):
                raise ValueError('Invalid hosted photo contract')
            predictions = payload.get('predictions')
            if not isinstance(predictions, list) or len(predictions) > 5:
                raise ValueError('Invalid predictions')
            for item in predictions:
                label, name, score = item['label'], item['ingredient'], item['confidence']
                if (not isinstance(label, str) or FOOD.get(label) != name
                        or isinstance(score, bool) or not isinstance(score, (float, int))
                        or not math.isfinite(score) or not 0.05 <= score <= 1):
                    raise ValueError('Unsupported prediction')
            status = payload.get('status')
            if status not in ['predictions_available', 'no_match', 'unavailable']:
                raise ValueError('Invalid hosted status')
            if (status == 'predictions_available') != bool(predictions):
                raise ValueError('Invalid hosted result')
            result.update(status=status, predictions=predictions,
                          message='Review each suggestion before adding it.' if predictions else
                          ('No supported ingredient among the top predictions. Try one prominent ingredient or type its name.'
                           if status == 'no_match' else 'Hosted recognition is unavailable. Use typed ingredients.'))
        except Exception:
            result.update(status='unavailable', predictions=[], message='Hosted recognition failed or timed out. Your pantry is unchanged; use typed ingredients.')
        return result
    if mode != "local" or not weights_path or not os.path.isfile(weights_path):
        result.update(status="unavailable", message="Local vision weights are unavailable. Use typed ingredients or explicitly try demo.")
        return result
    try:
        if os.path.getsize(weights_path) > 11_000_000:
            raise ValueError("Unexpected baseline weights size")
        with open(weights_path, "rb") as checkpoint:
            digest = hashlib.sha256(checkpoint.read()).hexdigest()
        if digest != "047dcff4addef86ea5bc2eff13c9614dc11f47ab1160d0a71a25e7db994f4e1f":
            result.update(status="unavailable", message="Local weights do not match the supported MobileNet baseline. Use typed ingredients.")
            return result
        import torch
        from torchvision.models import mobilenet_v3_small, MobileNet_V3_Small_Weights
        torch.set_num_threads(2)
        weights = MobileNet_V3_Small_Weights.IMAGENET1K_V1
        model = mobilenet_v3_small(weights=None)
        model.load_state_dict(torch.load(weights_path, map_location="cpu", weights_only=True))
        model.eval()
        with torch.inference_mode():
            probabilities = model(weights.transforms()(image).unsqueeze(0))[0].softmax(0)
            values, indexes = probabilities.topk(5)
        predictions = []
        for confidence, index in zip(values.tolist(), indexes.tolist()):
            label = weights.meta["categories"][index]
            if label in FOOD and confidence >= 0.05:
                predictions.append(dict(label=label, ingredient=FOOD[label], confidence=confidence))
        result.update(status="predictions_available" if predictions else "no_match", predictions=predictions,
                      message="Best-effort prominent-object classification. Alternatives are not separate detected objects; scores are not certainty. Review every suggestion." if predictions else "No supported ingredient among the top predictions. Try one prominent ingredient or type its name.")
    except Exception:
        result.update(status="unavailable", message="Local vision could not run. Your pantry is unchanged; use typed ingredients or try demo.")
    return result


if __name__ == "__main__":
    try:
        request = json.loads(sys.stdin.read(7_001_000))
        response = classify(request.get("data", ""), request.get("mode", ""), request.get("weights", ""))
    except Exception:
        response = dict(status="unavailable", model="mobilenet_v3_small", predictions=[],
                        requires_user_confirmation=True, width=0, height=0, message="Vision unavailable; use typed ingredients.")
    print(json.dumps(response, allow_nan=False))
