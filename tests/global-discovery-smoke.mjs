import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {installModelFixtures} from './browser-fixtures.mjs';
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';
const browser=await chromium.launch();const page=await browser.newPage({viewport:{width:1440,height:1000}});
const errors=[];page.on('pageerror',e=>errors.push(e.message));const state=await installModelFixtures(page);
try{
 await page.goto(`${base}/explore`);
 await expect(page.locator('.region-choice-grid button')).toHaveCount(15);
 await page.getByLabel('Describe your ingredients').fill('I have potatoes, eggs, spinach and onions.');
 await page.getByRole('button',{name:'Review ingredients',exact:true}).click();
 await expect(page.getByLabel('Edit proposed ingredient names')).toHaveValue('egg, onion, potato, spinach');
 await expect(page.locator('.pantry-chips li')).toHaveCount(0);expect(state.calls).toHaveLength(0);
 await page.getByRole('button',{name:'Confirm & find meals',exact:true}).click();
 await expect(page.locator('.meal-card')).toHaveCount(5);await expect(page.getByRole('heading',{name:'Your five meal choices'})).toBeVisible();
 await expect(page.locator('.pantry-chips li')).toHaveCount(4);expect(state.prepares).toHaveLength(0);
 const count=state.calls.length;
 await page.getByRole('link',{name:'Discover worldwide',exact:true}).click();
 await expect(page.getByRole('heading',{level:1})).toContainText('surprise you');
 await expect(page.locator('.pantry-chips li')).toHaveCount(4);expect(state.calls).toHaveLength(count);
 await expect(page.locator('.region-choice-grid')).toHaveCount(0);
 await page.getByRole('button',{name:'Find five meals',exact:true}).click();
 await expect(page.locator('.meal-card')).toHaveCount(5);expect(state.calls.at(-1)).toMatchObject({mode:'discover',region_key:'',tradition_key:'',demo:false,ingredients:['egg','onion','potato','spinach']});
 expect(new Set(await page.locator('.meal-card .seed-meta').allTextContents()).size).toBe(5);
 await page.locator('.meal-card').first().getByRole('button',{name:'Choose this meal'}).click();
 await expect(page).toHaveURL(`${base}/recipes/gamja-jeon-demo`);expect(state.prepares).toHaveLength(1);
 await expect(page.locator('.detail-ingredients')).toContainText('In pantry');
 const beforeBack=state.calls.length;await page.goBack();
 await expect(page.locator('.meal-card')).toHaveCount(5);expect(state.calls).toHaveLength(beforeBack);expect(state.restores.length).toBeGreaterThan(0);
 await page.reload();await expect(page.locator('.meal-card')).toHaveCount(5);expect(state.calls).toHaveLength(beforeBack);
 state.partial=true;await page.getByRole('button',{name:'Find five meals',exact:true}).click();
 await expect(page.locator('.meal-card')).toHaveCount(3);
 for(const button of await page.locator('.meal-card button').all()) await expect(button).toBeDisabled();
 expect(state.prepares).toHaveLength(1);
 state.partial=false;await page.getByRole('button',{name:'Retry discovery',exact:true}).click();await expect(page.locator('.meal-card')).toHaveCount(5);
 for(const width of [390,320]){await page.setViewportSize({width,height:900});expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);}
 expect(errors).toEqual([]);
 console.log('PASS: natural-language review/confirmation, one shared pantry, worldwide variety, exactly-five selection gate, selected-only preparation, recipe/back/reload recovery and mobile layout. All inference mocked.');
}finally{await browser.close();}
