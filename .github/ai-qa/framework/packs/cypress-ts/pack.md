# Cypress + TypeScript — conventions tier

**ID:** `cypress-ts` · **Tier:** conventions · **Template:** [instructions.template.md](instructions.template.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `cypress-ts` / `conventions` / TypeScript / browser E2E, API integration if established |
| Detection signals | Cypress dependency/config and existing `*.cy.ts` specs |
| Default paths (only if no project convention) | `cypress/e2e/**/*.cy.ts`, existing support/fixtures |
| Run by path/tag | Existing Cypress runner's `--spec` selector; tag plugin only if installed/configured |
| Report | Spec/source, environment, result and evidence in approved `qa-work/<id>/` after L1 |
| Anti-patterns | `cy.wait(number)`, mixing `async/await` with commands, shared test order/state, secrets |

Apply only to confirmed Cypress TypeScript projects; inspect `cypress.config.ts`, support commands and representative `*.cy.ts`. Follow existing folder layout and custom commands rather than generating a new harness.

- Prefer stable `data-cy` locators or installed Testing Library role queries over style/layout CSS or XPath.
- Cypress commands queue and retry: use `.should('be.visible')` / `.should('have.text', ...)`; never assign a `cy` return to a variable or mix command chains with `async/await`.
- Alias requests with `cy.intercept(...).as('name')` and `cy.wait('@name')`. Never use `cy.wait(number)` to fix timing.
- Reset state in `beforeEach`; use function-scoped data, `cy.fixture` for static inputs and `cy.request` for controlled seeding when the environment permits. No shared mutable or order-dependent state.
- Read auth/base URL from the project's approved configuration, never commit tokens. Assert user-observable outcomes, not incidental DOM details.

This is guidance, not a promise of API scaffolding or an installed Cypress runner. Validate using an existing targeted command only.
