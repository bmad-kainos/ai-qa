# ADR 0001: Catalogue API boundary

## Status

Accepted

## Context

The browser application needs a stable product contract while the catalogue storage service evolves independently.

## Decision

Expose product data through the HTTP API described in `openapi.yaml`. Browser tests stub this boundary with Playwright routes; they do not connect to a shared database.

## Consequences

Contract changes must update the OpenAPI document and API tests. PostgreSQL is the local development store for the service, not a browser-test dependency.