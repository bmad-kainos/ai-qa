import { test, expect } from '@playwright/test';
test('catalogue returns a list', async ({ request }) => {
  const response = await request.get('/api/catalogue');
  expect(response.ok()).toBeTruthy();
  expect(Array.isArray(await response.json())).toBeTruthy();
});
