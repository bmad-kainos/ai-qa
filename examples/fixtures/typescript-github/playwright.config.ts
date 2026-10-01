import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: './tests',
  reporter: [['junit', { outputFile: 'test-results/junit.xml' }]],
  use: { baseURL: process.env.TEST_BASE_URL ?? 'http://localhost:3000' },
});
