# Testing defaults

These are candidate defaults, not project findings. Configure applies a candidate only after discovery/confirmation and records it as `★` with a date. Use observed project conventions first. Never select a framework pack or invent a test command from these examples.

## Scopes

| Test path | Level | Pack | Location | Naming | Fixtures/builders | Tags | Base classes | Assertions |
|---|---|---|---|---|---|---|---|---|
| Unknown until discovered | Unknown | None selected | Unknown | Unknown | Unknown | Unknown | Unknown | Unknown |

Record one row per observed scope. Render instruction globs only from discovered test paths. If no pack matches, follow existing tests with reduced-confidence warning. If no framework exists, record `∅`, establish a `★` only through Configure, and offer a gated scaffold.

## Commands

| Command | Candidate |
|---|---|
| All tests | No default; discover and confirm. |
| Path | No default; derive from observed runner. |
| Tag | No default; derive from observed markers/selectors. |
| Lint/compile | No default; discover and confirm. |
| List/help | No default; inspect documented runner help without running the suite. |

Do not run the suite during discovery. L3 applies to full, environment-dependent, long or shared-service runs unless a targeted command is explicitly marked safe in project `qa-process.md`.

## Reports

No report format or path default. Record observed format and path; distinguish a report that exists from an executed test result and measured coverage.

## Environments and base URLs

No environment or URL defaults. Record environment-variable **names only**, never values or credentials. Confirm safe targets and side effects before execution.

## Test data rules

No file format or naming default. Follow project conventions, ownership, privacy, isolation and cleanup requirements. Never commit secrets, live identifiers or confidential data.

## Manual testing ownership

Manual scenarios focus on business outcomes, service boundaries, real environment behaviour, permissions, changed feature flags ON/OFF, untested/over-mocked branches and HIGH/CRITICAL regression. Apply `method/dedup-rule.md`; do not duplicate passing relevant automated assertions.

## Options (not defaults)

- Use `.sql` files for test data where required by project conventions.
- Keep a Confluence page empty until testing begins, if required by the team’s evidence process.