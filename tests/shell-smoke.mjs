// Run against `jac run --dev`: node tests/shell-smoke.mjs
// Jac installs npm packages into .jac/client/node_modules.
import { chromium, expect } from '../.jac/client/node_modules/@playwright/test/index.mjs';
import { mkdir } from 'node:fs/promises';

const baseURL = process.env.COOKSY_TEST_URL || 'http://localhost:8000';
// Jac's watcher observes screenshot writes too; keep generated captures outside the app.
const screenshotDir = process.env.COOKSY_SCREENSHOT_DIR || '/tmp/cooksy-m1-screenshots';
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const errors = [];
const statusRequests = [];
page.on('pageerror', error => errors.push(error.message));
page.on('response', response => {
  if (response.url().includes('/function/shell_status')) statusRequests.push(response.status());
});
async function noOverflow() {
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  for (const heading of await page.locator('.region-copy h2').all()) {
    expect(await heading.evaluate(element => element.scrollWidth <= element.clientWidth)).toBe(true);
  }
}
try {
  await mkdir(screenshotDir, { recursive: true });
  await page.goto(baseURL);
  await expect(page.getByRole('heading', { level: 1 })).toContainText('Good food starts');
  await expect(page).toHaveTitle('Cooksy — Your ingredients. The world’s kitchens.');
  await expect(page.getByRole('status')).toHaveText('Connected to the Jac kitchen');
  expect(statusRequests).toContain(200); // Proves an RPC, not a client-only constant.
  await noOverflow();
  if (process.env.COOKSY_SCREENSHOTS) await page.screenshot({ path: `${screenshotDir}/m1-home-desktop.png`, fullPage: true, animations: 'disabled' });

  await page.keyboard.press('Tab');
  await expect(page.getByRole('link', { name: 'Skip to content' })).toBeFocused();
  await page.keyboard.press('Enter');
  await expect(page.locator('#main-content')).toBeFocused();

  await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'Explore', exact: true }).click();
  await expect(page).toHaveURL(`${baseURL}/explore`);
  await expect(page.getByRole('heading', { level: 1 })).toContainText('A world of kitchens.');
  const region = page.getByRole('button', { name: /East Africa/ });
  await region.focus();
  await page.keyboard.press('Enter');
  await expect(region).toHaveAttribute('aria-pressed', 'true');
  await expect(page.locator('#selection-title')).toHaveText('East Africa');
  await page.getByRole('button', { name: 'All regions', exact: true }).click();
  await expect(region).toHaveAttribute('aria-pressed', 'false');
  await expect(page.locator('#selection-title')).toHaveText('All regions');
  if (process.env.COOKSY_SCREENSHOTS) await page.screenshot({ path: `${screenshotDir}/m1-explore-desktop.png`, fullPage: true, animations: 'disabled' });

  await page.getByRole('link', { name: 'Visit my pantry' }).click();
  await expect(page).toHaveURL(`${baseURL}/pantry`);
  await expect(page.getByRole('heading', { level: 1 })).toContainText('Your pantry,');
  await page.reload(); // SPA deep-link fallback.
  await expect(page.getByRole('heading', { level: 1 })).toContainText('Your pantry,');
  await page.getByRole('link', { name: 'Cook along', exact: true }).click();
  await expect(page).toHaveURL(`${baseURL}/cook-along`);
  await expect(page.getByRole('heading', { level: 1 })).toContainText('One step');
  await page.goto(`${baseURL}/missing-kitchen`);
  await expect(page.getByRole('heading', { level: 1 })).toContainText('isn’t on the map.');
  await page.getByRole('link', { name: 'Back to Cooksy' }).click();
  await expect(page).toHaveURL(`${baseURL}/`);

  for (const width of [390, 320]) {
    await page.setViewportSize({ width, height: 844 });
    for (const route of ['/', '/explore', '/pantry', '/cook-along', '/missing-kitchen']) {
      await page.goto(baseURL + route);
      await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
      await noOverflow();
      await expect(page.getByRole('status')).toHaveText('Connected to the Jac kitchen');
      console.log(`Verified ${width}px ${route}`);
      if (process.env.COOKSY_SCREENSHOTS && width === 390 && (route === '/' || route === '/explore')) {
        await page.screenshot({ path: `${screenshotDir}/m1-${route === '/' ? 'home' : 'explore'}-mobile.png`, fullPage: true });
      }
    }
  }

  // A new context clears the runtime reader cache, allowing a real offline check.
  const offlineContext = await browser.newContext();
  const offlinePage = await offlineContext.newPage();
  await offlinePage.route('**/function/shell_status', route => route.abort('failed'));
  await offlinePage.goto(baseURL);
  await expect(offlinePage.getByRole('status')).toHaveText('The kitchen is offline. Try connecting again.');
  await offlinePage.unroute('**/function/shell_status');
  await offlinePage.getByRole('button', { name: 'Reconnect' }).click();
  await expect(offlinePage.getByRole('status')).toHaveText('Connected to the Jac kitchen');
  await offlineContext.close();
  expect(errors).toEqual([]);
  console.log('PASS: navigation, keyboard selection/skip link, deep links, 404, actual RPC, offline retry, no runtime errors, responsive 390/320px layouts.');
} finally {
  await context.close();
  await browser.close();
}
