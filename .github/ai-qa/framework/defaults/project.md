# Project Context — discovery template

This reusable **field guide** documents what to discover and how to label evidence. The renderable source templates live under `.github/ai-qa/framework/templates/`. After L5 approval Configure writes the sourced project description in `.github/ai-qa/project/project.md` and operating rules in `.github/ai-qa/project/conventions/*.md`. Other QA workflows read these files without writing them. Do not treat examples or unverified guesses as project facts.

| Topic | Finding | Source / observed at | Status |
|---|---|---|---|
| Project, repository and purpose | unknown | — | ∅ |
| Languages, versions and package manager | unknown | — | ∅ |
| Source, test and documentation layout | unknown | — | ∅ |
| Test frameworks, test levels and suites | unknown | — | ∅ |
| Naming, fixtures, data and ticket marker | unknown | — | ∅ |
| Install, validation, lint and CI commands | unknown | — | ∅ |
| API contracts, auth and service boundaries | unknown | — | ∅ |
| Environments, test data ownership, side effects | unknown | — | ∅ |
| Jira, ADO, GitHub, Confluence and transport availability | unknown | — | ∅ |
| Branch and PR conventions | unknown | — | ∅ |
| Output locations and reporting conventions | unknown | — | ∅ |
| Safety, privacy and other Do Not rules | unknown | — | ∅ |

Use all seven statuses in `method/discovery.md`: `✓` Observed,
`◐` Inferred (basis/sample), `⚠` Conflict (both sides), `∅` Not found
after bounded search, `?` Could not check, `✗` No consistent convention
after representative sampling, and `★` dated/approved Configure default.
The `∅` cells above are *template placeholders*, not proof a search was
performed; Configure must replace them with actual findings and statuses.
Include path:line/link, command, revision/date and confidence. Project Context
is a concise map, not a store for secrets, personal data or ticket payloads.
