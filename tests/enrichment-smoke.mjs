import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {installModelFixtures,envelope} from './browser-fixtures.mjs';
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const browser=await chromium.launch();const context=await browser.newContext({viewport:{width:1440,height:1000}});
await context.addInitScript(()=>sessionStorage.setItem('cooksy.pantry.v1','cooking oil|potato'));
const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));const state=await installModelFixtures(page,{allowRealDemo:true});state.partial=true;
try{
 await page.goto(`${base}/explore`);await expect(page.getByRole('button',{name:'Find five meals',exact:true})).toBeEnabled();
 await page.getByRole('button',{name:'Find five meals',exact:true}).click();await expect(page.locator('.meal-card')).toHaveCount(3);
 await page.getByRole('button',{name:'Try demo choices',exact:true}).click();await expect(page.locator('.meal-card')).toHaveCount(5);
 await expect(page.locator('.demo-disclosure')).toContainText('Developer demo fixtures');
 await expect(page.locator('.meal-card').first()).toContainText('Gamja-jeon');
 const before=state.calls.length;await page.reload();await expect(page.locator('.meal-card')).toHaveCount(5);expect(state.calls).toHaveLength(before);
 await page.locator('.meal-card').first().getByRole('button').click();await expect(page).toHaveURL(`${base}/recipes/gamja-jeon-demo`);
 await page.getByRole('button',{name:'Start cook-along',exact:true}).click();await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
 await page.route('**/function/cooking_help',async route=>{
  const data=route.request().postDataJSON();expect(data.current_sequence).toBe(1);expect(data.recipe_key).toBe('gamja-jeon-demo');
  await route.fulfill({status:200,contentType:'application/json',body:envelope({quotes:['Grate the potato'],status:'grounded',message:'Quoted from this recipe’s current step.',recipe_key:data.recipe_key,sequence:1})});
 });
 await page.getByLabel('Question about this step').fill('What do I grate?');await page.getByRole('button',{name:'Ask about this step'}).click();await expect(page.locator('.step-help blockquote')).toHaveText('Grate the potato');
 await page.getByRole('button',{name:'Mark done & continue'}).click();await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');await expect(page.locator('.step-help blockquote')).toHaveCount(0);
 await page.unroute('**/function/cooking_help');await page.route('**/function/cooking_help',route=>route.fulfill({status:503,body:'Unavailable'}));
 await page.getByLabel('Question about this step').fill('How?');await page.getByRole('button',{name:'Ask about this step'}).click();await expect(page.locator('.step-help')).toContainText('Help is unavailable');await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
 expect(errors).toEqual([]);console.log('PASS: explicit five-choice demo fallback and restoration use real graph RPC; recipe selection/cooking real; grounded-help mock/reset/failure preservation. No paid provider calls.');
}finally{await context.close();await browser.close();}
