# QA process conventions

Configure renders this source into `.github/ai-qa/project/conventions/qa-process.md` after discovery and L5 approval. Values require evidence. These conventions cannot weaken `method/safety.md`.

## Readiness

| Threshold / decision owner | Value | Status | Evidence/source |
|---|---|---|---|
| Six scores, RAG, ownership and recommendation | <project threshold/owner; framework rubric applies unless an approved extension exists> | <status> | <source> |

## Definition of done and QA evidence

| Evidence / approval requirement | Value | Status | Evidence/source |
|---|---|---|---|
| Required FR/NFR, test, run, review and release evidence | <rule> | <status> | <source> |

## Test plan destination and timing

| Destination / when plan is published | Value | Status | Evidence/source |
|---|---|---|---|
| <local path or provider destination and timing> | <rule> | <status> | <source> |

## Comment templates

| Provider / template path | Value | Status | Evidence/source |
|---|---|---|---|
| <template or none found> | <rule> | <status> | <source> |

## Extra regression areas

| Area | Why included | Status | Evidence/source |
|---|---|---|---|
| <project area beyond framework's mandatory 13> | <reason> | <status> | <source> |

## Fix loop

| Max iterations / scope / owner | Value | Status | Evidence/source |
|---|---|---|---|
| <project rule; framework hard limits remain> | <rule> | <status> | <source> |

## Commands safe to run (L3 exemptions)

| Command and selector | Environment / duration / data effects / cleanup | Status | Evidence/source |
|---|---|---|---|
| <explicit safe command or none> | <constraints> | <status> | <source/confirmation> |

## Work-id rule

| Rule | Value | Status | Evidence/source |
|---|---|---|---|
| <explicit → branch pattern → ad-hoc fallback> | <project-specific syntax/pattern> | <status> | <conventions/git evidence> |

## qa-work policy

| Commit / ignore / retention policy | Value | Status | Evidence/source |
|---|---|---|---|
| <default: commit index.md and outputs/; ignore everything else> | <approved project override if any> | <status> | <source/approval date> |

## Scenario format

| Format | Value | Status | Evidence/source |
|---|---|---|---|
| <`bdd` (Given / When / Then) or `steps` (numbered steps with expected results); see `method/scenario-format.md`> | <value> | <status> | <existing manual tests, AC style, or confirmation; `★` with date if default> |

## Locale

| Locale | Value | Status | Evidence/source |
|---|---|---|---|
| <locale; framework candidate en-GB> | <value> | <status> | <source> |

## Team options

| Option | Enabled? | Status | Evidence/source |
|---|---|---|---|
| Keep Confluence page empty until testing | <yes/no> | <status> | <source/confirmation> |
| Use `.sql` test data | <yes/no> | <status> | <source/confirmation> |
| Branch description length 10–45 characters | <yes/no> | <status> | <source/confirmation> |

Options are not defaults; enable only with project evidence or user confirmation. Default fix loop is maximum 3 iterations, stopping early on repeat; fix test defects only and append attempts to `execution.md`.