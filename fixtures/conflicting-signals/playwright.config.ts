import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/integration',
  reporter: [['list'], ['junit', { outputFile: 'test-results/integration.xml' }]],
  use: { baseURL: process.env.PRICING_API_URL ?? 'http://localhost:4100' },
});