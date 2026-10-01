import { describe, expect, it } from 'vitest';

describe('cart total', () => {
  it('adds line subtotals', () => {
    const total = [{ price: 4, quantity: 2 }, { price: 3, quantity: 1 }]
      .reduce((sum, line) => sum + line.price * line.quantity, 0);

    expect(total).toBe(11);
  });
});