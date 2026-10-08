# QA readiness and risk-based prioritisation

## QA readiness assessment

For each ticket assess all six dimensions and score 1–5.

### 1. Requirements Clarity (1–5)
- Is the objective clear?
- Is expected behaviour defined?
- Are assumptions documented?
- Are edge cases described?

### 2. Acceptance Criteria Quality (1–5)
- Are ACs measurable?
- Are outcomes verifiable?
- Are success and failure paths covered?
- Can testing be performed without further clarification?

### 3. Testability (1–5)
- Can behaviour be verified?
- Are test environments available?
- Is expected behaviour observable?
- Is validation practical?

### 4. Automation Readiness (1–5)
- Can automation be written immediately?
- Are inputs and outputs clear?
- Are dependencies manageable?
- Is automation worthwhile?

### 5. Observability (1–5)
- Are logs required?
- Are metrics required?
- Are audit events required?
- Are monitoring expectations defined?

### 6. QA Confidence (1–5)
- Would QA be confident testing this today?
- Are requirements sufficient?
- Are major unknowns resolved?

For every ticket assess logging, metrics and audit events as required / not required, then set coverage to Complete / Partial / Missing. Highlight missing observability requirements explicitly — these are often forgotten during refinement and expensive to retrofit. Give evidence and precise questions for each weak score. A score is an evidence-backed refinement aid, not a computed guarantee. Never turn a missing ticket detail into a guessed acceptance criterion.

## QA Readiness — RAG Status

Assign one of three statuses to every ticket:

| Status | Meaning |
|---|---|
| 🟢 **Green** | QA is confident to test this now. Requirements are clear, ACs are measurable, test environment is available or not needed. |
| 🟡 **Amber** | QA can test this but with caveats. One or more items need clarification, a dependency is outstanding, or observability is incomplete — but the ticket can still proceed with those items tracked. |
| 🔴 **Red** | QA cannot test this. Requirements are too vague, ACs are missing or unmeasurable, or the design is untestable as written. **Block this ticket until resolved.** |

Red readiness stops design-to-automation progression until refinement resolves the blocking questions.

## QA Ownership Classification

Every ticket must be assigned **one** category.

**Developer Validation Only** — QA Action: No
Examples: refactoring, internal code cleanup, validation extraction, helper methods, build script updates, dependency updates, internal configuration changes.

**QA Review Only** — QA Action: Review only
Examples: logging additions, monitoring improvements, feature flags, low-risk configuration changes. Manual verification may be sufficient.

**Integration Coverage Required** — QA Action: Yes
Examples: API changes, service interactions, contract changes, database interactions. Integration automation should be considered.

**E2E Coverage Required** — QA Action: Yes
Examples: customer journeys, multi-system workflows, authentication flows, business-critical functionality. E2E automation should be considered.

**Not Ready For Development** — QA Action: Block refinement outcome
Examples: missing requirements, unclear ACs, significant unknowns, untestable design.

## QA Recommendation

Output **exactly one** recommendation per ticket:

- ✅ No QA Action Required
- ✅ Manual Verification Only
- ✅ Integration Test Required
- ✅ E2E Test Required
- 🚫 Not Ready For Development

Match the ownership classification to exactly one recommendation. Internal changes with adequate developer tests do not automatically need QA automation.

## Testing Prerequisites

For every ticket that requires QA action, identify what is needed before tests can be written or run:

**Environment and Access:**
- [ ] Test environment access
- [ ] External service access (API gateway, OAuth provider, etc.)
- [ ] Credentials and secrets (API keys, OAuth clients, etc.)
- [ ] Any required tooling or CLIs

**Test Data:**
- [ ] Fixtures or test profiles relevant to the domain
- [ ] Any seed data or known-good inputs required by the test environment
- [ ] Certificate fixtures (if testing mTLS or cert validation)

**Dependencies:**
- [ ] Dependent tickets that must be completed first
- [ ] Dependent infrastructure that must exist

**Mocking Strategy:**
- [ ] Can external calls be mocked, or do real systems need to be up?
- [ ] Is a test environment available, or will this be blocked?

Flag any prerequisites that are unresolved as **blockers** in the ticket output. Never ask the user to provide secret values; record required environment-variable names only.

## Risk-Based Test Prioritisation

Rank tickets, features, test cases, or areas by risk to focus QA effort where it matters most.

### 1. Change Impact (1–5)
How much does this change affect the system?

| Score | Meaning |
|---|---|
| 5 | Core system path — auth, payments, data writes, primary user journey |
| 4 | Important feature used frequently or by many users |
| 3 | Secondary feature, supporting workflow, or internal tooling |
| 2 | Minor UI change, content update, or low-traffic path |
| 1 | Cosmetic change, documentation update, config tweak |

