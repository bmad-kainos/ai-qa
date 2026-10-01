import { expect, test } from '@playwright/test';

test('catalogue page renders products returned by its API boundary', async ({ page }) => {
  await page.route('**/api/catalogue', (route) => route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([{ id: 'sku-1', name: 'Notebook', price: 4.5 }]),
  }));

  await page.goto('/');

  await expect(page.getByRole('listitem')).toHaveText('Notebook - £4.50');
});
