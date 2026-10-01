import { expect, test } from '@playwright/test';

test('shows an empty state when no products are available', async ({ page }) => {
  await page.route('**/api/catalogue', (route) => route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([]),
  }));

  await page.goto('/');

  await expect(page.getByRole('heading', { name: 'Catalogue' })).toBeVisible();
  await expect(page.getByRole('listitem')).toHaveCount(0);
});