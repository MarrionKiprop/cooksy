import {chromium, expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
const base=process.env.COOKSY_TEST_URL || 'http://localhost:8000';
const browser=await chromium.launch();
const page=await browser.newPage({viewport:{width:1440,height:1000}});
const errors=[], calls=[];page.on('pageerror',e=>errors.push(e.message));
const candidate={key:'ai-browser-fixture',name:'Pantry discovery fixture',description:'Unverified browser fixture.',region:'East Asia',tradition:'Korean-inspired',minutes:20,score:100,missing:[],provenance:'Browser mock / no model call',verification:'AI-generated candidate / needs verification',prepared:false};
const envelope=result=>JSON.stringify({ok:true,type:'response',data:{result,reports:[]},error:null});
let fail=false;
await page.route('**/function/discover_pantry',async route=>{
 const data=route.request().postDataJSON();calls.push(data);
 if(fail) return route.fulfill({status:503,body:'Test unavailable'});
 await route.fulfill({status:200,contentType:'application/json',body:envelope({candidates:[candidate,{...candidate,key:'gamja-jeon-demo',name:'Gamja-jeon',prepared:true}],status:'enriched',message:'Mocked discovery succeeded.',events:[]})});
});
try{
 await page.goto(`${base}/pantry`);
 await expect(page.getByRole('button',{name:'Add & find meals'})).toBeEnabled();
 expect(calls).toHaveLength(0);
 await page.getByLabel('Ingredient names',{exact:true}).fill('Potatoes, eggs, oil');
 await page.getByRole('button',{name:'Add & find meals'}).click();
 await expect(page.locator('.pantry-discovery .ai-message')).toHaveText('Mocked discovery succeeded.');
 expect(calls[0]).toEqual({ingredients:['cooking oil','egg','potato'],cuisine:''});
 await expect(page.locator('.ai-candidate')).toHaveCount(1); // Existing prepared recipe is not duplicated.
 await page.getByLabel('Region',{exact:true}).selectOption('east-asia');
 await expect(page.locator('.pantry-discovery .ai-message')).toHaveText('Mocked discovery succeeded.');
 await expect.poll(()=>calls.at(-1)?.cuisine).toBe('East Asia'); // Send readable cuisine, never the region slug.
 await expect(page.locator('.match-card')).toHaveCount(2);
 await expect(page.locator('.ai-candidate')).toHaveCount(1);
 await page.getByLabel('Region',{exact:true}).selectOption('mediterranean');
 await expect.poll(()=>calls.at(-1)?.cuisine).toBe('Mediterranean');
 await expect(page.getByRole('button',{name:'Discover more dishes'})).toBeEnabled();
 const beforeReload=calls.length;
 await page.reload();
 await expect(page.locator('.pantry-chips li')).toHaveCount(3);
 await expect(page.getByRole('button',{name:'Discover more dishes'})).toBeEnabled();
 expect(calls).toHaveLength(beforeReload); // Restoring a tab never invokes the provider.
 fail=true;
 await page.getByRole('button',{name:'Discover more dishes'}).click();
 await expect(page.locator('.pantry-discovery .ai-message')).toContainText('AI discovery is unavailable');
 await expect(page.locator('.match-card')).toHaveCount(8);
 await expect(page.locator('.pantry-chips li')).toHaveCount(3);
 fail=false;
 await page.getByRole('button',{name:'Discover more dishes'}).click();
 await expect(page.locator('.ai-candidate')).toHaveCount(1);
 await page.setViewportSize({width:320,height:900});
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);
 await page.route('**/function/prepare_candidate',async route=>{
  expect(route.request().postDataJSON()).toEqual({recipe_key:'ai-browser-fixture'});
  await route.fulfill({status:200,contentType:'application/json',body:envelope({key:'gamja-jeon-demo',ready:true,message:'Mock selected preparation'})});
 });
 await page.getByRole('button',{name:'Prepare this recipe',exact:true}).click();
 await expect(page).toHaveURL(`${base}/recipes/gamja-jeon-demo`);
 await expect(page.getByRole('heading',{level:1})).toHaveText('Gamja-jeon');
 await page.goto(`${base}/pantry`);
 await page.getByRole('button',{name:'Clear pantry',exact:true}).click();
 await expect(page.locator('.ai-candidate')).toHaveCount(0);
 await expect(page.locator('.pantry-discovery')).toHaveCount(0);
 const beforeInvalid=calls.length;
 await page.getByLabel('Ingredient names',{exact:true}).fill('2 onions');
 await page.getByRole('button',{name:'Add & find meals'}).click();
 await expect(page.locator('.pantry-notice')).toContainText('2 onions');
 expect(calls).toHaveLength(beforeInvalid);
 await expect(page.locator('.pantry-discovery')).toHaveCount(0);
 await page.setViewportSize({width:320,height:900});
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);
 expect(errors).toEqual([]);
 console.log('PASS: pantry submission/region discovery, normalized names + readable scope, duplicate removal, no provider on reload, AI failure preserves saved pantry/matches, selected preparation/navigation, clear and 320px layout. All inference mocked.');
}finally{await browser.close();}
