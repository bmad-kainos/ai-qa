| Field | Value |
|---|---|
| id | `jest-vitest` |
| tier | `conventions` |
| languages | TypeScript |
| levels | Unit, component integration |
| detection signals | Manifest/config identifying the actual Jest or Vitest runner and representative unit tests |
| default paths | `**/*.test.ts`, `**/*.test.tsx`, existing `__tests__/` |
| run by path | Jest: `npx jest "<path>"`; Vitest: `npx vitest run "<path>"` (templates only) |
| run by tag | Jest/Vitest: `-t "<test-name-pattern>"` (name filter, not a tag; use project tag support only if configured) |
| report format | Existing configured JSON/JUnit reporter or console output, plus `09_execution.md` evidence |
| anti-patterns | Mixing runner APIs, broad snapshots, live unit-test network, shared data, secrets, order dependencies |

Use only when repository tests/config identify **which** runner is installed. Their mocking globals and configs are not interchangeable; follow the installed runner's imports and APIs. This conventions pack does not provide an integration harness.
