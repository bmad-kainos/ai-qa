# Discovery — typescript-github

| Domain | Status | Conclusion | Evidence | Note |
|---|---|---|---|---|
| Build/test stack | ✓ Observed | TypeScript and Playwright with API test path | `package.json:1-12`, `playwright.config.ts:1-5`, `tests/api/catalogue.spec.ts:1-5` | One test sampled, 1/1 follows `.spec.ts`. |
| Execution | ✓ Observed | npm test, `test:api` and JUnit output | `package.json:4-7`, `playwright.config.ts:4` | Do not execute suite in discovery. |
| CI/CD | ✓ Observed | GitHub Actions runs Playwright on push/PR | `.github/workflows/tests.yml:1-12` | Upload artefact not configured. |
| PRs | ✓ Observed | PR template has Summary/Validation | `.github/PULL_REQUEST_TEMPLATE.md:1-6` | No base/title pattern observed. |
| Project context | ✓ Observed | Catalogue API contract | `docs/openapi.yaml:1-8` | No deployed base URL specified. |
| Git | ? Could not check | No historical branch sample in fixture snapshot | Fixture files | Read git log and recent merged PRs in a real checkout. |

Sample: one API test from one test directory (1/1 observed), config, workflow, contract and PR template. Examples: `tests/api/catalogue.spec.ts:2`, `playwright.config.ts:3`, `.github/PULL_REQUEST_TEMPLATE.md:1`.

## Needs your input

- Which repository base branch and title pattern should PRs use if unavailable from git/remote evidence?
