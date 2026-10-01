# ADR 0001: PostgreSQL for order persistence

## Status

Accepted

## Context

Orders require durable storage and transactional writes. The local development stack must remain self-contained and must not depend on shared team data.

## Decision

Use PostgreSQL for deployed persistence and Docker Compose for a local PostgreSQL service. Integration tests must use isolated data and may not target staging.

## Consequences

Database credentials are supplied by environment variable. CI runs the deterministic API suite; a database-backed integration profile will be added when repository persistence is implemented.
