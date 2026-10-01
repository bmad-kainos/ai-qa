import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/api',
  reporter: [['junit', { outputFile: 'test-results/api.xml' }]],
  use: { baseURL: process.env.ORDERS_API_URL ?? 'http://localhost:8080' },
});