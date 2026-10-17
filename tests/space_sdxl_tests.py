"""Exercise the Space contract without importing torch or downloading weights."""
import base64
import importlib.util
import io
from pathlib import Path
import sys
import unittest
from unittest.mock import MagicMock, patch

from PIL import Image


class SpaceTests(unittest.TestCase):
    def setUp(self):
        gradio = MagicMock()
        gradio.Error = ValueError
        spaces = MagicMock()
        spaces.GPU.side_effect = lambda **kwargs: lambda fn: fn
        self.torch = MagicMock()
        diffusers = MagicMock()
        self.pipe = MagicMock(spec=['vae'])
        self.pipe.vae = MagicMock(spec=['enable_slicing'])
        diffusers.StableDiffusionXLPipeline.from_pretrained.return_value.to.return_value = self.pipe
        self.pipe.return_value.images = [Image.new('RGB', (768, 768), (120, 80, 40))]
        modules = {'spaces': spaces, 'gradio': gradio, 'torch': self.torch, 'diffusers': diffusers}
        with patch.dict(sys.modules, modules):
            path = Path(__file__).resolve().parents[1] / 'deploy/huggingface-sdxl/app.py'
            spec = importlib.util.spec_from_file_location('cooksy_sdxl_space', path)
            self.app = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(self.app)
        self.spaces = spaces

    def test_loading_does_not_generate_and_gpu_call_is_bounded(self):
        self.pipe.assert_not_called()
        self.pipe.vae.enable_slicing.assert_called_once_with()
        self.spaces.GPU.assert_called_once_with(duration=60)

    def test_generated_image_and_metadata_match_adapter_policy(self):
        image, payload = self.app.generate('Cooked potato pancake', 'watermark', 123)
        self.assertEqual(image.size, (768, 768))
        self.assertEqual(payload['seed'], 123)
        self.assertEqual(payload['steps'], 25)
        self.assertEqual(payload['model'], 'stabilityai/stable-diffusion-xl-base-1.0')
        self.assertEqual(payload['mime_type'], 'image/jpeg')
        with Image.open(io.BytesIO(base64.b64decode(payload['image_base64'], validate=True))) as output:
            self.assertEqual(output.size, (768, 768))
            self.assertEqual(output.format, 'JPEG')
        self.assertLess(len(base64.b64decode(payload['image_base64'])), 2*1024*1024)
        self.assertEqual(self.pipe.call_args.kwargs['num_inference_steps'], 25)

    def test_invalid_inputs_never_call_pipeline(self):
        for prompt, negative, seed in [('', '', 0), ('x'*10001, '', 0),
                                       ('dish', 'x'*2001, 0), ('dish', '', -1),
                                       ('dish', '', 2**31), ('dish', '', 1.5)]:
            with self.assertRaises(ValueError): self.app.generate(prompt, negative, seed)
        self.pipe.assert_not_called()


if __name__ == '__main__':
    unittest.main()
