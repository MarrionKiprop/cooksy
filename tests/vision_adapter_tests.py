"""Local adapter boundary tests; run with the configured vision Python."""
import base64
import importlib.util
import io
from pathlib import Path
import unittest
import tempfile
import os
import sys
from types import SimpleNamespace
from unittest.mock import Mock
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
    def hosted(self, payload, data=None):
        call=Mock(return_value=payload)
        with patch.dict(os.environ,{'COOKSY_VISION_ENDPOINT':'https://langstkip-cooksy-sdxl.hf.space/gradio_api/call/review_photo','COOKSY_VISION_API_KEY':'test-hf-secret'}), patch.dict(sys.modules,{'sdxl_adapter':SimpleNamespace(gradio_payload=call)}):
            result=adapter.classify(photo() if data is None else data,'hosted','')
        return result,call

    def hosted_payload(self, status='predictions_available'):
        return dict(status=status,model='mobilenet_v3_small/IMAGENET1K_V1',
                    requires_user_confirmation=True,width=32,height=24,
                    predictions=[dict(label='banana',ingredient='banana',confidence=0.8)] if status=='predictions_available' else [])

    def test_hosted_contract_keeps_names_unconfirmed_and_auth_private(self):
        result,call=self.hosted(self.hosted_payload())
        self.assertEqual(result['status'],'predictions_available')
        self.assertTrue(result['requires_user_confirmation'])
        self.assertEqual(call.call_args.kwargs['data'],[photo()])
        self.assertEqual(call.call_args.kwargs['outputs'],1)
        self.assertEqual(call.call_args.args[2]['Authorization'],'Bearer test-hf-secret')
        self.assertNotIn('test-hf-secret',str(result))

    def test_hosted_invalid_photo_does_not_leave_server(self):
        result,call=self.hosted(self.hosted_payload(),data='corrupt')
        self.assertEqual(result['status'],'invalid');call.assert_not_called()

    def test_hosted_rejects_unsupported_or_malformed_predictions(self):
        for field,value in [('model','other'),('requires_user_confirmation',False),('width',100),('predictions',[dict(label='pizza',ingredient='pizza',confidence=0.8)]),('predictions',[dict(label='banana',ingredient='banana',confidence=float('nan'))])]:
            payload=self.hosted_payload();payload[field]=value
            result,_=self.hosted(payload)
            self.assertEqual(result['status'],'unavailable');self.assertEqual(result['predictions'],[])
        result,_=self.hosted(self.hosted_payload('no_match'))
        self.assertEqual(result['status'],'no_match')

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
