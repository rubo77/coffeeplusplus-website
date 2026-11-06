// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * Playwright configuration for the local coffeeplusplus docker mirror
 * (website + phpBB forum on http://localhost:8624).
 */
module.exports = defineConfig({
    testDir: './tests',
    fullyParallel: true,
    forbidOnly: !!process.env.CI,
    retries: 0,
    workers: 1,
    reporter: 'list',
    use: {
        baseURL: 'http://localhost:8624',
        trace: 'on-first-retry',
    },
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
    ],
});
