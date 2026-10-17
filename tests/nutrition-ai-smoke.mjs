import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {envelope} from './browser-fixtures.mjs';
const browser=await chromium.launch();const page=await browser.newPage();
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const errors=[];page.on('pageerror',e=>errors.push(e.message));let calls=0;
try{
 const response=page.waitForResponse(r=>r.url().endsWith('/function/recipe_nutrition'));
 await page.route('**/function/estimate_recipe_nutrition',async route=>{
  calls++;
  if(calls===1)return route.fulfill({status:503,body:'offline'});
  const baseline=(await (await response).json()).data.result;
  const result=structuredClone(baseline);
  result.status='ai_estimate';result.matched=3;
  result.values[0].total=352.5;result.values[0].per_serving=176.2;
  const oil=result.items.find(i=>i.name==='cooking oil');oil.grams=13.5;oil.reason='AI assumptions: generic oil density 0.9 g/ml.';
  result.disclosure='Includes approximate AI estimates, not verified USDA values.';
  return route.fulfill({contentType:'application/json',body:envelope(result)});
 });
 await page.goto(base+'/recipes/gamja-jeon-demo');
 const panel=page.locator('.nutrition-panel');
 await expect(panel.getByRole('heading',{name:'Known-ingredient subtotal only'})).toBeVisible();
 expect(calls).toBe(0);
 const button=panel.getByRole('button',{name:'Estimate missing nutrition with AI'});
 await button.click();
 await expect(panel.getByText(/AI estimates are unavailable/)).toBeVisible();
 await expect(panel.getByRole('table')).toContainText('231 kcal');
 await button.click();
 await expect(panel.getByRole('heading',{name:'AI-assisted nutrition estimate'})).toBeVisible();
 await expect(panel.getByText(/not verified USDA values or measured meal nutrition/)).toBeVisible();
 await expect(panel.getByRole('table')).toContainText('352.5');
 await panel.getByText('References, assumptions and missing amounts',{exact:true}).click();
 await expect(panel.getByText(/AI assumptions: generic oil density/)).toBeVisible();
 for(const width of [390,320]){await page.setViewportSize({width,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);}
 await page.getByRole('button',{name:/Start cook-along/}).click();
 await expect(page).toHaveURL(base+'/cook-along');
 expect(calls).toBe(2);expect(errors).toEqual([]);
 console.log('PASS: AI nutrition only on explicit click, failure preserves reference subtotal, separate AI label/assumptions, responsive display, cooking remains usable. Inference mocked.');
}finally{await browser.close();}
