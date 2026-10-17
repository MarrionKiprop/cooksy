import base64
import importlib.util
import io
import json
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
    def space_request(self, events, receipt=None):
        class Response(io.BytesIO):
            def __enter__(self): return self
            def __exit__(self, *args): self.close()
        with patch.dict(os.environ, {
            'COOKSY_SDXL_ENDPOINT':'https://langstkip-cooksy-sdxl.hf.space/gradio_api/call/generate',
            'COOKSY_SDXL_API_KEY':'test-hf-token',
        }), patch.object(module.urllib.request, 'build_opener') as opener:
            opener.return_value.open.side_effect = [
                Response(json.dumps(receipt or {'event_id':'event123'}).encode()),
                Response(events),
            ]
            result=module.generate(dict(mode='hosted',prompt='Cooked potato',negative_prompt='text',seed=10))
            calls=opener.return_value.open.call_args_list
        return result,calls

    def test_space_queue_and_image_contract(self):
        payload=dict(image_base64=image_data(),mime_type='image/png',
                     model='stabilityai/stable-diffusion-xl-base-1.0',seed=10,steps=25)
        events=b'event: heartbeat\ndata: null\n\nevent: complete\ndata: '+json.dumps([{'url':'https://never-download.example/'},payload]).encode()+b'\n\n'
        result,calls=self.space_request(events)
        self.assertEqual(result['status'],'ready')
        self.assertEqual(len(calls),2)  # No third request to returned file URL.
        self.assertEqual(json.loads(calls[0].args[0].data),{'data':['Cooked potato','text',10]})
        self.assertTrue(calls[1].args[0].full_url.endswith('/generate/event123'))
        for call in calls:self.assertEqual(call.args[0].get_header('Authorization'),'Bearer test-hf-token')
        self.assertNotIn('test-hf-token',str(result))

    def test_space_rejects_bad_receipt_failed_or_incomplete_events(self):
        for events,receipt in [
            (b'',{'event_id':'../../secret'}),
            (b'event: error\ndata: "private details"\n\n',None),
            (b'event: heartbeat\ndata: null\n\n',None),
            (b'event: complete\ndata: ["https://example.com/image"]\n\n',None),
            (b'x'*2_801_001,None),
        ]:
            result,_=self.space_request(events,receipt)
            self.assertEqual(result['status'],'error')
            self.assertNotIn('private details',str(result))

    def test_space_rejects_model_mismatch_and_corrupt_image(self):
        for model,encoded in [('other-model',image_data()),('stabilityai/stable-diffusion-xl-base-1.0','invalid')]:
            payload=dict(image_base64=encoded,mime_type='image/png',model=model,seed=10,steps=25)
            result,_=self.space_request(b'event: complete\ndata: '+json.dumps([{},payload]).encode()+b'\n\n')
            self.assertEqual(result['status'],'error')

    def test_space_timeout_does_not_submit_another_gpu_job(self):
        with patch.dict(os.environ,{'COOKSY_SDXL_ENDPOINT':'https://langstkip-cooksy-sdxl.hf.space/gradio_api/call/generate'}), patch.object(module.urllib.request,'build_opener') as opener:
            opener.return_value.open.side_effect=TimeoutError('private provider details')
            result=module.generate(dict(mode='hosted',prompt='Cooked potato',seed=10))
        self.assertEqual(result['status'],'error')
        self.assertEqual(opener.return_value.open.call_count,1)
        self.assertNotIn('private provider details',str(result))

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
