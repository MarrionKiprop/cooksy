import { chromium, expect } from '../.jac/client/node_modules/@playwright/test/index.mjs';
import { mkdir } from 'node:fs/promises';
const baseURL = process.env.COOKSY_TEST_URL || 'http://localhost:8000';
const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const errors = [];
const calls = [];
page.on('pageerror', error => errors.push(error.message));
page.on('response', response => { if (response.url().includes('/function/cook_session')) calls.push(response.status()); });
try {
  const incomplete = await page.request.post(`${baseURL}/function/cook_session`, { data: { recipe_key: 'gamja-jeon-demo' } });
  expect([400, 422]).toContain(incomplete.status());
  await page.goto(`${baseURL}/explore`);
  const pancake = page.locator('.seed-card').filter({ has: page.getByRole('heading', { name: 'Gamja-jeon', exact: true }) });
  await pancake.getByRole('link', { name: 'View recipe' }).click();
  await expect(page).toHaveURL(`${baseURL}/recipes/gamja-jeon-demo`);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Gamja-jeon');
  await expect(page.locator('.detail-ingredients')).toContainText('300 g');
  await expect(page.locator('.detail-ingredients')).toContainText('Essential · missing');
  await expect(page.locator('.method-list li')).toHaveCount(2);
  await expect(page.locator('.recipe-context')).toContainText('Korean');
  await page.reload();
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Gamja-jeon');
  if (process.env.COOKSY_SCREENSHOTS) {
    await mkdir('/tmp/cooksy-m4-screenshots', { recursive: true });
    await page.screenshot({ path: '/tmp/cooksy-m4-screenshots/m4-recipe-desktop.png', fullPage: true });
  }
  await page.getByRole('button', { name: 'Start cook-along', exact: true }).click();
  await expect(page).toHaveURL(`${baseURL}/cook-along`);
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  await expect(page.getByRole('button', { name: 'Back a step' })).toBeDisabled();
  await page.getByRole('button', { name: 'Mark done & continue' }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
  await expect(page.getByLabel('Cooking progress')).toHaveAttribute('value', '1');
  await page.reload();
  await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
  expect(calls).toContain(200);
  await page.getByRole('button', { name: 'Back a step' }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  await page.getByRole('button', { name: 'Mark done & continue' }).click();
  await page.getByRole('button', { name: 'Finish session' }).click();
  await expect(page.locator('.active-step')).toContainText('SESSION COMPLETE');
  await expect(page.getByLabel('Cooking progress')).toHaveAttribute('value', '2');
  await page.reload();
  await expect(page.locator('.active-step')).toContainText('SESSION COMPLETE');
  await page.getByRole('button', { name: 'Review final step' }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 2 OF 2');
  await page.getByRole('button', { name: 'Restart this recipe' }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  await page.getByRole('link', { name: 'View recipe' }).click();
  await page.getByRole('link', { name: 'Cook along', exact: true }).click();
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  await page.setViewportSize({ width: 390, height: 844 });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  if (process.env.COOKSY_SCREENSHOTS) {
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: '/tmp/cooksy-m4-screenshots/m4-cooking-mobile.png', fullPage: true });
  }
  // A failed next request must not overwrite the saved current step.
  await page.route('**/function/cook_session', route => route.fulfill({ status: 503, contentType: 'application/json', body: JSON.stringify({ ok: false, error: { message: 'Test offline' } }) }));
  await page.getByRole('button', { name: 'Mark done & continue' }).click();
  await expect(page.getByRole('alert')).toContainText('last saved step is unchanged');
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  await page.unroute('**/function/cook_session');
  await page.getByRole('button', { name: 'Retry session' }).click();
  await expect(page.getByRole('alert')).toHaveCount(0);
  await expect(page.locator('.active-step')).toContainText('STEP 1 OF 2');
  await page.getByRole('button', { name: 'End session', exact: true }).click();
  await expect(page.locator('.cook-session')).toHaveCount(0);
  await page.reload();
  await expect(page.locator('.empty-kitchen')).toBeVisible();
  await page.goto(`${baseURL}/recipes/not-a-recipe`);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Recipe not found.');

  const isolated = await browser.newContext();
  const other = await isolated.newPage();
  await other.goto(`${baseURL}/cook-along`);
  await expect(other.locator('.empty-kitchen')).toBeVisible();
  await other.evaluate(() => sessionStorage.setItem('cooksy.cooking.v1', 'cooksy-demo-v1|gamja-jeon-demo|999|0'));
  await other.reload();
  await expect(other.getByRole('alert')).toBeVisible();
  await other.getByRole('button', { name: 'Discard saved session' }).click();
  await expect(other.locator('.empty-kitchen')).toBeVisible();
  await isolated.close();

  const blocked = await browser.newContext();
  await blocked.addInitScript(() => { Object.defineProperty(window, 'sessionStorage', { get() { throw new Error('blocked'); } }); });
  const blockedPage = await blocked.newPage();
  await blockedPage.goto(`${baseURL}/recipes/gamja-jeon-demo`);
  await blockedPage.getByRole('button', { name: 'Start cook-along', exact: true }).click();
  await expect(blockedPage.locator('.active-step')).toContainText('STEP 1 OF 2');
  await expect(blockedPage.locator('.storage-note')).toContainText('Tab storage is unavailable');
  await blocked.close();
  expect(errors).toEqual([]);
  console.log('PASS: selected recipe/deep link, real cooking RPC, next/back/finish/restart, reload and route recovery, mobile layout, failed-action preservation, end/unknown recipe, isolated/corrupt sessions and blocked-storage fallback.');
} finally { await context.close(); await browser.close(); }
