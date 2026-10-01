# 1. Install, update, verify and uninstall

Run the installer from a separate AI-QA checkout, pointing at the project. `install.sh` and `install.ps1` behave the same way.

## Install

```mermaid
flowchart TD
  A(["install.sh install /path/to/project"])
  A --> B{"Target is the AI-QA repo?"}
  B -->|yes| X1["Refuse"]
  B -->|no| C{"Already installed?"}
  C -->|yes| X2["Refuse: use update"]
  C -->|no| D{"Name collision with<br/>qa* agents, skills or<br/>instructions?"}
  D -->|"yes, and no prefix given"| X3["Abort and list collisions"]
  D -->|"no, or a prefix is given"| E{"Dry run?"}
  E -->|yes| P["Print plan only"]
  E -->|no| G["Copy agents, skills<br/>and framework files"]
  G --> H["Add marked blocks to<br/>copilot-instructions.md<br/>and .gitignore"]
  H --> J["Write manifest.json<br/>with SHA-256 hashes"]
  J --> K(["Next: run @qa-configure"])
```

Collisions are checked against existing `qa*` agents, `qa-*` skills and `qa*` instructions that AI-QA doesn't own. Passing `--prefix x` renames everything from `qa` to `x`.

## Update

```mermaid
flowchart TD
  A(["install.sh update /path/to/project"])
  A --> B["Read manifest and version"]
  B --> C{"Each payload file"}
  C -->|unchanged| C1["Skip"]
  C -->|"hash matches manifest"| C2["Replace"]
  C -->|"edited locally"| C3["Keep, write .ai-qa-new"]
  B --> D{"Each file dropped<br/>from the payload"}
  D -->|unmodified| D1["Delete"]
  D -->|modified| D2["Keep and warn"]
  C1 --> E["Rewrite manifest"]
  C2 --> E
  C3 --> E
  D1 --> E
  D2 --> E
  E --> F["Print CHANGELOG<br/>entries since installed version"]
  F --> G{"refresh-required<br/>in docs/migrations.md?"}
  G -->|yes| H(["Run @qa-configure refresh"])
  G -->|no| I(["Done"])
```

## Verify

```mermaid
flowchart TD
  V1["Hash every manifest file"] --> V2["Check both marked blocks"]
  V2 --> V3["Compare installed and source version"]
  V3 --> V4{"Project layer present?"}
  V4 -->|no| V5["Warn: run @qa-configure"]
  V4 -->|yes| V6(["Verified"])
  V5 --> V6
```

Verify exits non-zero if any hash or marked block doesn't match.

## Uninstall

```mermaid
flowchart TD
  U1["Remove unmodified<br/>manifest files"] --> U2["Remove marked blocks<br/>(byte-for-byte restore)"]
  U2 --> U3["List modified files<br/>and leave them"]
  U3 --> U4["Remove manifest and<br/>empty dirs it created"]
  U4 --> U5{"--purge confirmed?"}
  U5 -->|yes| U6["Also delete project layer,<br/>baselines and qa-work"]
  U5 -->|no| U7["Keep project layer,<br/>baselines and qa-work"]
```
