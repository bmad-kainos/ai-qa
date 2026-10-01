# ADR 0001: Migrate work tracking to Azure Boards

## Status

Accepted; migration completed for new work

## Context

The pricing team previously used self-hosted Jira. Repository contribution notes still contain the old Jira workflow and issue syntax.

## Decision

Use Azure Boards in the `Commerce/Pricing` project for new work items. Reference items as `AB#123`. Keep legacy Jira links only for historical issues until they are archived.

## Consequences

The self-hosted Jira URL in `CONTRIBUTING.md` may remain relevant to open work. Confirm whether the legacy project is read-only before changing integrations.
