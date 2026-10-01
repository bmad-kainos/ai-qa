---
work-id: "<ticket-or-feature-id>"
skill: "<qa-skill-name>"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
  - source: "<ticket-or-repository-path-or-link>"
    revision: "<commit-or-document-revision-or-observed-time>"
---

# <Artefact title>

**Scope:** <work item and intended output>
**Status:** <draft / complete / blocked>

## <Skill-specific output>

<Evidence-linked result. Separate observed facts, inferences, recommendations and unknowns.>

## Drift

Record evidence that contradicts `.github/ai-qa/project/project.md`, project conventions or the selected pack. Include both sources, paths/lines, freshness and impact. Do not edit `.github/ai-qa/project/**`; suggest `qa-configure refresh` for persistent changes.

| Project statement / convention | Observed evidence | Status | Impact / recommendation |
|---|---|---|---|
| <statement or none observed> | <source path:line/revision> | <⚠ / other status> | <impact and refresh suggestion> |