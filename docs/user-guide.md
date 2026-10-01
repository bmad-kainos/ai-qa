# User guide

## Before you start

1. Install AI-QA into the project (see [README](../README.md)) and run `install.sh verify`.
2. Open the project in VS Code with GitHub Copilot.
3. Switch to a non-default branch before any work that writes files. AI-QA never edits the default branch.

## Configure

Ask `@qa-configure`. It runs the procedure described in [configure](configure.md):

- It runs read-only discovery.
- It asks one question at a time, each with evidence and an *Option A (recommended)*. You can say "accept all".
- It shows the exact diff of the project layer.
- It writes only after you approve the L5 gate.

When it finishes, it lists what is ready, what is degraded, the first commands to try and an offer to take a baseline.

## Workflows

Ask `@qa design <ticket>` (or `automate`, `full`, `triage`). In every workflow:

- Analysis runs without pausing between steps and stops only at gates.
- Re-running a workflow reuses non-stale artefacts in `qa-work/<work-id>/`.
- You can skip steps; the skipped step is recorded in `index.md`.

| Workflow | Steps | Stops / gates |
|---|---|---|
| `design` | analyse-requirement → code-context (+ verify on a branch) → coverage-gaps (requirement) → design-tests → regression-risk → automation-plan → review-tests (design) → test-plan | Red readiness stops and offers refinement questions; design approval before the plan is finalised; QA Summary shown in chat |
| `automate` | design/spec → branch (propose / create local) → generate-tests → review-tests (code) → run-tests → analyse-failure loop → update index and test plan | L2 branch/commit, L3 unsafe runs, L5 dependency install |
| `full` | design → checkpoint → automate → offer publish / create-pr | All of the above; QA Summary shown at the end |
| `triage` | run or pasted/CI failure → analyse-failure → bug-report → publish | L4 for any external write |

Refinement is `qa-analyse-requirement` in `batch` mode (sprint, JQL or WIQL). Use `clarify` mode for an Option-A interview about one ticket.

The QA Summary columns are: Ticket · Readiness · Max risk · Coverage verdict · Scenarios written/not written · Automated/manual/not needed · Run result · Published.

## Using skills directly

Every skill works on its own. If an upstream artefact is missing, the skill gathers the minimum evidence itself.

| Need | Ask |
|---|---|
| Independent 13-area regression assessment | `qa-regression-risk` on a diff, ticket or description |
| Check a branch against requirements | `qa-code-context verify <branch>` |
| Read-only test inventory | `qa-coverage-gaps --inventory` |
| Tests from an OpenAPI spec | `qa-generate-tests` with the spec path |
| Classify a CI failure | `qa-analyse-failure <ci-run-url>` or paste the log |
| Weekly engineering update | `qa-tech-report weekly` |
| Baseline now, compare later | `qa-baseline snapshot`, later `qa-baseline compare` |
| Draft PR from the current branch | `qa-create-pr` (push and PR creation are separate L4 gates) |
| Update docs after a change | `qa-update-docs` |

## Work ids and artefacts

The work id is resolved in this order:

1. An explicit argument.
2. The ticket key in the current branch name, matched with `conventions/git.md`.
3. `adhoc-<yyyymmdd>-<slug>`.

| File | Contents | Default |
|---|---|---|
| `index.md` | Step status, staleness, traceability matrix, QA Summary, gate log | committed |
| `requirement.md` … `execution.md` | Per-step outputs | ignored |
| `logs/` | Raw logs | ignored |
| `outputs/` | `test-plan.md`, `comment.md`, `bug-*.md`, `test-data.*` | committed |

Change the policy through `qa-configure` (`qa-process.md` → *qa-work policy*).

## Integrations without MCP

Every operation has a manual fallback. For reads, paste the work item, page or log into chat. For writes, the skill writes the exact payload to `qa-work/<id>/outputs/` and tells you where to paste it. Every external write, including a manual hand-off that you then paste yourself, is preceded by an L4 gate that shows the action, target, exact payload and side effect.

## Fixture walkthroughs

The [fixtures](../fixtures/README.md) are the v1 validation targets. To try one:

1. Copy a fixture somewhere outside this checkout and run `git init` in it.
2. Install AI-QA into the copy and run `@qa-configure`.
3. Compare the result with `fixtures/_expected/<fixture>/`.

| Fixture | What to look for |
|---|---|
| `java-maven-restassured-azdo` | Maven + JUnit 5/REST Assured → `junit5-restassured` pack; Azure Pipelines and Boards (`AB#` syntax); help/list-only command verification |
| `ts-playwright-github` | Playwright API + e2e → `playwright-ts`; GitHub Actions, PR template, `#123` issues |
| `python-pytest-jira` | pytest + httpx → `pytest`; `*.atlassian.net` → Jira Cloud ◐, confirmed by a `serverInfo` probe or one question |
| `dotnet-no-pack` | xUnit has no matching pack → reduced-confidence warning; a self-hosted Jira URL → Server/DC ◐ |
| `empty-repo` | No tests or CI → ∅ findings, ★ defaults dated after approval, offer of a gated scaffold |
| `conflicting-signals` | ⚠ Jest vs Vitest, Jira vs ADO, competing branch patterns, each asked once with evidence |
| `monorepo-workspaces` | Two workspace scopes; v1 configures a single scope path and asks which |

Never install into this checkout; the installer refuses.
