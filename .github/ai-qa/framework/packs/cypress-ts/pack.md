| Field | Value |
|---|---|
| id | `cypress-ts` |
| tier | `conventions` |
| languages | TypeScript |
| levels | Browser E2E, API integration only if already established |
| detection signals | Cypress dependency/config and representative `*.cy.ts` specs/support commands |
| default paths | `cypress/e2e/**/*.cy.ts`, existing support and fixture roots |
| run by path | `npx cypress run --spec "<path>"` (template only; use configured `Commands` first) |
| run by tag | `npx cypress run --env grepTags="<tag>"` only with an existing tag plugin; otherwise no tag command is available |
| report format | Configured Cypress reporter (JSON/JUnit only when installed/configured), plus `09_execution.md` evidence |
| anti-patterns | `cy.wait(number)`, mixing `async/await` with command chains, shared test order/state, secrets, brittle selectors |

Apply only to confirmed Cypress TypeScript projects; inspect `cypress.config.ts`, support commands and representative specs. Follow existing folders and custom commands rather than generating a harness.
