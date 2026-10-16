import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {installModelFixtures} from './browser-fixtures.mjs';
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const browser=await chromium.launch();const page=await browser.newPage({viewport:{width:1440,height:1000}});
const errors=[];page.on('pageerror',e=>errors.push(e.message));if(!process.env.COOKSY_OFFLINE_JOURNEY){const state=await installModelFixtures(page,{allowRealDemo:true});state.partial=true;}
await page.unroute('**/function/review_ingredients');
try{
 await page.goto(base+'/pantry');await page.getByLabel('Describe your ingredients').fill('potato, cooking oil, salt');
 await page.getByRole('button',{name:'Review ingredients',exact:true}).click();
 await expect(page.getByLabel('Edit proposed ingredient names')).toHaveValue('cooking oil, potato, salt');
 await page.getByRole('button',{name:'Confirm & find meals',exact:true}).click();await expect(page.locator('.pantry-chips li')).toHaveCount(3);
 await page.getByRole('link',{name:'Discover worldwide',exact:true}).click();await page.getByRole('button',{name:'Find five meals',exact:true}).click();
 await expect(page.locator('.meal-card')).toHaveCount(process.env.COOKSY_OFFLINE_JOURNEY?0:3);await page.getByRole('button',{name:'Browse sample recipes',exact:true}).click();await expect(page.locator('.meal-card')).toHaveCount(5);
 await page.locator('.meal-card').first().getByRole('button').click();await expect(page).toHaveURL(base+'/recipes/gamja-jeon-demo');
 await expect(page.locator('.nutrition-panel')).toContainText('Known-ingredient subtotal only');
 await expect(page.locator('.nutrition-coverage')).toContainText('2 of 3');
 await expect(page.locator('.nutrition-table')).toContainText('115.5 kcal');
 await page.getByText('References, assumptions and missing amounts',{exact:true}).click();
 await expect(page.locator('.nutrition-sources')).toContainText('cooking oil');
 await expect(page.locator('.nutrition-sources a').first()).toHaveAttribute('href',/fdc.nal.usda.gov/);
 await page.getByRole('button',{name:'View sample layout',exact:true}).click();await expect(page.locator('.preview-demo')).toBeVisible();
 await page.route('**/function/recipe_nutrition',route=>route.fulfill({status:503,body:'offline'}));await page.reload();
 await expect(page.locator('.nutrition-panel')).toContainText('Nutrition estimates are unavailable');
 await expect(page.getByRole('button',{name:'Start cook-along',exact:true})).toBeEnabled();
 await page.unroute('**/function/recipe_nutrition');await page.getByRole('button',{name:'Retry nutrition',exact:true}).click();await expect(page.locator('.nutrition-table')).toBeVisible();
 for(const width of [390,320]){await page.setViewportSize({width,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);}
 await page.getByRole('button',{name:'Start cook-along',exact:true}).click();await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
 await page.getByRole('button',{name:/Mark done & continue/}).click();await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
 await page.reload();await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
 await page.getByRole('button',{name:'Finish session',exact:true}).click();await expect(page.locator('.active-step')).toContainText('SESSION COMPLETE');
 expect(errors).toEqual([]);console.log('PASS: typed pantry → worldwide discovery → real explicit five-choice demo → selected recipe → sourced partial nutrition/retry → preview demo → cook-along/reload/finish; mobile. No paid calls.');
}finally{await browser.close();}
