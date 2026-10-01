# ADR 0001: Invoice total precision

## Status

Accepted

## Decision

Calculate invoice totals with decimal arithmetic and preserve the summed line precision. Currency-specific rounding is applied by the payment boundary, not this calculator.