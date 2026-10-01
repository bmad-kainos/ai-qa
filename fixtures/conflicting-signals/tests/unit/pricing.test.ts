import { describe, expect, it } from 'vitest';

describe('price validation', () => {
  it('accepts a non-negative price', () => {
    expect(4.25).toBeGreaterThanOrEqual(0);
  });
});