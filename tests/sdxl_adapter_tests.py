import base64
import importlib.util
import io
import os
from pathlib import Path
import unittest
from unittest.mock import patch
from PIL import Image

spec=importlib.util.spec_from_file_location('sdxl',Path(__file__).resolve().parents[1]/'adapters/sdxl_adapter.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
def image_data():
    stream=io.BytesIO();Image.new('RGB',(32,32),(150,100,50)).save(stream,format='PNG')
    return base64.b64encode(stream.getvalue()).decode()

class AdapterTests(unittest.TestCase):
    def test_demo_has_no_fabricated_image(self):
        result=module.generate(dict(mode='demo',prompt='Cooked potato pancake',seed=10))
        self.assertEqual(result['status'],'demo');self.assertEqual(result['image'],'')
        self.assertIn('no SDXL image',result['message'])
    def test_unconfigured_and_missing_weights_are_honest(self):
        with patch.dict(os.environ,{'COOKSY_SDXL_MODEL_PATH':'/does/not/exist'}):
            result=module.generate(dict(mode='local',prompt='Recipe',seed=10))
        self.assertEqual(result['status'],'unavailable')
    def test_image_contract_rejects_external_urls_svg_corruption(self):
        self.assertTrue(module.valid_image(image_data(),'image/png').startswith('data:image/png;base64,'))
        for data,mime in [('https://example.com/a.png','image/png'),('xxx','image/png'),(image_data(),'image/svg+xml'),(image_data(),'image/jpeg')]:
            with self.assertRaises(Exception):module.valid_image(data,mime)
    def test_hosted_payload_and_auth_are_server_only_and_no_redirects(self):
        class Response:
            def __enter__(self):return self
            def __exit__(self,*args):pass
            def read(self,size):
                import json
                return json.dumps(dict(image_base64=image_data(),mime_type='image/png')).encode()
        with patch.dict(os.environ,{'COOKSY_SDXL_ENDPOINT':'https://sdxl.example/generate','COOKSY_SDXL_API_KEY':'test-secret'}):
            with patch.object(module.urllib.request,'build_opener') as opener:
                opener.return_value.open.return_value=Response()
                result=module.generate(dict(mode='hosted',prompt='Declared potato recipe',seed=10))
                request=opener.return_value.open.call_args.args[0]
                self.assertEqual(request.get_header('Authorization'),'Bearer test-secret')
                self.assertIn(b'Declared potato recipe',request.data)
        self.assertEqual(result['status'],'ready');self.assertNotIn('test-secret',str(result))
    def test_hosted_errors_sanitized_and_invalid_endpoint_not_called(self):
        with patch.dict(os.environ,{'COOKSY_SDXL_ENDPOINT':'http://untrusted/generate'}),patch.object(module.urllib.request,'build_opener') as opener:
            self.assertEqual(module.generate(dict(mode='hosted',prompt='Recipe',seed=10))['status'],'unavailable');opener.assert_not_called()
        with patch.dict(os.environ,{'COOKSY_SDXL_ENDPOINT':'https://sdxl.example/generate'}),patch.object(module.urllib.request,'build_opener',side_effect=RuntimeError('private token')):
            result=module.generate(dict(mode='hosted',prompt='Recipe',seed=10))
        self.assertEqual(result['status'],'error');self.assertNotIn('private token',str(result))
    def test_invalid_prompt_seed(self):
        for prompt,seed in [('',1),('x'*10001,1),('Recipe',-1)]:
            self.assertEqual(module.generate(dict(mode='demo',prompt=prompt,seed=seed))['status'],'error')

if __name__=='__main__':unittest.main()