### 2. Failure Criticality (1–5)
What is the impact if this fails in production?

| Score | Meaning |
|---|---|
| 5 | System unavailable, data loss, security breach, regulatory breach |
| 4 | Core feature down, significant user impact, revenue affected |
| 3 | Degraded experience, workaround available |
| 2 | Minor inconvenience, easily recoverable |
| 1 | No user impact if it fails |

### Risk Score

`Risk Score = Change Impact × Failure Criticality`

Maximum score: 25 (highest risk). Minimum: 1 (lowest risk).

### Apply modifiers (optional)

| Modifier | Adjustment |
|---|---|
| Recently changed code with no existing tests | +5 |
| Known flaky area or history of bugs | +3 |
| Dependent on external service or integration | +2 |
| Has existing high-quality automated test coverage | −3 |
| Out of scope for this release | Force to 0 |

Items with no existing test coverage should be bumped one tier up regardless of score. Apply domain knowledge to override scores where appropriate and explain it. The model is a starting point.

### Risk tiers

- **Must Test (Risk ≥ 16):** Full test coverage required before release.
- **Should Test (Risk 6–15):** Cover happy path and at least one negative case.
- **Smoke / Spot Check (Risk 3–5):** Quick manual check or single integration test sufficient.
- **Skip (Risk ≤ 2):** No automated test action required for this release.

When two items have the same risk score, prioritise the one with higher **Failure Criticality**.

## Testing Prerequisites and estimation

Classify automation effort as None / Low / Medium / High using `effort-estimation.md`; do not estimate hours unless explicitly requested and supported by locally evidenced work. Report unresolved prerequisites and Red blockers before estimating actionable effort.

## Ticket Output Format

```text
<TICKET> — <Summary>

QA Recommendation:    <exactly one recommendation>
QA Ownership:         <exactly one ownership category>
QA Readiness:         <Green / Amber / Red>

Scores:
	Requirements Clarity:    <1–5>/5
	Acceptance Criteria:     <1–5>/5
	Testability:             <1–5>/5
	Automation Readiness:    <1–5>/5
	Observability:           <1–5>/5
	QA Confidence:           <1–5>/5

Key Concerns:
	- <evidence-backed concern>

Questions for Refinement:
	- <focused question>

Observability Review:
	Logging Required:       <Yes / No / Unknown>
	Metrics Required:       <Yes / No / Unknown>
	Audit Events Required:  <Yes / No / Unknown>
	Coverage Status:        <Complete / Partial / Missing / Unknown>

Testing Prerequisites:
	- [ ] <prerequisite and status; never include secret values>

Automation Impact: <None / Low / Medium / High>

Change Impact: <1–5> — <justification>
Failure Criticality: <1–5> — <justification>
Risk Score: <impact × criticality, with modifiers stated>

Suggested Coverage:
	- <requirement-linked coverage>
```

## Sprint / Queue Summary

After all tickets are analysed, provide:

### Refinement Summary

```text
Tickets Reviewed:          X
Ready For Development:     X
Needs Clarification:       X
Not Ready For Development: X
```

### QA Action Summary

```text
No QA Action Required:    X
Manual Verification Only: X
Integration Coverage:     X
E2E Coverage:             X
```

### Highest Priority Refinement Items

List tickets requiring immediate discussion before the sprint can proceed.

### Common Requirement Gaps

Identify recurring issues across the sprint. Examples:
- Missing negative scenarios
- Missing observability requirements
- Missing error handling definitions
- Missing acceptance criteria
- Missing automation strategy

### Risk-Based Test Priority

| Priority | Ticket | Summary | Impact | Criticality | Risk Score | Recommended Action |
|---|---|---|---|---|---|---|
| 1 | <ticket> | <summary> | <1–5> | <1–5> | <score> | <action> |

Provide Must Test, Should Test, Smoke / Spot Check and Skip groups with the tier definitions above. For each ticket preserve its readiness, recommendation, ownership, scores, evidence, concerns, questions, observability, prerequisites and automation impact.

## Important Guidance

Do not assume every ticket requires QA automation. It is acceptable — and encouraged — to recommend **“✅ No QA Action Required”** when:

- Developer-owned unit tests provide sufficient coverage
- The change is internal only with no customer-facing behaviour changes
- Existing integration / E2E coverage is unaffected

Avoid recommending automation that provides little value or increases maintenance burden. Focus on risk, coverage gaps, and refinement quality rather than maximising test count. The primary goal is helping the team make good refinement decisions and focus QA effort where it delivers the most value.
