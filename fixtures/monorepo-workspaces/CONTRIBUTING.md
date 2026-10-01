# Contributing

Create branches from `main` as `feature/COM-123-short-description` or `bugfix/COM-123-short-description`. Use Conventional Commits and reference GitHub issues as `#123` in pull requests.

Run the workspace-specific tests for the package you change, then run `npm test` before merging. API tests use Playwright under `packages/api`; web tests use Vitest under `packages/web`.