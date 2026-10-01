# Contributing

## Branches and commits

- Branch from `main` with `feature/<issue>-<short-description>` or `bugfix/<issue>-<short-description>`.
- Use Conventional Commits, for example `feat(catalogue): show product price`.
- Reference GitHub issues using `#123`; close issues in the pull request body with `Closes #123`.

## Tests and review

Run `npm test` before opening a pull request. Keep API and end-to-end test names descriptive and use Playwright route fixtures instead of shared services. Pull requests need one approving review and passing GitHub Actions checks.