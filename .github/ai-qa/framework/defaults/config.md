# QA project configuration — defaults and field guide

This reusable file is a **field guide**, not an active configuration. Configure creates or updates `.github/ai-qa/project/project.md` and `.github/ai-qa/project/conventions/*.md` after the project-adaptation approval gate; do not edit framework defaults or installed packs to configure a project. An unset field is `unknown`, not evidence for the example value below. Record source, confidence, date and user decision for each value in the project layer.

| Field | Value | Meaning |
|---|---|---|
| Project name | unknown | Human-readable name |
| Repository | unknown | Owner/repository or repository URL |
| Jira enabled | unknown | yes / no / unknown |
| Jira project key | unknown | Issue-ID prefix, e.g. `PROJ` in `PROJ-1234`; **not** a PAT, password, token or URL |
| Jira base URL | unknown | Public site URL only; no credentials |
| Confluence enabled | unknown | yes / no / unknown |
| Confluence space key | unknown | Space identifier; not a secret |
| Source root | unknown | Repository-relative directory |
| Test root | unknown | Repository-relative directory |
| Docs root | unknown | Repository-relative directory |
| Test framework | unknown | Observed language(s), runner(s) and versions |
| Install command | unknown | Do not run merely to discover |
| Validate command | unknown | Do not run without relevant authorization |
| Lint command | unknown | Do not invent |
| CI/CD | unknown | Pipeline path/system |
| Output directory | unknown | Repository-relative, user-confirmed destination for reports |
| Test branch | unknown | Explicitly confirm per-ticket; this is not a permanent assumed branch |
| Test naming pattern | unknown | Derive from existing tests |
| Fixtures / test data | unknown | Paths and data ownership |
| Ticket marker | unknown | Project-specific marker, or `none` |
| Test levels | unknown | Unit / integration / E2E / manual as observed |
| Code style | unknown | Applicable style guidance, imports and async conventions |
| API / authentication | unknown | Describe mechanism only; never write credentials |
| Environments | unknown | Allowed targets, test data and side-effect restrictions |
| Branch conventions | unknown | Project naming and protected branches |
| Provider / transport | unknown | Jira/ADO/GitHub/local sources; CLI/MCP/manual fallback; avoid assuming a particular tool exists |
| Secret variable names | unknown | Environment variable *names* only, never their values |
| Do Not | Never publish without explicit approval; never hardcode secrets | Add confirmed project-specific prohibitions |

Provider integrations are optional: read-only repository and pasted-ticket workflows remain available without Jira or Confluence. Never turn on an integration solely because a URL or key appears in a sample. A Jira project key is not an authentication credential; authentication belongs in the provider's approved secret store, never in Markdown.
