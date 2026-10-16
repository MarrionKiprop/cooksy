import { chromium, expect } from '../.jac/client/node_modules/@playwright/test/index.mjs';
import { mkdir } from 'node:fs/promises';
const baseURL = process.env.COOKSY_TEST_URL || 'http://localhost:8000';
const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const errors = [];
const requests = [];
page.on('pageerror', error => errors.push(error.message));
page.on('response', response => { if (response.url().includes('/function/match_pantry')) requests.push(response.status()); });
const input = page.getByLabel('Ingredient names', { exact: true });
const submit = page.getByRole('button', { name: 'Add & find meals' });
try {
  await page.goto(`${baseURL}/pantry`);
  await expect(submit).toBeEnabled();
  await expect(page.locator('.match-card')).toHaveCount(0);
  await submit.click();
  await expect(page.locator('.pantry-notice')).toContainText('Add at least one ingredient');
  await input.fill(' POTATOES, potato,\nEggs, oil');
  await submit.click();
  await expect(page.locator('.pantry-chips li')).toHaveCount(3);
  await expect(page.locator('.match-card')).toHaveCount(8);
  expect(requests).toContain(200);
  await expect(page.locator('.match-card').first()).toContainText('Tamagoyaki');
  await expect(page.locator('.match-card').first().locator('.coverage-badge')).toHaveText('100% essential coverage');
  await page.locator('.match-card').first().locator('summary').click();
  await expect(page.locator('.match-card').first()).toContainText('Optional missing: soy sauce');
  await expect(page.locator('.match-card').first()).toContainText('Your amounts have not been checked');
  await page.reload();
  await expect(page.locator('.pantry-chips li')).toHaveCount(3);
  await expect(page.locator('.match-card')).toHaveCount(8);
  await page.getByRole('button', { name: 'Remove cooking oil', exact: true }).click();
  await expect(page.locator('.pantry-chips li')).toHaveCount(2);
  await expect(page.locator('.match-card').first().locator('.coverage-badge')).toHaveText('50% essential coverage');
  await page.getByLabel('Region', { exact: true }).selectOption('east-asia');
  await expect(page.locator('.match-card')).toHaveCount(2);
  await input.fill('2 onions, spinach');
  await submit.click();
  await expect(page.locator('.pantry-notice')).toContainText('2 onions');
  await expect(page.locator('.pantry-chips')).toContainText('spinach');
  await expect(page.locator('.pantry-chips')).not.toContainText('2 onions');
  await page.getByLabel('Region', { exact: true }).selectOption('east-africa');
  await expect(page.locator('.match-card')).toHaveCount(2);
  await expect(submit).toBeEnabled();
  const sukuma = page.locator('.match-card').filter({ has: page.getByRole('heading', { name: 'Sukuma wiki' }) });
  await sukuma.locator('summary').click();
  await expect(sukuma).toContainText('Possible swap: spinach for kale');
  await expect(sukuma).toContainText('The required ingredient stays marked missing');
  await page.setViewportSize({ width: 390, height: 844 });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  if (process.env.COOKSY_SCREENSHOTS) {
    await mkdir('/tmp/cooksy-m3-screenshots', { recursive: true });
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: '/tmp/cooksy-m3-screenshots/m3-pantry-mobile.png', fullPage: true });
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: '/tmp/cooksy-m3-screenshots/m3-pantry-desktop.png', fullPage: true });
  }

  // New browser contexts have independent session storage and no server pantry state.
  const otherContext = await browser.newContext();
  const other = await otherContext.newPage();
  await other.goto(`${baseURL}/pantry`);
  await expect(other.getByRole('button', { name: 'Add & find meals' })).toBeEnabled();
  await expect(other.locator('.pantry-chips li')).toHaveCount(0);
  await otherContext.close();

  await page.route('**/function/match_pantry', route => route.fulfill({ status: 503, contentType: 'application/json', body: JSON.stringify({ ok: false, error: { message: 'Test unavailable' } }) }));
  await input.fill('tomato');
  await submit.click();
  await expect(page.getByRole('alert')).toContainText('Your ingredients are still here');
  await expect(input).toHaveValue('tomato');
  await page.unroute('**/function/match_pantry');
  await page.getByRole('button', { name: 'Retry matching' }).click();
  await expect(page.getByRole('alert')).toHaveCount(0);
  await expect(page.locator('.pantry-chips li')).toHaveCount(3); // Retry uses committed pantry; draft stays unsubmitted.
  await expect(input).toHaveValue('tomato');
  await page.getByRole('button', { name: 'Clear pantry', exact: true }).click();
  await expect(page.locator('.pantry-chips li')).toHaveCount(0);
  await expect(page.locator('.match-card')).toHaveCount(0);
  await page.reload();
  await expect(submit).toBeEnabled();
  await expect(page.locator('.pantry-chips li')).toHaveCount(0);

  // Disabled storage must not prevent a working in-memory pantry.
  const blockedContext = await browser.newContext();
  await blockedContext.addInitScript(() => {
    Object.defineProperty(window, 'sessionStorage', { get() { throw new Error('Storage disabled for test'); } });
  });
  const blocked = await blockedContext.newPage();
  await blocked.goto(`${baseURL}/pantry`);
  await expect(blocked.getByRole('button', { name: 'Add & find meals' })).toBeEnabled();
  await expect(blocked.locator('.storage-note')).toContainText('Tab storage is unavailable');
  await blocked.getByLabel('Ingredient names', { exact: true }).fill('potato, oil');
  await blocked.getByRole('button', { name: 'Add & find meals' }).click();
  await expect(blocked.locator('.match-card')).toHaveCount(8);
  await blockedContext.close();
  expect(errors).toEqual([]);
  console.log('PASS: real pantry RPC, aliases/deduplication, transparent scores, remove/filter, invalid entries, substitution boundary, tab recovery/isolation, offline retry/draft retention, clear, blocked-storage fallback and mobile layout.');
} finally { await context.close(); await browser.close(); }
