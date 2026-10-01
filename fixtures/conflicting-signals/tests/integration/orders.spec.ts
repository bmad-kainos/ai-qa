import { expect, test } from '@playwright/test';

test('pricing API rejects a negative amount', async ({ request }) => {
  const response = await request.post('http://localhost:4100/prices/validate', {
    data: { amount: -1, currency: 'GBP' },
  });

  expect(response.status()).toBe(400);
});