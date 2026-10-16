import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {installModelFixtures} from './browser-fixtures.mjs';
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const browser=await chromium.launch();const context=await browser.newContext();await context.addInitScript(()=>sessionStorage.setItem('cooksy.pantry.v1','cooking oil|egg|potato'));
const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));const state=await installModelFixtures(page);
try{
 await page.goto(`${base}/pantry`);await expect(page.locator('.region-choice-grid button')).toHaveCount(15);await expect(page.locator('.pantry-chips li')).toHaveCount(3);expect(state.calls).toHaveLength(0);
 const response=await page.request.post(`${base}/function/culinary_regions`,{data:{}});const data=(await response.json()).data.result;
 for(const region of data.regions){
  await page.getByRole('button',{name:region.name,exact:true}).click();
  await expect.poll(()=>state.calls.at(-1)?.region_key).toBe(region.key);await expect(page.locator('.meal-card')).toHaveCount(5);
  await expect(page.getByRole('button',{name:'Find five meals',exact:true})).toBeEnabled();
  expect(state.calls.at(-1).ingredients).toEqual(['cooking oil','egg','potato']);
 }
 await page.getByRole('button',{name:'West Africa',exact:true}).click();await expect(page.getByLabel('Culinary tradition')).toBeEnabled();
 await page.getByLabel('Culinary tradition').selectOption('nigerian');await expect.poll(()=>state.calls.at(-1)?.tradition_key).toBe('nigerian');
 await expect(page.locator('.meal-card')).toHaveCount(5);
 const before=state.calls.length;await page.reload();await expect(page.locator('.meal-card')).toHaveCount(5);expect(state.calls).toHaveLength(before);
 await expect(page.getByRole('button',{name:'West Africa',exact:true})).toHaveAttribute('aria-pressed','true');await expect(page.getByLabel('Culinary tradition')).toHaveValue('nigerian');
 for(const width of [390,320]){await page.setViewportSize({width,height:900});expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);}
 expect(errors).toEqual([]);console.log('PASS: all 15 regions feed canonical discovery scope, tradition filtering, shared confirmed names, no inference on reload, scope/result restoration and mobile layout. Inference mocked.');
}finally{await context.close();await browser.close();}
