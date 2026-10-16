import {chromium,expect} from '../.jac/client/node_modules/@playwright/test/index.mjs';
import {createRequire} from 'node:module';
import {writeFile} from 'node:fs/promises';
const require=createRequire(new URL('../.jac/client/package.json',import.meta.url));
const axePath=require.resolve('axe-core/axe.min.js');
const browser=await chromium.launch();const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'});
const base=process.env.COOKSY_TEST_URL||'http://localhost:8000';const findings=[];
try{
 for(const route of ['/','/explore','/discover','/pantry','/recipes/gamja-jeon-demo','/cook-along','/missing-kitchen']){
  await page.goto(base+route);await expect(page.locator('main h1')).toHaveCount(1);
  if(route==='/pantry'){
   await page.getByLabel('Describe your ingredients').fill('potato, salt');await page.getByRole('button',{name:'Review ingredients',exact:true}).click();await expect(page.getByLabel('Edit proposed ingredient names')).toBeVisible();
  }
  if(route.includes('/recipes/')){
   await expect(page.locator('.nutrition-table')).toBeVisible();
   const summary=page.getByText('References, assumptions and missing amounts',{exact:true});await summary.focus();await expect(summary).toBeFocused();await summary.press('Enter');await expect(page.locator('.nutrition-sources')).toHaveAttribute('open','');
   await page.getByRole('button',{name:'View sample layout',exact:true}).click();await expect(page.locator('.preview-demo')).toBeVisible();
  }
  if(route==='/cook-along')await expect(page.locator('.active-step')).toBeVisible();
  await page.addScriptTag({path:axePath});
  const results=await page.evaluate(async()=>await window.axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa','best-practice']}}));
  const violations=results.violations.map(v=>({id:v.id,impact:v.impact,help:v.help,nodes:v.nodes.map(n=>({target:n.target,summary:n.failureSummary}))}));
  findings.push({route,violations,incomplete:results.incomplete.map(v=>v.id),incomplete_details:results.incomplete.map(v=>({id:v.id,nodes:v.nodes.map(n=>({target:n.target,summary:n.failureSummary}))}))});
  if(route.includes('/recipes/')){await page.getByRole('button',{name:'Start cook-along',exact:true}).click();await expect(page).toHaveURL(base+'/cook-along');await expect(page.locator('.active-step')).toBeVisible();}
 }
 await writeFile('/tmp/cooksy-m8-accessibility.json',JSON.stringify(findings,null,2));
 const problems=findings.filter(f=>f.violations.length);expect(problems,JSON.stringify(problems,null,2)).toEqual([]);
 console.log('PASS: axe WCAG A/AA and best-practice checks on seven routes. Incomplete/manual checks recorded separately; not a full accessibility certification.');
}finally{await browser.close();}
