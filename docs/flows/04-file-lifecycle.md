# 4. File lifecycle in a target project

Each diagram shows what one stage does to the project's files. Green is created, amber is modified, red is removed and grey is kept.

```mermaid
flowchart LR
  P0["Project before AI-QA"] --> I["install"] --> C["configure"] --> U["use"] --> X["uninstall"]
```

## install (installer)

```mermaid
flowchart LR
  I(["install"])
  I --> A["Created"]
  I --> M["Modified"]
  A --> A1["2 agents<br/>qa, qa-configure"]
  A --> A2["21 skills<br/>.github/skills/qa-*"]
  A --> A3["framework<br/>.github/ai-qa/framework/**"]
  A --> A4["manifest.json"]
  M --> M1["copilot-instructions.md<br/>marked block added"]
  M --> M2[".gitignore<br/>marked block added"]
  classDef created fill:#d4edda,stroke:#28a745,color:#000
  classDef modified fill:#fff3cd,stroke:#e0a800,color:#000
  class A,A1,A2,A3,A4 created
  class M,M1,M2 modified
```

Either modified file is created if it doesn't exist. Nothing is removed, and no project code, tests, CI or docs are touched.

## configure (`qa-configure`, L5)

```mermaid
flowchart LR
  C(["configure"])
  C --> P["project layer<br/>.github/ai-qa/project/"]
  C --> R["rendered instructions<br/>.github/instructions/"]
  C --> M["MCP config<br/>.vscode/mcp.json"]
  P --> P1["project.md"]
  P --> P2["discovery.md"]
  P --> P3["conventions/<br/>5 files"]
  R --> R1["qa-project<br/>.instructions.md"]
  R --> R2["qa-pack<br/>.instructions.md<br/>one per selected pack"]
  M --> M1["only if MCP<br/>was chosen"]
  classDef created fill:#d4edda,stroke:#28a745,color:#000
  class P,P1,P2,P3,R,R1,R2,M,M1 created
```

On refresh, only the managed sections of these files change. Framework files, code, tests and dependency manifests are never touched.

## use (`qa` and skills)

```mermaid
flowchart LR
  U(["use"])
  U --> A["Created"]
  U --> M["Modified"]
  U --> G["Gated, not files"]
  A --> A1["qa-work/id/index.md<br/>and outputs/<br/>committed by default<br/>(numbered artefacts 01_ to 11_ ignored)"]
  A --> A2["qa-work/id/*.md<br/>and logs/<br/>git-ignored by default"]
  A --> A3["baselines/date.md<br/>and .json"]
  A --> A4["test files<br/>L1, non-default branch"]
  M --> M1["docs<br/>qa-update-docs, L1"]
  G --> G1["local branch<br/>or commit: L2"]
  G --> G2["push, PR, comments,<br/>pages: L4"]
  classDef created fill:#d4edda,stroke:#28a745,color:#000
  classDef modified fill:#fff3cd,stroke:#e0a800,color:#000
  classDef gated fill:#e2e3e5,stroke:#6c757d,color:#000
  class A,A1,A2,A3,A4 created
  class M,M1 modified
  class G,G1,G2 gated
```

Product code is never changed by the fix loop. Tests are never deleted, skipped or disabled. The default branch is never edited, and nothing is merged.

## uninstall (installer)

```mermaid
flowchart LR
  X(["uninstall"])
  X --> R["Removed"]
  X --> K["Kept"]
  R --> R1["unmodified installed files<br/>and manifest.json"]
  R --> R2["marked blocks<br/>(byte-for-byte restore)"]
  K --> K1["modified framework files<br/>(listed)"]
  K --> K2["project layer,<br/>baselines, qa-work"]
  K2 -.-> P["deleted only with<br/>--purge, confirmed"]
  classDef removed fill:#f8d7da,stroke:#dc3545,color:#000
  classDef kept fill:#e2e3e5,stroke:#6c757d,color:#000
  class R,R1,R2,P removed
  class K,K1,K2 kept
```

`copilot-instructions.md` and `.gitignore` are deleted only if AI-QA created them and they are now empty.
