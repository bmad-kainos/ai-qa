# Jest / Vitest + TypeScript — conventions tier

**ID:** `jest-vitest` · **Tier:** conventions · **Template:** [instructions.template.md](instructions.template.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `jest-vitest` / `conventions` / TypeScript / unit, component integration |
| Detection signals | Actual Jest **or** Vitest manifest/config, representative unit tests |
| Default paths (only if no project convention) | `**/*.test.ts`, `**/*.test.tsx`, existing `__tests__/` |
| Run by path/tag | Existing installed runner's file/name selector; no assumed tag plugin |
| Report | Test/source, selected command, observed result in approved `qa-work/<id>/` after L1 |
| Anti-patterns | Runner API interchange, broad snapshots, live unit-test network, shared data, secrets |

Use when the project's existing tests/config identify **which** runner is installed. They share many patterns but their mocking globals and configs are not interchangeable; follow the installed runner's imports and APIs.

- Group with `describe`; make each `it`/`test` describe one behavior and outcome using Arrange–Act–Assert.
- Prefer precise `toEqual` for structural equality, `toBe` for identity and `toThrow` for errors. Await asynchronous `resolves` / `rejects` assertions.
- Build fresh data per test. Mock external boundaries only; avoid testing mocks instead of behavior. Restore/clear mocks between tests using the runner's existing configuration or APIs.
- Do not call live APIs/filesystems in unit tests. Avoid broad snapshots, shared mutable state, test-order dependencies and secrets.
- If API integration coverage is requested, inspect the existing HTTP client and test environment first; this conventions pack does not provide an integration harness.

Use the repository's existing targeted Jest or Vitest command; do not install or substitute the other runner.
