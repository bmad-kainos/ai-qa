| Field | Value |
|---|---|
| id | `playwright-ts` |
| tier | `full` |
| languages | TypeScript, JavaScript |
| levels | API integration, browser E2E |
| detection signals | `@playwright/test`, `playwright.config.ts`/`.js`, and representative Playwright specs; inspect imports to distinguish TypeScript/JavaScript |
| default paths | `tests/api/*.spec.ts`, `tests/e2e/*.spec.ts`, `tests/fixtures/` (only absent project conventions) |
| run by path | `npx playwright test "<path>"` (template only; use configured `Commands` first) |
| run by tag | `npx playwright test --grep "<tag-or-title>"` (existing project tag/title only) |
| report format | Configured Playwright reporter, preferably JSON where already configured; include command, case, environment and evidence in `execution.md` |
| anti-patterns | `waitForTimeout`, brittle CSS/XPath or positional selectors, shared mutable data, embedded credentials, undocumented status assertions, order-dependent tests |

Select only when repository evidence confirms the runner and language. If the project uses Playwright Python, use the `pytest` pack; do not silently generate TypeScript tests. Project paths, naming, fixtures, auth and commands always override these defaults.

## Workflow
1. Read runner configuration, representative specs, fixtures and documented commands. Separate API tests using the `request` fixture from browser journeys using `page`.
2. Present the scenario inventory before writing tests. Use the authoritative contract or requirement; do not invent response statuses or schemas.
3. Follow the project's test root and naming. The default paths in this pack are suggestions only when conventions are absent.
4. Use fresh payload factories and isolated fixtures. Configure base URL and headers through existing approved configuration; never embed credentials.
5. Prefer accessible role/label locators and Playwright auto-waiting. Wait for specific response/state signals, never arbitrary delays.
6. Use explicit mocks only where project.md says to mock; use real dependencies where the project says they must remain real.
7. Run the configured targeted command only when permitted; report generated, compiled, executed and passing states separately.
