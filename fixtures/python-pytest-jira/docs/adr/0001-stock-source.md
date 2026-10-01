# ADR 0001: Stock ownership and reservation boundary

## Status

Accepted

## Context

The Stock API is authoritative for available quantity. Checkout requests reservations but owns basket and payment state. A checkout sandbox is not available to every local developer.

## Decision

Keep quantity reads and updates in Stock API. Treat checkout reservation as an external HTTP boundary and cover its contract with isolated tests until a dedicated sandbox is confirmed.

## Consequences

Unit tests cover quantity rules; integration tests exercise the local ASGI application. Cross-service tests must not use production data and require an explicitly identified sandbox.
