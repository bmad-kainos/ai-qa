# Contributing

## Branches and work items

- Branch from `main` using `feature/STK-123-short-description` or `bugfix/STK-123-short-description`.
- Use Conventional Commits and include the Jira key, for example `fix(stock): reject negative quantity STK-12`.
- Jira Cloud work items use `https://stock-team.atlassian.net/browse/STK-12`; project key `STK` is the issue prefix.
- The team runbook is maintained in the [Stock API Confluence space](https://stock-team.atlassian.net/wiki/spaces/STOCK/overview).

## Validation and data

Run `python -m pytest tests/` before review. Keep tests isolated and deterministic; never use production stock records. Pull requests require one approval from the Stock maintainers.