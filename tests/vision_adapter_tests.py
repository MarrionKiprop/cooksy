"""Local adapter boundary tests; run with the configured vision Python."""
import base64
import importlib.util
import io
from pathlib import Path
import unittest
import tempfile
from unittest.mock import patch
from PIL import Image

spec = importlib.util.spec_from_file_location('adapter', Path(__file__).resolve().parents[1] / 'adapters/vision_adapter.py')
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)

def photo(fmt='PNG'):
    stream = io.BytesIO()
    Image.new('RGB', (32, 24), (150, 100, 80)).save(stream, format=fmt)
    mime = 'png' if fmt == 'PNG' else 'jpeg'
    return f'data:image/{mime};base64,' + base64.b64encode(stream.getvalue()).decode()

class VisionAdapterTests(unittest.TestCase):
    def test_rejects_invalid_and_mismatched_media(self):
        for value in ['', 'http://localhost/private', 'data:image/png;base64,%%%','data:image/svg+xml;base64,abc', photo().replace('image/png','image/jpeg')]:
            self.assertEqual(adapter.classify(value, 'demo', '')['status'], 'invalid')
    def test_size_and_pixel_limits(self):
        self.assertEqual(adapter.classify('x'*7_000_001,'demo','')['status'],'invalid')
        with patch.object(adapter, 'MAX_PIXELS', 100):
            self.assertEqual(adapter.classify(photo(),'demo','')['status'],'invalid')
    def test_decoder_accepts_jpeg_png_and_demo_discloses(self):
        for fmt in ['PNG','JPEG']:
            result=adapter.classify(photo(fmt),'demo','')
            self.assertEqual(result['status'],'demo')
            self.assertTrue(result['requires_user_confirmation'])
            self.assertIn('not recognized',result['message'])
            self.assertEqual((result['width'],result['height']),(32,24))
            self.assertEqual(len(result['predictions']),2)
    def test_missing_weights_no_implicit_demo(self):
        result=adapter.classify(photo(),'local','/does/not/exist')
        self.assertEqual(result['status'],'unavailable')
        self.assertEqual(result['predictions'],[])
    def test_wrong_checkpoint_cannot_claim_official_model(self):
        with tempfile.NamedTemporaryFile() as checkpoint:
            checkpoint.write(b'wrong checkpoint');checkpoint.flush()
            result=adapter.classify(photo(),'local',checkpoint.name)
        self.assertEqual(result['status'],'unavailable')
        self.assertIn('do not match',result['message'])

    def test_conservative_label_mapping(self):
        self.assertEqual(adapter.FOOD['head cabbage'],'cabbage')
        for label in ['hen','pizza','cheeseburger','red wine']:
            self.assertNotIn(label,adapter.FOOD)

if __name__=='__main__': unittest.main()
