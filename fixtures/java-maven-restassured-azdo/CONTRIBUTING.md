# Contributing

## Branches and commits

- Branch from `main` using `feature/AB-123-short-description` or `bugfix/AB-123-short-description`.
- Use Conventional Commits, for example `feat(orders): validate quantity AB#123`.
- Include the Azure Boards reference (`AB#123`) in the pull request description.

## Validation

Run `sh mvnw --batch-mode test` before requesting review. Keep API tests deterministic and use the isolated test application; do not use shared staging data.

## Review

Pull requests require one reviewer from the owning team. Use the repository pull request template when one is present.