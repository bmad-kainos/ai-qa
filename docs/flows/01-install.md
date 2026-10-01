# 1. Install, update, verify and uninstall

These commands are run from a separate AI-QA checkout and target a project repository. `install.sh` and `install.ps1` behave the same way.

## Install

```mermaid
flowchart TD
  A([./install.sh install /path/to/project]) --> B{Target is the AI-QA<br/>checkout itself?}
  B -- yes --> X1[/Refuse and exit/]
  B -- no --> C{Manifest already<br/>exists?}
  C -- yes --> X2[/Refuse: use update or verify/]
  C -- no --> D{Existing qa* agents,<br/>qa-* skills or qa* instructions<br/>not owned by AI-QA?}
  D -- yes, no --prefix --> X3[/Abort and list collisions/]
  D -- "no, or --prefix x" --> E[Stage payload/.github files<br/>rename qa → x if --prefix]
  E --> F{--dry-run?}
  F -- yes --> P[/Print planned writes and exit - nothing changed/]
  F -- no --> G[Copy agents, skills and framework files]
  G --> H[Add or replace the marked pointer block in<br/>.github/copilot-instructions.md<br/>creating the file if absent]
  H --> I[Add the marked qa-work block to .gitignore]
  I --> J[Write .github/ai-qa/manifest.json<br/>with a SHA-256 for every installed file]
  J --> K([Done: open the project in VS Code<br/>and run @qa-configure])
```

## Update

```mermaid
flowchart TD
  A([./install.sh update /path/to/project]) --> B[Read the manifest and the installed version]
  B --> C{For each payload file}
  C -- unchanged --> C1[Skip]
  C -- "installed hash == manifest hash<br/>(nobody edited it)" --> C2[Replace it]
  C -- edited locally --> C3[Keep it and write file.ai-qa-new - warn]
  B --> D{For each file dropped from the payload}
  D -- unmodified --> D1[Delete it]
  D -- modified --> D2[Keep it - warn]
  C1 & C2 & C3 & D1 & D2 --> E[Rewrite the manifest]
  E --> F[Print CHANGELOG sections newer than the installed version]
  F --> G{docs/migrations.md has<br/>refresh-required: in range?}
  G -- yes --> H([Tell the user to run @qa-configure refresh])
  G -- no --> I([Done])
```

## Verify and uninstall

```mermaid
flowchart LR
  subgraph verify
    V1[Hash every manifest file] --> V2[Check both marked blocks]
    V2 --> V3[Compare the version with the source VERSION]
    V3 --> V4{Project layer present?}
    V4 -- no --> V5[WARN: run qa-configure]
  end
  subgraph uninstall
    U1[Remove unmodified manifest files] --> U2[Remove the marked blocks<br/>restoring the files byte-for-byte]
    U2 --> U3[List modified files and leave them]
    U3 --> U4[Remove the manifest and any empty dirs it created]
    U4 --> U5{--purge confirmed?}
    U5 -- yes --> U6[Also delete the project layer,<br/>baselines and qa-work]
    U5 -- no --> U7[Keep the project layer, baselines and qa-work]
  end
```
