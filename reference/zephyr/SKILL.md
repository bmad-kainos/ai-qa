---
name: reference-zephyr-tests
description: Reference-only Zephyr test-case workflow retained for a future provider; not installed or invocable in AI-QA v1.
argument-hint: "[future Zephyr work-item workflow]"
---

# Create Zephyr Test Issues from a Work Item

## When to use
This is reference material only. Zephyr and Azure Test Plans are deferred beyond v1; this file is not installed by the installer and must not be invoked as an available skill. It is retained to seed a future provider. In a future implementation, given one or more work-item identifiers, the intended method is to:
1. Fetch the story's Acceptance Criteria and Testing Notes.
2. Create **one** Zephyr `Test` issue per story, with all ACs as structured test steps inside it.
3. Link the Test back to the parent Story ("is a test for" / "is tested by").
4. Post a testing progress comment on the Story.

> **Why one Test per Story?**
> Creating one Test issue per AC burns through the issue counter quickly (some Jira Server projects have a fixed issue limit). One Test per Story with per-AC steps gives the same traceability at a fraction of the issue count.

The original use cases were a story moved to "In Test" that needs test cases, starting test design for a sprint ticket, and requests to create test cases, add tests to a work item or scaffold tests for a story. These triggers describe future provider behaviour only.

## Reads
A future provider must read `.github/ai-qa/project/project.md`; `.github/ai-qa/project/conventions/integrations.md`, `git.md` and `qa-process.md`; `.github/ai-qa/framework/method/safety.md`, `artefacts.md` and `precedence.md`; and `.github/ai-qa/framework/providers/operations.md` plus the applicable provider recipe. This reference is not a v1 operation and must not be used to bypass provider configuration. If project context is absent, use read-only session evidence and suggest `qa-configure`; never edit the project layer.

## Work-id
Resolve per `.github/ai-qa/framework/method/git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
A future implementation would require the work-item key, confirmed provider/deployment/transport, Acceptance Criteria, Testing Notes, Out of Scope, sprint/cycle context and available Zephyr method. If prior artefacts are missing, gather the minimum yourself; never refuse. Do not request or persist secret values.

## Procedure
### Choose a creation method

| Method | When to use |
|--------|------------|
| **Excel import** (preferred) | One or more stories at once; ZAPI auth is unavailable; faster and requires no password |
| **ZAPI script** | Single story with rich manually-crafted step content; ZAPI credentials available |

Determine which method applies from the user's context or available credentials. For the reference procedures, load [method-excel.md](./method-excel.md) or [method-zapi.md](./method-zapi.md). If an error is encountered, load [error-handling.md](./error-handling.md) for the error reference table and environment requirements.

These methods describe a deferred capability. Do not execute provider writes from this reference; a future installed implementation must route any external work through `qa-publish` and require its L4 gate.

### Related skills
- `qa-generate-tests` — scaffold the automated test file and link test markers to the future test issue.
- `qa-analyse-requirement` — analyse whether a work item is ready for test before creating test cases.

## Output
A future installed implementation would record generated test identifiers, links, comment receipt and evidence in an artefact under `qa-work/<work-id>/`, with frontmatter per `.github/ai-qa/framework/method/artefacts.md`, and update `qa-work/<work-id>/index.md`. This reference creates no artefacts and performs no remote action.

## Side effects and safety
| Action | Level | Gate |
|---|---|---|
| Read reference files | L0 | No gate |
| Future local artefact writes | L1 | Non-default branch; workflow-plan approval applies; summarise changes |
| Future test issue, link or comment writes | L4 | Must use configured provider operations and exact `qa-publish` approval; unavailable in v1 |

## Drift
If future provider evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
