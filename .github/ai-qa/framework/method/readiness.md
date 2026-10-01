# QA readiness and ownership

For a ticket or feature, justify six scores from **1 (insufficient) to 5 (strong)**:
requirements clarity, measurable acceptance criteria, practical testability,
automation readiness, observability and QA confidence. Note missing access, data,
environment, dependencies and whether logging, metrics or audit events are needed
and testable. A score is an evidence-backed refinement aid, not a computed guarantee.

Assign a single readiness outcome: **Green** if QA can verify it now; **Amber** if it can
proceed with explicitly owned caveats; **Red** if essential behaviour, criteria or a
verification route is undefined. Red stops design-to-automation progression until
refinement resolves the blocking questions. Give exactly one ownership classification:
**Developer Validation Only**, **QA Review Only**, **Integration Coverage Required**,
**E2E Coverage Required**, or **Not Ready For Development**. Match it to exactly one
recommendation: **No QA Action Required**, **Manual Verification Only**,
**Integration Test Required**, **E2E Test Required**, or **Not Ready For Development**.
Internal changes with adequate developer tests do not automatically need QA automation.

State evidence and precise questions for each weak score; never turn a missing ticket
detail into a guessed acceptance criterion. For a backlog provide counts by readiness
and recommended action, highlighting Red blockers before estimating effort.
