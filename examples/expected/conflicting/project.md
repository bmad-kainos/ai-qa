# Project Context — Conflicting signals

<!-- ai-qa:managed -->
## Summary
Medium: fixture deliberately contains contradictory QA instructions ([README](../../fixtures/conflicting/README.md)).
## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| UI tests | intended test suite | `package.json` | Playwright (inferred) | Not yet observed in files |
## Technology stack
Medium: Node package with Playwright dependency ([package](../../fixtures/conflicting/package.json)).
## Environments
Low: no environment URLs found ([discovery](discovery.md)).
## Data stores and external dependencies
Low: none documented ([discovery](discovery.md)).
## CI/CD
Low: none observed ([discovery](discovery.md)).
## Test landscape
Medium: two conflicting test commands, no tests ([README](../../fixtures/conflicting/README.md), [guide](../../fixtures/conflicting/CONTRIBUTING.md)).
## Constraints
High: Jira deployment must be confirmed before provider selection ([ADR](../../fixtures/conflicting/docs/adr/0001-legacy-tracker.md)).
## Documentation sources
High: [README](../../fixtures/conflicting/README.md), [guide](../../fixtures/conflicting/CONTRIBUTING.md), [ADR](../../fixtures/conflicting/docs/adr/0001-legacy-tracker.md).
## Unknowns and conflicts
High: Jira Cloud versus Server/DC and test command conflict ([discovery](discovery.md)).
## Provenance
High: local fixture files only, no serverInfo or test execution.
<!-- ai-qa:user -->
Preserved project notes.
