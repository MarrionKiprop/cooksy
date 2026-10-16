import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {envelope} from './browser-fixtures.mjs';
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const browser=await chromium.launch();const page=await browser.newPage({viewport:{width:1440,height:1000}});
const errors=[];page.on('pageerror',e=>errors.push(e.message));
try{
 for(const route of ['/','/explore','/discover','/pantry']){
  await page.goto(base+route);await expect(page.locator('.connection [role="status"]')).toHaveText('Connected');
  expect(await page.locator('body').innerText()).not.toMatch(/DEVELOPMENT PREVIEW|graph memory|GPT-4\.1|later milestone|process cache|ready to try/);
 }
 const source='OpenAI gpt-4.1-mini · structured culinary proposal · 2026-10-16T21:04:51.806366+00:00';
 await page.route('**/function/get_recipe',async route=>{const response=await route.fetch();const body=await response.json();body.data.result.recipe.key='ai-copy-check';body.data.result.recipe.provenance=source;body.data.result.recipe.tradition='Kenyan';body.data.result.recipe.region='East Africa';await route.fulfill({response,json:body});});
 await page.route('**/function/recipe_nutrition',route=>route.fulfill({contentType:'application/json',body:envelope({status:'unavailable',servings:2,matched:0,total_items:3,values:[],items:[],disclosure:'Reference estimates only.'})}));
 await page.route('**/function/serving_preview',route=>route.fulfill({contentType:'application/json',body:envelope({status:'not_requested',image:'',model:'SDXL',provider:'off',message:'',prompt:'',cache_key:'',created_at:'',seed:0,cached:false,label:'AI-generated serving preview; illustrative, not an exact photograph.'})}));
 await page.goto(base+'/recipes/gamja-jeon-demo');
 await expect(page.locator('.recipe-kind')).toHaveText('AI-generated recipe');
 await expect(page.getByText('Source: '+source,{exact:true})).not.toBeVisible();
 const visible=await page.locator('body').innerText();expect(visible).not.toMatch(/needs verification|independent verification|A little context|2026-10-16T|gpt-4\.1/);
 const info=page.getByText('Recipe information',{exact:true});await info.focus();await info.press('Enter');
 await expect(page.getByText('Source: '+source,{exact:true})).toBeVisible();
 for(const width of [390,320]){await page.setViewportSize({width,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);}
 expect(errors).toEqual([]);console.log('PASS: normal screens have product copy, concise AI label remains, provenance is secondary and keyboard accessible, mobile layout intact. Inference mocked.');
}finally{await browser.close();}
