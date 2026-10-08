# 3. Using AI-QA (`@qa` and skills)

## What every skill does

```mermaid
flowchart TD
  U(["Request"])
  U --> W["Resolve work-id"]
  W --> RD["Read project.md, conventions,<br/>framework method and<br/>fresh qa-work artefacts"]
  RD --> M{"Upstream artefact<br/>missing?"}
  M -->|yes| G["Gather the minimum itself<br/>(never refuse)"]
  M -->|no| DO["Run the procedure"]
  G --> DO
  DO --> S{"Side effect<br/>above L1?"}
  S -->|yes| GATE["Gate: show action, target,<br/>exact payload. Needs explicit yes"]
  S -->|no| OUT
  GATE --> OUT["Write the artefact<br/>and update index.md"]
  OUT --> DR{"Evidence contradicts<br/>the project layer?"}
  DR -->|yes| DRF["Record drift,<br/>suggest @qa-configure refresh"]
```

The work-id is the explicit argument, else the ticket key in the branch name (via `conventions/git.md`), else `adhoc-<yyyymmdd>-<slug>`.

## Routing through `@qa`

```mermaid
flowchart TD
  Q(["@qa request"]) --> R{"What kind?"}
  R -->|"design, automate,<br/>full or triage"| WF["Run the workflow"]
  R -->|"refinement"| BA["qa-analyse-requirement<br/>in batch mode"]
  R -->|"focused task"| SK["The one matching skill"]
```

You can also call any `qa-*` skill directly and skip `@qa`.

## design

```mermaid
flowchart TD
  D1["qa-analyse-requirement"] --> RD{"Readiness Red?"}
  RD -->|yes| STOP(["Stop: refinement questions"])
  RD -->|no| D2["qa-map-code"]
  D2 --> D3["qa-coverage-gaps"]
  D3 --> D4["qa-design-scenarios"]
  D4 --> D5["qa-regression-risk"]
  D5 --> D6["qa-automation-plan"]
  D6 --> D7["qa-review-tests (design)"]
  D7 --> DA{"Design approved?"}
  DA -->|yes| D8["qa-test-plan"]
  D8 --> DS(["TL;DR, Next Steps and QA Summary in chat"])
```

`qa-map-code` also runs `verify` when you give it a branch. `qa-coverage-gaps` runs at requirement scope. `qa-review-tests` runs as a subagent where the host supports it.

## automate

```mermaid
flowchart TD
  A1["Approved design or spec"] --> A2["qa-create-branch<br/>propose, then create local (L2)"]
  A2 --> A3["qa-generate-tests<br/>inventory first (L1)"]
  A3 --> A4["qa-review-tests (code)"]
  A4 --> A5["qa-run-tests<br/>(L3 unless safe)"]
  A5 --> A6{"Failures?"}
  A6 -->|yes| A7["qa-analyse-failure<br/>fix tests only, max 3 rounds"]
  A7 --> A5
  A6 -->|no| A8(["Update index and test plan"])
```

Installing dependencies is a separate L5 gate.

## full and triage

```mermaid
flowchart LR
  F1["design"] --> F2{"Checkpoint<br/>approval"}
  F2 -->|yes| F3["automate"]
  F3 --> F4(["QA Summary,<br/>offer publish or PR (L4)"])
```

```mermaid
flowchart LR
  T1["Run, pasted log<br/>or CI URL"] --> T2["qa-analyse-failure"]
  T2 --> T3["qa-bug-report<br/>(draft)"]
  T3 --> T4["qa-publish (L4)"]
```

## External operations

```mermaid
flowchart TD
  SK["Skill requests an operation<br/>e.g. workitem.get"]
  SK --> CFG["conventions/integrations.md<br/>provider, deployment,<br/>transport order"]
  CFG --> PF["providers/ file<br/>(Cloud or Server/DC section)"]
  PF --> T1{"Preferred transport<br/>works?"}
  T1 -->|yes| OK(["Result"])
  T1 -->|no| T2{"Next transport<br/>works?"}
  T2 -->|yes| OK
  T2 -->|no| MAN["Manual: paste input in,<br/>or save the payload to<br/>qa-work/id/outputs/"]
```

Transports are MCP, CLI (`gh`, `az`) and REST, in the order the project configures. Every L4 write goes through `qa-publish` (PRs through `qa-create-pr`) behind an explicit approval gate.
