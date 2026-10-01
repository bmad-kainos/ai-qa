# Contributor guide

## Branches and work items

Use `feature/JIRA-123-short-description` and `bugfix/JIRA-123-short-description` branches. Work items are tracked in the self-hosted Jira installation at `https://jira.pricing.example.org/browse/JIRA-123`.

## Tests

Run Jest with `npm test`. Test files should use `.test.ts` and live under `tests/unit/`. The integration suite is described as Playwright in the package scripts; ask the team before relying on it.
