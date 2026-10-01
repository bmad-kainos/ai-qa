# QA Discovery

> Generic installable template. Configure renders this to
> `.github/ai-qa/project/conventions/discovery.md` only after an L5 diff preview and approval.
> It records *where evidence was found*, not an unsourced conclusion.

<!-- ai-qa:managed:start -->
| Source to inspect | Finding / relevant paths | Revision or observed at | Status |
|---|---|---|---|
| README, architecture and contributing guidance | ∅ unknown | — | ∅ |
| Manifests and language/test-runner configuration | ∅ unknown | — | ∅ |
| Representative source, tests, fixtures and data | ∅ unknown | — | ∅ |
| CI workflows, scripts and reports | ∅ unknown | — | ∅ |
| API contracts, feature flags and deployment configuration | ∅ unknown | — | ∅ |
| Requirement, issue and documentation sources | ∅ unknown | — | ∅ |
| Test environments, access and cleanup constraints | ∅ unknown | — | ∅ |
| Branch, PR and reporting conventions | ∅ unknown | — | ∅ |

## Conflicting evidence

| Topic | Source A | Source B | Resolution / owner |
|---|---|---|---|
| ∅ none assessed | — | — | ∅ unknown |

Inspect the smallest relevant scope; do not run install scripts or live tests during
discovery. Cite paths and lines where feasible. A configured URL is not proof of access.
Use `✓` Observed, `◐` Inferred (basis and sample), `⚠` Conflict (both
sides), `∅` Not found after bounded search, `?` Could not check, `✗`
No consistent convention after representative sampling, or `★` a
dated user-approved default established only by Configure. Sample a
recorded proportion of relevant files and name 2–3 actual examples;
log path:line/commands. Never run the test suite for discovery.
<!-- ai-qa:managed:end -->

<!-- ai-qa:user -->
Project-authored discovery notes; preserve verbatim on refresh.
<!-- /ai-qa:user -->
