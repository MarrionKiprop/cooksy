import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {envelope} from './browser-fixtures.mjs';
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const browser=await chromium.launch();const page=await browser.newPage({viewport:{width:1440,height:1000}});
const errors=[];page.on('pageerror',e=>errors.push(e.message));
const calls=[];page.on('request',r=>{if(r.url().endsWith('/function/serving_preview'))calls.push(r.postDataJSON());});
try{
 await page.goto(base+'/recipes/gamja-jeon-demo');
 await expect(page.getByRole('heading',{name:'Picture your plate.'})).toBeVisible();
 await expect(page.locator('.serving-preview [role="status"]')).toContainText(/Nothing is generated automatically\.|DEMO: layout only/);
 expect(calls.every(c=>c.generate===false)).toBe(true);
 await page.getByRole('button',{name:'Generate serving preview',exact:true}).click();
 await expect(page.locator('.serving-preview [role="status"]')).toContainText('SDXL is not configured.');
 await expect(page.getByRole('button',{name:'Start cook-along',exact:false})).toBeEnabled();
 await page.getByRole('button',{name:'Try demo layout',exact:true}).click();
 await expect(page.getByRole('img',{name:'Demo plate layout; no AI image generated'})).toBeVisible();
 await expect(page.locator('.preview-demo')).toContainText('AI-generated serving preview; illustrative, not an exact photograph.');
 await page.getByText('About this preview', {exact:true}).click();
 await expect(page.locator('.preview-prompt')).toContainText('potato');
 await expect(page.locator('.preview-prompt')).toContainText('Gamja');
 await page.getByRole('button',{name:'Try demo layout',exact:true}).click();
 await expect(page.locator('.serving-preview details')).toContainText('Reused cached result');
 const before=calls.filter(c=>c.generate).length;
 await page.reload();await expect(page.locator('.preview-demo')).toBeVisible();
 expect(calls.filter(c=>c.generate)).toHaveLength(before);
 await page.route('**/function/serving_preview',route=>{const b=route.request().postDataJSON();if(b.generate)return route.fulfill({status:503,body:'offline'});return route.continue();});
 await page.getByRole('button',{name:'Generate serving preview',exact:true}).click();
 await expect(page.locator('.serving-preview [role="status"]')).toContainText('Your recipe and cooking progress are unchanged');
 await expect(page.locator('.preview-demo')).toBeVisible();
 await page.unroute('**/function/serving_preview');
 // A successful image envelope is mocked; no SDXL/paid provider request occurs.
 const image='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAYCAIAAAAUMWhjAAAAJklEQVR4nGNMmWbEQEvARFPTRy0YtWDUglELRi0YtWDUglELqAYAifcBXGHsQmkAAAAASUVORK5CYII=';
 await page.route('**/function/serving_preview',route=>{const b=route.request().postDataJSON();if(!b.generate)return route.continue();return route.fulfill({contentType:'application/json',body:envelope({status:'ready',image,model:'Browser fixture / not live SDXL',provider:'mock',message:'Mock success',prompt:'potato recipe',cache_key:'mock',created_at:'2026-10-16',seed:42,cached:false,label:'AI-generated serving preview; illustrative, not an exact photograph.'})});});
 await page.getByRole('button',{name:'Generate serving preview',exact:true}).click();
 await expect(page.locator('.serving-preview figure img')).toBeVisible();
 await expect(page.locator('.serving-preview figcaption')).toHaveText('AI-generated serving preview; illustrative, not an exact photograph.');
 for(const width of [390,320]){await page.setViewportSize({width,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);}
 await page.getByRole('button',{name:/Start cook-along/}).click();await expect(page).toHaveURL(base+'/cook-along');
 expect(errors).toEqual([]);console.log('PASS: selected-recipe preview only, no generation on load/reload, actual demo/cache RPC, unavailable/failure preservation, labelled mocked image success, mobile and cooking. No real provider calls.');
}finally{await browser.close();}
