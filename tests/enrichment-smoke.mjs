import { chromium, expect } from '../.jac/client/node_modules/@playwright/test/index.mjs';
const base = process.env.COOKSY_TEST_URL || 'http://localhost:8000';
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
const errors = [];
page.on('pageerror', error => errors.push(error.message));
try {
  await page.goto(`${base}/explore`);
  await expect(page.getByRole('heading', { name: 'What could your ingredients become?' })).toBeVisible();
  await page.getByLabel('Ingredients to discover with').fill('potatoes, oil');
  await page.getByRole('button', { name: 'Discover dishes', exact: true }).click();
  await expect(page.locator('.ai-message')).toContainText('Reused graph content', { timeout: 30000 });
  await expect(page.locator('.ai-candidate')).toHaveCount(5);
  await expect(page.locator('.ai-candidate').first()).toContainText('Gamja-jeon');
  await page.locator('.ai-candidate').first().getByRole('button').click();
  await expect(page).toHaveURL(`${base}/recipes/gamja-jeon-demo`);
  await page.getByRole('button', { name: 'Start cook-along', exact: true }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  // Exact response envelope copied from Jac RPC, deterministic UI test; real model parsing is unit-tested.
  await page.route('**/function/cooking_help', async route => {
    const body = route.request().postDataJSON();
    expect(body.current_sequence).toBe(1);
    expect(body.recipe_key).toBe('gamja-jeon-demo');
    await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ ok: true, type: 'response', error: null, data: { result: { quotes: ['Grate the potato'], status: 'grounded', message: 'Quoted from this recipe’s current step.', recipe_key: body.recipe_key, sequence: 1 }, reports: [] } }) });
  });
  await page.getByLabel('Question about this step').fill('What do I grate?');
  await page.getByRole('button', { name: 'Ask about this step' }).click();
  await expect(page.locator('.step-help blockquote')).toHaveText('Grate the potato');
  await page.getByRole('button', { name: 'Mark done & continue' }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
  await expect(page.locator('.step-help blockquote')).toHaveCount(0);
  await page.unroute('**/function/cooking_help');
  await page.route('**/function/cooking_help', route => route.fulfill({ status: 503, body: 'Unavailable' }));
  await page.getByLabel('Question about this step').fill('How?');
  await page.getByRole('button', { name: 'Ask about this step' }).click();
  await expect(page.locator('.step-help')).toContainText('Help is unavailable');
  await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
  await page.setViewportSize({ width: 320, height: 900 });
  await page.goto(`${base}/explore`);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  await page.route('**/function/enrich', route => route.fulfill({ status: 503, body: 'Unavailable' }));
  await page.getByRole('button', { name: 'Discover dishes', exact: true }).click();
  await expect(page.locator('.ai-message')).toContainText('Discovery is unavailable');
  expect(errors).toEqual([]);
  console.log('PASS M5: real graph-first RPC and navigation; grounded-help UI mock; step reset; failure preservation; 320px layout; no browser errors.');
} finally { await browser.close(); }
