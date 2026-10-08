---
work-id: "<ticket-or-sprint-id>"
skill: "qa-test-plan"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
  - source: "<ticket, sprint or repository path/link>"
    revision: "<source revision or observed time>"
---

# Test Plan — <ticket or sprint>

**Author:** <current user or role, if known>
**Date:** <date>
**Project:** <project name and confirmed identifier>
**Scope:** <ticket / sprint / feature>
**Status:** Draft

## TL;DR

- **Verdict:** <Go / Go with conditions / No-go / Not assessed, with one-line reason>
- **Top risks:** 1. <risk, tier, evidence> 2. <risk> 3. <risk>
- **Next action:** <single most important action and owner>

## Next Steps

Ordered: blockers first, then risk tier, then effort. Cite the source artefact number; de-duplicate.

| # | Action | Owner | Evidence (FR/NFR/scenario ID) | Blocker | Source |
|---|---|---|---|---|---|
| 1 | <action> | <owner> | <ID> | <Yes / No> | <e.g. 03> |

## Summary

<Brief description of the work and test scope. State exclusions and source revision.>

## QA Summary

| Ticket | Readiness | Max risk | Coverage verdict | Scenarios written/not written | Automated/manual/not needed | Run result | Published |
|---|---|---|---|---|---|---|---|
| <ticket> | <Green / Amber / Red> | <LOW / MEDIUM / HIGH / CRITICAL> | <Pass / Needs Improvement / Insufficient / Not assessed> | <written/not written counts> | <decision and rationale> | <PASS / FAIL / BLOCKED / Not run> | <destination/receipt or Not published> |

## Risk Assessment

<Key risks, evidence, modifiers and highest supported risk. Do not average risk categories or turn missing evidence into LOW.>

## Requirements Breakdown

List functional (`FR1`, `FR2`, …) and non-functional (`NFR1`, `NFR2`, …) requirements with stable IDs, source/revision, measurable outcome and ambiguities. If the source specifies no NFRs, state “none specified”.

## Traceability Matrix

| FR/NFR | Existing evidence (test/assertion or gap) | Scenarios | Automation decision (assessed / automated / deliberately not automated, with reason) | Test files | Last result (run / environment / time) |
|---|---|---|---|---|---|
| FR1 | <assertion or gap> | <scenario ID or —> | <decision and rationale> | <test path or —> | <run evidence or Not run> |

Distinguish test existence, assertion relevance, actual execution, measured coverage and deployment validation.

## Test Scenarios

Write lean scenarios, in the project's configured Scenario format (see `method/scenario-format.md`), focused on business outcomes, cross-service behaviour, real environment edge cases, permissions, runtime feature flag ON/OFF behaviour, failure modes depending on infrastructure, and HIGH/CRITICAL risks. Tag each scenario and list `Covers: FRn, NFRn`.

Format `bdd` (default):

```gherkin
GIVEN <precondition>
WHEN <action>
THEN <observable expected result>
AND <additional assertion>
```

Format `steps`:

```md
**Preconditions:** <environment, data and state before step 1>

| # | Action | Expected result | Evidence |
|---|---|---|---|
| 1 | <action> | <observable result> | |

**Cleanup:** <how to restore state>
```

### Scenarios Not Written

| Requirement ID / category | Why omitted | Existing passing evidence |
|---|---|---|
| <ID/category> | <specific deduplication reason or uncertainty> | <test/assertion/run evidence or “none”> |

## Automation Recommendation

For each scenario choose automated (level/location/mocking/environment/CI impact), manual or not needed. Justify against the nine automation factors and record impact class (None/Low/Medium/High). Automation recommendation is not approval to write or run tests.

## Regression Impact

<Affected areas and escalation reasoning.>

## Environment Impact

<Environment-specific behaviour, access, test-data effects, base URL variable names only, dependencies, cleanup and safety limits. Never include credentials.>

## Open Questions

- <unresolved question, evidence and owner, or “None”>

## Regression Risk Matrix

Complete all 13 areas. Use `unknown` when evidence is missing; never mark every area LOW without justification. For each HIGH/CRITICAL area include targeted scenario, automation reinforcement, possible production impact and rollout/rollback validation.

| Area | Risk Level | Why? / evidence | Regression Needed? | Automation Update Needed? |
|---|---|---|---|---|
| API Behaviour | | | | |
| Existing Endpoints | | | | |
| Feature Flags | | | | |
| Caching | | | | |
| Authentication / Authorisation | | | | |
| API Gateway | | | | |
| Backend Logic | | | | |
| Database Layer | | | | |
| Data Integrity | | | | |
| Logging / Monitoring | | | | |
| Environment Configuration | | | | |
| CI/CD Pipeline | | | | |
| Backward Compatibility | | | | |

## Sprint-scope additions

Include these sections when the plan covers a sprint or queue.

### Scope

| Ticket | Summary | In scope? | Notes |
|---|---|---|---|
| <ticket> | <summary> | <yes/no> | <evidence or exclusion> |

### Test Approach

| Ticket | Summary | Test Level | Automated | Effort |
|---|---|---|---|---|
| <ticket> | <summary> | <Unit / Integration / E2E / Manual> | <Yes / Manual / Blocked> | <None / Low / Medium / High> |

### Prerequisites and Dependencies

| Requirement | Needed for | Status |
|---|---|---|
| <environment/access/data/dependency/tooling; names only for secrets> | <ticket/scope> | <ready / blocked / unknown> |

### Test Effort Summary

| Category | Tickets | Estimated effort |
|---|---|---|
| <None / Low / Medium / High> | <ticket list> | <evidence-backed estimate or not estimated> |

## Drift

<Record contradictions with project context/conventions, or “None observed”; never edit the project layer. Suggest `qa-configure refresh` when appropriate.>