// Test: coffeeplusplus site + phpBB forum mirror on http://localhost:8624
// Run:  cd dev/playwright && PLAYWRIGHT_BROWSERS_PATH=/home/ruben/.playwright-browsers npx playwright test --project=chromium
const { test, expect } = require('@playwright/test');

test('website index renders Coffee++', async ({ page }) => {
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    const res = await page.goto('/');
    expect(res.status()).toBe(200);
    await expect(page).toHaveTitle(/Coffee\+\+/i);
    await expect(page.locator('body')).toContainText(/keyboard|Tastatur/i);
    expect(errors).toEqual([]);
});

test('phpBB forum index renders without errors', async ({ page }) => {
    const res = await page.goto('/phpBB3/');
    expect(res.status()).toBe(200);
    await expect(page).toHaveTitle(/Index page|Forum/i);
    const body = await page.locator('body').innerText();
    expect(body).not.toMatch(/General Error|Fatal error|Unable to write to the cache/i);
    // a forum list with at least one forum link must be present
    await expect(page.locator('a.forumtitle').first()).toBeVisible();
});

test('forum topic page opens', async ({ page }) => {
    await page.goto('/phpBB3/viewforum.php?f=1');
    const topic = page.locator('a.topictitle').first();
    await expect(topic).toBeVisible();
    const href = await topic.getAttribute('href');
    await page.goto(href);
    expect(page.url()).toMatch(/viewtopic|app\.php/);
    const body = await page.locator('body').innerText();
    expect(body).not.toMatch(/General Error|Fatal error/i);
});
