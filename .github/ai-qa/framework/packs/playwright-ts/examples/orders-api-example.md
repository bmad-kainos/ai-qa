# Playwright TypeScript — Orders API example (illustrative, unrun)

This **hypothetical** contract says `POST /orders` accepts integer `quantity` 1–9 and a nonempty `customerId`; valid requests return **201** with a string `id`, invalid quantities or missing `customerId` return **400** with `error.code`. Adapt statuses/schema to the real contract. `baseURL` is configured by the existing project from `API_BASE_URL`; do not use this example on a shared service without approved isolation/cleanup.

```typescript
import { test, expect } from '@playwright/test';

const order = (quantity: number) => ({ customerId: 'isolated-example', quantity });

test.describe('POST /orders — hypothetical contract', () => {
  test('creates an order from a valid payload', async ({ request }) => {
    const response = await request.post('/orders', { data: order(5) });
    expect(response.status(), await response.text()).toBe(201);
    expect(await response.json()).toEqual(expect.objectContaining({ id: expect.any(String) }));
  });

  for (const { quantity, status } of [
    { quantity: 0, status: 400 }, // below minimum
    { quantity: 1, status: 201 }, // at minimum
    { quantity: 9, status: 201 }, // at maximum
    { quantity: 10, status: 400 }, // above maximum
  ]) {
    test(`quantity ${quantity} returns ${status}`, async ({ request }) => {
      const response = await request.post('/orders', { data: order(quantity) });
      expect(response.status(), `quantity=${quantity}: ${await response.text()}`).toBe(status);
      const body = await response.json();
      if (status === 400) expect(body.error.code).toBeTruthy();
      else expect(body.id).toEqual(expect.any(String));
    });
  }

  test('rejects a missing required customerId', async ({ request }) => {
    const response = await request.post('/orders', { data: { quantity: 1 } });
    expect(response.status(), await response.text()).toBe(400);
    expect((await response.json()).error.code).toBeTruthy();
  });
});
```

Use existing fixtures for auth, deterministic order IDs and cleanup; never copy hypothetical expectations into production tests without a verified contract. `test` and `expect` come from the already-installed Playwright runner, not a new dependency request.
