# Playwright + TypeScript — full pack

**ID:** `playwright-ts` · **Tier:** full · **Template:** [instructions.template.md](instructions.template.md) · **Generation:** [generation.md](generation.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `playwright-ts` / `full` / TypeScript / API integration, browser E2E |
| Detection signals | `@playwright/test`, `playwright.config.ts`, representative Playwright specs |
| Default paths (only if no project convention) | `tests/api/*.spec.ts`, `tests/e2e/*.spec.ts`, `tests/fixtures/` |
| Run by path/tag | Existing runner's path selector; `--grep` for a project-established tag/title; never invent a package script |
| Report | Case/source, command, environment, result and evidence in approved `qa-work/<id>/` after L1; label unrun tests |
| Anti-patterns | Hard sleeps, brittle selectors, shared mutable data, embedded credentials, asserting undocumented statuses |

Select when repository evidence confirms `@playwright/test` and TypeScript (`playwright.config.ts` and existing specs). If the project uses Playwright JavaScript or Python, adapt syntax to those existing conventions; do not silently create TypeScript tests.

## Workflow
1. Read config, representative specs, fixtures and package scripts. Separate API-only tests (the `request` fixture) from browser journeys (`page`).
2. Inventory scenarios with source/acceptance criterion, test level, payload/state, expected observable result and risk. For APIs, derive contract cases from the authoritative OpenAPI or ticket; never invent contract status codes.
3. Follow project test root and naming; absent established structure, propose `tests/api/<resource>.contract.spec.ts`, `tests/e2e/<journey>.spec.ts`, `tests/fixtures/` and `playwright.config.ts` **for approval**, not as mandatory paths.
4. Use fresh payload factories and `test.extend` fixtures for isolated setup; configure `baseURL` and headers in the established config. Obtain credentials externally. Use `storageState` only when it cannot leak across identities or environments.
5. Choose accessible `getByRole` / `getByLabel` locators; `getByTestId` when no stable accessible handle exists. Avoid CSS/XPath and positional selectors when possible. Rely on Playwright's auto-wait and `await expect(locator).toBeVisible()` / `toHaveText()` / `toHaveURL()`; never add `waitForTimeout` sleeps.
6. Prefer `test.describe` and descriptive test names; use `test.step` for meaningful journeys. Use `page.route` for explicit mocks, `request` for HTTP assertions, and assert user-visible outcomes. For known async responses, wait for the specific response or state, not arbitrary load delays.
7. Run only the project's existing targeted validation command. Report coverage and unrun tests honestly; traces/retries may be configured for CI but are not proof of reliability.

Avoid shared mutable globals, test-order dependencies, hardcoded URLs/credentials and broad snapshot assertions. Default to no network calls to production or state-changing tests without authorization.
