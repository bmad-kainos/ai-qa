import { expect, test } from '@playwright/test';

test('orders endpoint returns the requested order', async ({ request }) => {
  const response = await request.get('/orders/order-17');

  expect(response.status()).toBe(200);
  expect(await response.json()).toMatchObject({ id: 'order-17' });
});