# Manual scenario deduplication

Before drafting scenarios, re-read available test assessment/coverage evidence for this work item. For each functional requirement or acceptance criterion, use the `FR`/`NFR` IDs assigned during requirement analysis and apply this filter:

| Question | If YES → | If NO → |
|---|---|---|
| Is this AC already fully covered by a **passing** unit test, with no coverage gap? | **Skip** a dedicated manual scenario for it, or fold it into a broader end-to-end scenario | Include a manual scenario |
| Does validating this AC require crossing a real boundary (API contract, service call, database, queue/event, feature flag at runtime, real environment config)? | Include a manual scenario regardless of unit coverage | Lower priority for a dedicated scenario |
| Is this a pure internal logic/branching check (e.g. input validation, calculation, mapping) with no system-level consequence? | **Skip** — unit tests own this | — |
| Is this flagged as a coverage gap, over-mocked, or an untested edge case? | Include a manual scenario — this is exactly what manual testing must catch | — |

❗ Never delete manual coverage of HIGH/CRITICAL risk areas, feature flag ON/OFF states, or cross-service data flows purely to reduce scenario count — the goal is to cut **redundant** scenarios, not risk coverage.

A passing test must be relevant, have assertions that exercise the behaviour, and have current run evidence. A test that merely exists, is skipped, or has no current run evidence does not qualify as passing.

## Core principle

Manual scenarios exist to catch what unit and integration tests **cannot** — real business outcomes, cross-service behaviour, and edge cases that only surface with live data and infrastructure. They are not a re-run of unit test logic in Gherkin syntax.

> A simple ticket with 3 ACs, all already covered by passing unit tests, should produce **2–4 manual scenarios** — not one scenario per AC. This is a heuristic, not a target or a cap: risk and real boundary coverage take precedence, and it does not require a fixed scenario count.

## What manual testing should focus on

- **Business-level acceptance** — does the end result match what the business actually asked for, not just what the function returns
- **Cross-service / system behaviour** — end-to-end flow across services, not a single function
- **Real environment edge cases** — data quirks, legacy records, migration artefacts that unit test fixtures don't reproduce
- **Feature flag ON/OFF at runtime** — actual toggled behaviour in a live environment
- **Regression on existing behaviour** — especially anything flagged HIGH/CRITICAL
- **Failure modes that depend on real infrastructure** — timeouts, malformed upstream data, partial failures

## What to avoid

- One scenario per AC when several ACs are exercised by the same business flow — merge them into a single end-to-end scenario with multiple `AND` assertions
- Re-asserting pure validation/calculation logic already confirmed unit-tested and passing
- Padding the plan with scenarios that add no new risk coverage, just to look thorough

## Scenario format

```gherkin
GIVEN <precondition>
WHEN <action>
THEN <expected result>
AND <additional assertion>
```

## Scenario categories (apply selectively, not as a checklist)

Apply the deduplication rule first; include a category only if it survives the filter:

- Happy path — include if it demonstrates real end-to-end/business flow, not pure logic
- Negative scenarios — include only for failure modes with system-level consequence
- Validation errors — include only if validation crosses a boundary (e.g. API contract), not internal-only
- Permission scenarios (if applicable) — always include, rarely fully unit-tested
- Feature flag ON state — always include if a flag is introduced or changed
- Feature flag OFF state — always include if a flag is introduced or changed
- Regression scenarios — include for HIGH/CRITICAL risk areas identified so far
- Environment-specific behaviour (if applicable) — include if behaviour genuinely differs per environment

## Quality criteria

Each scenario must be:
- **Clear** — unambiguous preconditions and expected results
- **Reproducible** — can be run by anyone with access to the environment
- **Deterministic** — the same input always produces the same output
- **Non-redundant** — justifies its existence against the deduplication rule above

For every selected scenario specify its requirement IDs, setup/test data, observable outcome and cleanup. State which requirement IDs it covers, for example `Covers: FR2, FR4`. Document the data naming convention so any team member can reproduce the data: use a consistent prefix or pattern linking test data to the work item, natural realistic names, avoid embedding ticket numbers in display names and excessive `TEST` prefixes.

## Required output note — Scenarios Not Written

Alongside the scenarios, include a short **Scenarios Not Written** list: requirement IDs (`FR`/`NFR`) or categories deliberately skipped because they are already covered by passing tests, with a one-line justification naming the evidence. If evidence is absent, describe the uncertainty rather than claiming deliberate deduplication. This makes the deduplication decision visible and reviewable.
