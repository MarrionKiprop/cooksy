// Browser-only fixtures. All normal-flow inference and preparation are intercepted.
export const envelope = result => JSON.stringify({ok:true,type:'response',data:{result,reports:[]},error:null});
const scopes = {
 'east-africa':['East Africa','Kenyan'],'north-africa':['North Africa','Moroccan'],'west-africa':['West Africa','Nigerian'],
 'southern-africa':['Southern Africa','South African'],'middle-east':['Middle East','Levantine'],'south-asia':['South Asia','Indian'],
 'east-asia':['East Asia','Japanese'],'southeast-asia':['Southeast Asia','Thai'],'central-asia':['Central Asia','Uzbek'],
 'mediterranean':['Mediterranean','Greek'],'western-europe':['Western Europe','French'],'eastern-europe':['Eastern Europe','Polish'],
 'latin-america':['Latin America','Mexican'],'north-america':['North America','US Southern'],'caribbean':['Caribbean','Jamaican']
};
export function fixturePlan(body,count=5){
 const worldwide=[['East Africa','Kenyan'],['East Asia','Japanese'],['South Asia','Indian'],['Mediterranean','Greek'],['Latin America','Mexican']];
 const pair=scopes[body.region_key]||['East Africa','Kenyan'];
 return {choices:Array.from({length:count},(_,i)=>({candidate:{key:`ai-ui-${body.region_key||body.mode}-${body.tradition_key||'any'}-${i}`,name:`Fixture meal ${i+1}`,description:'Browser fixture; not live AI output.',region:body.mode==='discover'?worldwide[i%5][0]:pair[0],tradition:body.tradition_key|| (body.mode==='discover'?worldwide[i%5][1]:pair[1]),minutes:15+i,score:i<3?100:50,missing:i<3?[]:['tomato'],provenance:'Browser mock / no paid call',verification:'AI-generated candidate / needs verification',prepared:false},available:body.ingredients,optional:['salt'],readiness:i<3?'Cook now':'Almost ready'})),ready:count===5,status:count===5?'ready':'incomplete',message:count===5?'Five validated browser-fixture choices.':`${count} of 5 valid choices. Retry or broaden.`,mode:body.mode,region_key:body.region_key,tradition_key:body.tradition_key,demo:false,events:['Read graph and validated structured browser fixture.']};
}
export async function installModelFixtures(target,{allowRealDemo=false}={}){
 const state={calls:[],reviews:[],prepares:[],restores:[],partial:false,fail:false,expired:false,prepareFail:false,plans:new Map()};
 await target.route('**/function/review_ingredients',async route=>{
  const b=route.request().postDataJSON();state.reviews.push(b);
  const natural=b.text.startsWith('I have');
  const names=natural?['egg','onion','potato','spinach']:['cooking oil','egg','potato'];
  await route.fulfill({status:200,contentType:'application/json',body:envelope({names,uncertain:[],status:'review',message:natural?'AI review fixture: nothing saved yet.':'Review fixture: nothing saved yet.'})});
 });
 await target.route('**/function/recommend_meals',async route=>{
  const b=route.request().postDataJSON();state.calls.push(b);
  if(b.demo&&allowRealDemo) return route.continue();
  if(state.fail) return route.fulfill({status:503,body:'Fixture unavailable'});
  const result=fixturePlan(b,state.partial?3:5);
  state.plans.set(result.choices.map(c=>c.candidate.key).join('|'),result);
  await route.fulfill({status:200,contentType:'application/json',body:envelope(result)});
 });
 await target.route('**/function/restore_meals',async route=>{
  const b=route.request().postDataJSON();state.restores.push(b);
  if(b.demo&&allowRealDemo) return route.continue();
  const saved=state.plans.get(b.keys.join('|'));
  if(state.expired||!saved) return route.fulfill({status:410,body:'Fixture expired'});
  await route.fulfill({status:200,contentType:'application/json',body:envelope({...saved,status:'restored',message:'Restored five fixture choices; no inference.'})});
 });
 await target.route('**/function/prepare_candidate',async route=>{
  const b=route.request().postDataJSON();
  if(b.recipe_key.endsWith('-demo')&&allowRealDemo) return route.continue();
  state.prepares.push(b);
  await route.fulfill({status:200,contentType:'application/json',body:envelope({key:'gamja-jeon-demo',ready:!state.prepareFail,message:state.prepareFail?'Fixture preparation unavailable':'Selected recipe fixture'})});
 });
 return state;
}
