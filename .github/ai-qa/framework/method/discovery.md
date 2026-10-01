# Repository discovery and session Project Context

Discovery is read-only (L0). Read `safety.md`, `precedence.md`, this method,
`.github/ai-qa/project/project.md` and the applicable project conventions if
they exist. The installed defaults and templates are *examples*, not project
facts. QA produces a **session** Project Context; only `qa-configure` may write
the persistent project layer after L5. Narrow the search to the requested
repository/feature and revisit evidence when the branch or requirements change.

## Evidence notation — seven distinct statuses

| Mark | Status | Use |
|---|---|---|
| ✓ | **Observed** | Directly inspected in a named file/line, configuration, command output or confirmed user statement; identify which. |
| ◐ | **Inferred** | Plausible pattern based on evidence; state the reasoning and at least one representative sample. Do not present it as a confirmed convention. |
| ⚠ | **Conflict** | At least two sources disagree; show **both** values, their paths/links and freshness before asking for resolution. |
| ∅ | **Not found** | A bounded, recorded search for this item found nothing; state the searched scope, not “does not exist anywhere”. |
| ? | **Could not check** | Access, permissions, absent tool, unavailable branch or missing data prevented inspection; explain the blocker. |
| ✗ | **No consistent convention** | A representative sample shows incompatible real practices; cite divergent examples, not merely lack of search results. |
| ★ | **Default established** | Only `qa-configure`, after the user's L5-confirmed adaptation, may record a fallback; include the decision date, approver and rationale. QA must never mint ★. |

Keep `∅` and `?` separate: a negative search is not an access failure. Do not
turn `◐` into `✓` because multiple files share an extension. For a statement
about a convention, record **sample size and proportion** (`files examined /
relevant files identified`) and name **2–3 real, representative examples**
when available. If fewer exist, show all and say so. Sample distinct
modules/test levels to avoid extrapolating from one directory; larger or
heterogeneous areas need more evidence. Report mixed patterns as `✗`, and
contradictory authoritative configuration as `⚠`.

## Source order and safe access

1. Confirm repository, branch/revision and task scope; read the installed
   project description/conventions without silently changing them.
2. Search local README/contribution/architecture docs, manifests and runner
   configs; then inspect representative source/tests, fixtures, CI and
   deployment *configuration*. Record paths and line numbers (`path:line`),
   search/inspection commands, branch/commit and observation date. Inspect
   data and scripts as text; do **not** execute install, migration, deployment,
   test-suite or provisioning commands during discovery.
3. Use user-supplied requirements/links with their provenance. Only after a
   provider and transport are **confirmed configured and accessible** may
   read-only remote issue/docs searches augment local evidence; do not assume
   an MCP server, token or POC helper exists. If unavailable, request pasted
   relevant content and mark remote claims `?`, not `∅`.
4. Compare current evidence against project conventions. For each discrepancy
   retain both sides with `⚠` and route persistent changes to `qa-configure`.
   Read only the framework packs/methods/provider recipes relevant to the task.

## Fifteen discovery domains

Record evidence/status (or a bounded-search/access reason) for **each** domain.
“Not applicable” needs evidence just like any other conclusion.

| # | Domain | Look for |
|---|---|---|
| 1 | Project identity and ownership | Repository/purpose, teams, contact and source of truth. |
| 2 | Component architecture | Modules, service boundaries and critical journeys. |
| 3 | Technology stack | Languages/versions, manifests, build and package tooling. |
| 4 | Source and documentation layout | Source roots, docs roots and generated content. |
| 5 | Test inventory | Frameworks/versions, unit/integration/E2E/manual roots and levels. |
| 6 | Test conventions | Names, markers, assertions, test selectors and styles across a sampled proportion. |
| 7 | Fixtures and test data | Fixture helpers, data provenance, isolation, retention and cleanup. |
| 8 | API and interface contracts | OpenAPI/schema, endpoints, events, gateway and backward compatibility. |
| 9 | Authentication and permissions | Auth mechanism, roles, secret *variable names* and test identities; never credential values. |
| 10 | Data stores and dependencies | Databases, caches, queues, external services and ownership. |
| 11 | Environments and deployment | Local/staging/production distinctions, feature flags, rollout and safe targets. |
| 12 | CI/CD and validation | Workflows/jobs, actual documented commands, reports and coverage sources. |
| 13 | Git and review practice | Default/protected branches, branch names, PR/review and commit conventions. |
| 14 | Requirements and documentation sources | Local specs, user-provided ticket, confirmed issue/wiki provider and revision. |
| 15 | QA reporting and observability | Work artefacts, run/evidence destinations, logs, metrics, audit and defect flow. |

For domains 6–7 especially, do not claim a project-wide rule from one test.
Quantify the sampling fraction and give two or three actual paths/names. For
domains with inaccessible environments, record `?` rather than trying live
tests. Missing optional integrations do not prevent ticket analysis from
user-provided content. A failed configured ticket fetch may be retried **once**;
then request title, description and acceptance criteria.

## Output and questions

Present a concise, dated Project Context snapshot with the 15 domains,
status, fact/inference, supporting `path:line` or link, inspected revision
and sampled fraction. List exclusions and freshness limits. Include a
**Needs your input** section containing only blocking `⚠`/`?` decisions or
essential missing scope; for each ask one focused question, show both conflict
sides or the access blocker, and state what the answer unlocks. Other gaps can
remain as `∅` without repeated questioning.

Route persistent setup/refresh to `qa-configure`; route focused QA requests to
their matching skills. The full ticket-to-test-plan flow needs a concrete
ticket ID, explicit planning intent and confirmed test branch, but individual
skills accept a feature or pasted requirements without inventing a ticket.
