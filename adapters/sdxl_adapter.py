"""Optional SDXL worker: local offline Diffusers or a configured JSON HTTPS bridge."""
import base64
import io
import json
import os
import sys
import urllib.parse
import urllib.request
import warnings

MAX_IMAGE = 2 * 1024 * 1024


def valid_image(encoded, mime):
    if mime not in ('image/png', 'image/jpeg') or not isinstance(encoded, str) or len(encoded) > 2_800_000:
        raise ValueError('Invalid image')
    blob = base64.b64decode(encoded, validate=True)
    if not 0 < len(blob) <= MAX_IMAGE:
        raise ValueError('Invalid image size')
    from PIL import Image
    with warnings.catch_warnings():
        warnings.simplefilter('error', Image.DecompressionBombWarning)
        with Image.open(io.BytesIO(blob)) as image:
            if image.format != ('PNG' if mime == 'image/png' else 'JPEG') or getattr(image, 'n_frames', 1) != 1:
                raise ValueError('Invalid image format')
            if image.width * image.height > 1_500_000:
                raise ValueError('Image dimensions too large')
            image.verify()
    return 'data:' + mime + ';base64,' + encoded


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def generate(request):
    mode = request.get('mode', 'off')
    prompt = request.get('prompt', '')
    seed = request.get('seed', 0)
    result = dict(status='unavailable', image='', model='SDXL', provider=mode,
                  message='Serving preview generation is not configured. Your recipe and cook-along remain available.')
    if not isinstance(prompt, str) or not 1 <= len(prompt) <= 10000 or not isinstance(seed, int) or not 0 <= seed < 2**31:
        result.update(status='error', message='Invalid preview request.')
        return result
    if mode == 'demo':
        result.update(status='demo', provider='Cooksy demo', model='No model / no inference',
                      message='DEMO layout only; no SDXL image was generated. The recipe-grounded prompt and cache are real.')
        return result
    try:
        if mode == 'hosted':
            endpoint = os.environ.get('COOKSY_SDXL_ENDPOINT', '')
            parsed = urllib.parse.urlsplit(endpoint)
            if parsed.scheme != 'https' or not parsed.netloc or parsed.username or parsed.password or parsed.query or parsed.fragment:
                return result
            model = os.environ.get('COOKSY_SDXL_MODEL_ID', 'stabilityai/stable-diffusion-xl-base-1.0')
            body = json.dumps(dict(model=model, prompt=prompt, negative_prompt=request.get('negative_prompt', ''),
                                   seed=seed, width=768, height=768, steps=25)).encode()
            headers = {'Content-Type': 'application/json'}
            key = os.environ.get('COOKSY_SDXL_API_KEY', '')
            if key:
                headers['Authorization'] = 'Bearer ' + key
            req = urllib.request.Request(endpoint, data=body, headers=headers, method='POST')
            with urllib.request.build_opener(NoRedirect()).open(req, timeout=60) as response:
                raw = response.read(2_801_000)
                if len(raw) >= 2_801_000:
                    raise ValueError('Response too large')
                payload = json.loads(raw)
            result.update(status='ready', model=model, provider='Configured SDXL HTTPS bridge',
                          image=valid_image(payload['image_base64'], payload['mime_type']),
                          message='Generated serving illustration. Actual appearance may differ.')
        elif mode == 'local':
            path = os.environ.get('COOKSY_SDXL_MODEL_PATH', '')
            if not os.path.isdir(path):
                return result
            import torch
            if not torch.cuda.is_available():
                result['message'] = 'Local SDXL requires a configured CUDA runtime. Use demo or configure a hosted provider.'
                return result
            from diffusers import StableDiffusionXLPipeline
            pipe = StableDiffusionXLPipeline.from_pretrained(path, local_files_only=True, use_safetensors=True,
                                                           torch_dtype=torch.float16).to('cuda')
            with torch.inference_mode():
                image = pipe(prompt=prompt, negative_prompt=request.get('negative_prompt', ''), width=768, height=768,
                             num_inference_steps=25, generator=torch.Generator('cuda').manual_seed(seed)).images[0]
            stream = io.BytesIO()
            image.save(stream, format='PNG')
            result.update(status='ready', provider='Local offline Diffusers', model=os.environ.get('COOKSY_SDXL_MODEL_ID', 'stabilityai/stable-diffusion-xl-base-1.0'),
                          image=valid_image(base64.b64encode(stream.getvalue()).decode(), 'image/png'),
                          message='Generated serving illustration. Actual appearance may differ.')
    except Exception:
        result.update(status='error', image='', message='Serving preview could not be generated. Retry later; your recipe is still available.')
    return result


if __name__ == '__main__':
    try:
        result = generate(json.loads(sys.stdin.read(70000)))
    except Exception:
        result = dict(status='error', image='', model='SDXL', provider='unknown', message='Preview unavailable; your recipe is still available.')
    print(json.dumps(result, allow_nan=False))
