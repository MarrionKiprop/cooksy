import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {envelope,installModelFixtures} from './browser-fixtures.mjs';
const browser=await chromium.launch();
const page=await browser.newPage();
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const errors=[];page.on('pageerror',e=>errors.push(e.message));
let reviews=0, confirmations=0;
const notice='Review photo sends your image to Hugging Face for recognition. Cooksy does not save the photo or send it to OpenAI. Avoid private images.';
const photo=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAACAAAAAYCAIAAAAUMWhjAAAAJklEQVR4nGNMmWbEQEvARFPTRy0YtWDUglELRi0YtWDUglELqAYAifcBXGHsQmkAAAAASUVORK5CYII=','base64');
try{
 await installModelFixtures(page);
 await page.route('**/function/photo_processing_notice',r=>r.fulfill({contentType:'application/json',body:envelope(notice)}));
 await page.route('**/function/review_photo_ingredients',r=>{
  reviews++;const body=r.request().postDataJSON();expect(body.demo).toBe(false);
  expect(body.data).toMatch(/^data:image\/png;base64,/);
  return r.fulfill({contentType:'application/json',body:envelope({status:'predictions_available',model:'mobilenet_v3_small/IMAGENET1K_V1',message:'Review',predictions:[{label:'banana',ingredient:'banana',confidence:.8}],receipt:'mock-receipt',requires_user_confirmation:true})});
 });
 await page.route('**/function/confirm_photo_ingredients',r=>{
  confirmations++;const body=r.request().postDataJSON();expect(body.selections).toEqual(['green banana']);
  return r.fulfill({contentType:'application/json',body:envelope({names:['green banana'],message:'Pantry updated.',events:[]})});
 });
 await page.goto(base+'/pantry');
 await expect(page.locator('.photo-privacy')).toHaveText(notice);
 await page.getByLabel('Take or upload an ingredient photo').setInputFiles({name:'photo.png',mimeType:'image/png',buffer:photo});
 expect(reviews).toBe(0); // File selection never transmits a photo.
 await page.getByRole('button',{name:'Review photo',exact:true}).click();
 await expect(page.getByRole('heading',{name:'Review photo suggestions'})).toBeVisible();
 await expect(page.locator('.pantry-chips li')).toHaveCount(0);
 await expect(page.getByRole('button',{name:'Confirm photo ingredients'})).toBeDisabled();
 expect(confirmations).toBe(0);
 await page.getByRole('button',{name:'Accept banana',exact:true}).click();
 await page.locator('#photo-name-0').fill('green banana');
 await page.getByRole('button',{name:'Confirm photo ingredients'}).click();
 await expect(page.locator('.pantry-chips')).toContainText('green banana');
 expect(reviews).toBe(1);expect(confirmations).toBe(1);
 // A missing processing policy must prevent hosted upload.
 await page.route('**/function/photo_processing_notice',r=>r.fulfill({status:503,body:'offline'}));
 await page.reload();
 await expect(page.locator('.photo-privacy')).toContainText('processing details are unavailable');
 await page.getByLabel('Take or upload an ingredient photo').setInputFiles({name:'photo.png',mimeType:'image/png',buffer:photo});
 await expect(page.getByRole('button',{name:'Review photo',exact:true})).toBeDisabled();
 expect(reviews).toBe(1);expect(errors).toEqual([]);
 console.log('PASS: hosted disclosure before upload, no automatic sending/mutation, edited explicit confirmation, policy failure blocks upload. Remote calls mocked.');
}finally{await browser.close();}
