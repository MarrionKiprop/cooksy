// Explicit opt-in: this makes up to three paid model requests. Never prints credentials.
if (process.env.COOKSY_LIVE_SMOKE !== '1') throw new Error('Set COOKSY_LIVE_SMOKE=1 for the optional paid provider check.');
const base = process.env.COOKSY_TEST_URL || 'http://localhost:8000';
async function rpc(name, data) {
  const response = await fetch(`${base}/function/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) });
  if (!response.ok) throw new Error(`${name}: HTTP ${response.status}`);
  const body = await response.json();
  return body.data.result;
}
const help = await rpc('cooking_help', { recipe_key: 'gamja-jeon-demo', current_sequence: 1, finished: false, version: 'cooksy-demo-v1', question: 'What should I grate?' });
console.log(`Live help: ${help.status}; ${help.quotes.length} checked quotations.`);
if (!['grounded', 'insufficient_context'].includes(help.status)) {
  console.log('Live provider unavailable. No discovery/preparation calls made.');
  process.exitCode = 2;
} else {
  const input = { ingredients: ['rice', 'tomato', 'onion', 'cooking oil', 'salt'], cuisine: 'Italian' };
  const result = await rpc('enrich', input);
  console.log(`Live discovery: ${result.status}; ${result.candidates.length} candidates.`);
  if (result.candidates.length === 5) {
    const reused = await rpc('enrich', input);
    if (reused.status !== 'graph') throw new Error('Five cached candidates did not skip model inference');
    console.log('Graph reuse: PASS, no enrichment model call.');
  }
  if (!result.candidates.length) {
    process.exitCode = 2;
  } else {
    const selection = await rpc('prepare_candidate', { recipe_key: result.candidates[0].key });
    console.log(`Selected preparation: ${selection.ready ? 'ready' : 'rejected/unavailable'}.`);
    if (selection.ready) {
      const selected = await rpc('get_recipe', { recipe_key: selection.key, ingredients: input.ingredients });
      if (!selected?.recipe?.steps?.length) throw new Error('Prepared recipe not reachable in next request');
      const cooking = await rpc('cook_session', { recipe_key: selection.key, current_sequence: 1, finished: false, action: 'start', version: selected.recipe.version });
      if (cooking.current_sequence !== 1) throw new Error('Generated recipe cooking session failed');
      console.log(`Selected graph recipe and cooking: PASS (${selected.recipe.steps.length} steps).`);
    } else { process.exitCode = 2; }
  }
}
