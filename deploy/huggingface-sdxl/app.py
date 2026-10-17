"""SDXL inference only. Cooksy's application and graph remain in Jac."""
import base64
import io
import hashlib
from pathlib import Path
import tempfile
import urllib.request

import spaces  # Must precede torch for ZeroGPU initialization.
import gradio as gr
import torch
from diffusers import StableDiffusionXLPipeline
from vision_adapter import classify

MODEL = 'stabilityai/stable-diffusion-xl-base-1.0'
REVISION = '462165984030d82259a11f4367a4eed129e94a7b'
CAPTION = 'AI-generated serving preview; illustrative, not an exact photograph.'

pipe = StableDiffusionXLPipeline.from_pretrained(
    MODEL, revision=REVISION, variant='fp16', dtype=torch.float16,
    use_safetensors=True,
).to('cuda')
pipe.vae.enable_slicing()


def mobile_weights():
    digest = '047dcff4addef86ea5bc2eff13c9614dc11f47ab1160d0a71a25e7db994f4e1f'
    target = Path(tempfile.gettempdir()) / 'cooksy-models' / 'mobilenet_v3_small-047dcff4.pth'
    if target.is_file() and hashlib.sha256(target.read_bytes()).hexdigest() == digest:
        return target
    url = 'https://download.pytorch.org/models/mobilenet_v3_small-047dcff4.pth'
    with urllib.request.urlopen(url, timeout=20) as response:
        blob = response.read(11_000_001)
    if len(blob) > 11_000_000 or hashlib.sha256(blob).hexdigest() != digest:
        raise ValueError('MobileNet checkpoint verification failed')
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix('.tmp')
    temporary.write_bytes(blob)
    temporary.replace(target)
    return target


def review_photo(data: str):
    # No GPU reservation. Decode first; never download weights for invalid media.
    checked = classify(data, 'validate', '')
    if checked['status'] != 'valid':
        return checked
    try:
        return classify(data, 'local', str(mobile_weights()))
    except Exception:
        checked.update(status='unavailable', predictions=[],
                       message='Photo recognition unavailable. Use typed ingredients.')
        return checked


@spaces.GPU(duration=60)
def generate(prompt: str, negative_prompt: str, seed: int):
    if not isinstance(prompt, str) or not prompt.strip() or len(prompt) > 10000:
        raise gr.Error('Enter a recipe prompt of 1–10000 characters.')
    if not isinstance(negative_prompt, str) or len(negative_prompt) > 2000:
        raise gr.Error('Negative prompt is too long.')
    if isinstance(seed, bool) or not isinstance(seed, (int, float)) or int(seed) != seed or not 0 <= seed < 2**31:
        raise gr.Error('Seed must be an integer between 0 and 2147483647.')
    seed = int(seed)
    with torch.inference_mode():
        image = pipe(
            prompt=prompt, negative_prompt=negative_prompt,
            width=768, height=768, num_inference_steps=25,
            generator=torch.Generator(device='cuda').manual_seed(seed),
        ).images[0].convert('RGB')
    stream = io.BytesIO()
    image.save(stream, format='JPEG', quality=88, optimize=True)
    payload = {
        'image_base64': base64.b64encode(stream.getvalue()).decode('ascii'),
        'mime_type': 'image/jpeg', 'model': MODEL, 'revision': REVISION,
        'seed': seed, 'steps': 25,
    }
    return image, payload


with gr.Blocks() as demo:
    gr.Markdown('# Cooksy serving previews\n' + CAPTION)
    gr.Markdown('SDXL on shared ZeroGPU. Queues and daily quotas apply. '
                'Do not include private information. Output does not verify ingredients or cooking safety.')
    prompt = gr.Textbox(label='Recipe prompt', lines=5, max_lines=12)
    negative = gr.Textbox(label='Negative prompt', value='text, watermark, raw unfinished meal, unrelated side dishes')
    seed = gr.Number(label='Seed', value=42, precision=0)
    button = gr.Button('Generate serving preview', variant='primary')
    image = gr.Image(label=CAPTION, format='jpeg')
    response = gr.JSON(visible=False)
    button.click(generate, [prompt, negative, seed], [image, response],
                 api_name='generate', concurrency_limit=1)
    photo_data = gr.Textbox(visible=False)
    photo_result = gr.JSON(visible=False)
    photo_button = gr.Button(visible=False)
    photo_button.click(review_photo, photo_data, photo_result,
                       api_name='review_photo', concurrency_id='vision', concurrency_limit=1)

if __name__ == '__main__':
    demo.queue(max_size=4, default_concurrency_limit=1).launch(show_error=False)
