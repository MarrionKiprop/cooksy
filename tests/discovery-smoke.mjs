// Run after the Jac server is ready: node tests/discovery-smoke.mjs
import { chromium, expect } from '../.jac/client/node_modules/@playwright/test/index.mjs';
import { mkdir } from 'node:fs/promises';

const baseURL = process.env.COOKSY_TEST_URL || 'http://localhost:8000';
const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const errors = [];
const responses = [];
page.on('pageerror', error => errors.push(error.message));
page.on('response', response => {
  if (response.url().includes('/function/discover')) responses.push(response.status());
});
try {
  await page.goto(`${baseURL}/explore`);
  await expect(page.locator('.seed-card')).toHaveCount(8);
  await expect(page.locator('.demo-disclosure')).toContainText('No AI inference or pantry matching');
  expect(responses).toContain(200);
  await page.getByRole('button', { name: /East Asia/ }).click();
  await expect(page.locator('.seed-card')).toHaveCount(2);
  await expect(page.locator('.seed-card h3')).toHaveText(['Gamja-jeon', 'Tamagoyaki']);
  await page.getByLabel('Kitchen tradition').selectOption('korean');
  await expect(page.locator('.seed-card')).toHaveCount(1);
  await page.locator('.seed-card summary').click();
  await expect(page.locator('.requirement-list')).toContainText('300 g');
  await expect(page.locator('.requirement-list')).toContainText('optional');
  await expect(page.locator('.seed-card ol li')).toHaveText([
    'Grate the potato and drain excess water.',
    'Form a thin pancake and pan-fry in oil until cooked through and golden.'
  ]);
  await page.locator('.graph-trace summary').click();
  await expect(page.locator('.graph-trace')).toContainText('Gamja-jeon');
  await expect(page.locator('.graph-trace li span')).toContainText(['catalogue', 'region', 'tradition', 'recipe', 'ingredient']);

  // Reset must clear a tradition that belongs to the previous region.
  await page.getByRole('button', { name: /East Africa/ }).click();
  await expect(page.getByLabel('Kitchen tradition')).toHaveValue('');
  await expect(page.locator('.seed-card')).toHaveCount(2);
  await expect(page.locator('.seed-card h3')).toHaveText(['Sukuma wiki', 'Mchicha']);
  await expect(page.getByLabel('Kitchen tradition').locator('option')).toHaveCount(3);
  await page.getByRole('button', { name: 'All regions', exact: true }).click();
  await expect(page.locator('.seed-card')).toHaveCount(8);

  // Validate the real HTTP contract, including an empty filter result.
  const response = await page.request.post(`${baseURL}/function/discover`, { data: { region_key: 'unknown', tradition_key: '' } });
  expect(response.status()).toBe(200);
  const body = await response.json();
  expect(body.ok).toBe(true);
  expect(body.data.result.mode).toBe('demo_graph');
  expect(body.data.result.recipes).toEqual([]);
  expect(body.data.result.regions).toHaveLength(4);

  await page.setViewportSize({ width: 390, height: 844 });
  await expect(page.locator('.seed-card')).toHaveCount(8);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  if (process.env.COOKSY_SCREENSHOTS) {
    const dir = '/tmp/cooksy-m2-screenshots';
    await mkdir(dir, { recursive: true });
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: `${dir}/m2-explore-mobile.png`, fullPage: true });
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: `${dir}/m2-explore-desktop.png`, fullPage: true });
  }

  const retryContext = await browser.newContext();
  const retryPage = await retryContext.newPage();
  await retryPage.route('**/function/discover', route => route.fulfill({ status: 503, contentType: 'application/json', body: JSON.stringify({ ok: false, error: { message: 'Test unavailable' } }) }));
  await retryPage.goto(`${baseURL}/explore`);
  await expect(retryPage.getByRole('alert')).toContainText('We couldn’t reach the demo kitchen.');
  await retryPage.unroute('**/function/discover');
  await retryPage.getByRole('button', { name: 'Retry discovery' }).click();
  await expect(retryPage.locator('.seed-card')).toHaveCount(8);
  await expect(retryPage.getByRole('alert')).toHaveCount(0);
  await retryContext.close();
  expect(errors).toEqual([]);
  console.log('PASS: actual discovery RPC, 8→2→1 filtering, edge quantities/optional flags, ordered steps, actual trace, region-reset, empty HTTP result, mobile layout, failure/retry and no browser runtime errors.');
} finally {
  await context.close();
  await browser.close();
}
