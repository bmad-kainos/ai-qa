---
name: Playwright + TypeScript test conventions
description: Best practices for Playwright tests written in TypeScript.
applyTo: "{{globs}}"
---

# Playwright + TypeScript — test conventions

> Rendered by `qa-configure` for this project's selected test paths only. The project's `.github/ai-qa/project/conventions/testing.md` and neighbouring tests take precedence over this pack guidance (precedence: user instruction > project conventions > neighbouring code > pack > framework defaults).

## Locators
- Prefer user-facing, role-based locators: `getByRole`, `getByLabel`, `getByPlaceholder`, `getByText`.
- Avoid CSS/XPath and `nth()` chains — they break on markup changes. Use `getByTestId` only when no accessible handle exists.
- Store locators in variables; do not use the legacy `page.$` / `page.waitForSelector`.

## Waiting & synchronisation
- Never use `page.waitForTimeout()` (a hard sleep). Playwright auto-waits for actionability.
- Use web-first assertions that auto-retry: `await expect(locator).toBeVisible()`, `toHaveText`, `toHaveURL`.
- To wait for a specific condition use `waitForResponse` / `waitForLoadState`, never an arbitrary delay.

## Assertions
- Always `await expect(...)`. Prefer locator assertions over reading a value and then asserting on it.
- Assert on user-visible outcomes, not implementation detail.

## Structure & fixtures
- Group with `test.describe`; make steps readable with `test.step`.
- Share setup via `test.extend` fixtures, not `beforeAll` globals that hold state.
- Every test must run independently and in parallel.
- Authenticate once and reuse a `storageState` file across tests.

## Network
- Mock or stub with `page.route`; assert backend calls with the `request` fixture.

## Config
- Set `baseURL`; enable `trace: 'on-first-retry'` and `retries` in CI.

## Anti-patterns
- No `waitForTimeout`, no CSS/XPath selectors, no shared mutable state, no `console.log` noise, no secrets in specs.

## Playwright + JavaScript — test conventions

Same engine and APIs as Playwright + TypeScript, without static types.

### Locators
- Prefer role-based locators: `getByRole`, `getByLabel`, `getByPlaceholder`, `getByText`.
- Avoid CSS/XPath and `nth()`; use `getByTestId` only as a fallback.

### Waiting & synchronisation
- Never `page.waitForTimeout()`. Rely on auto-waiting and web-first assertions.
- Use `await expect(locator).toBeVisible()` / `toHaveText` — they auto-retry.
- Wait for real signals (`waitForResponse`, `waitForLoadState`), not delays.

### Assertions
- Always `await expect(...)`; assert on user-visible outcomes.

### Structure & fixtures
- Group with `test.describe`; use `test.step` for readable steps.
- Share setup with `test.extend`; keep each test isolated and parallel-safe.
- Reuse auth via a `storageState` file.

### Network
- Mock with `page.route`; assert APIs with the `request` fixture.

### Anti-patterns
- No hard waits, no CSS/XPath, no shared mutable state, no `console.log` noise, no secrets in specs.
