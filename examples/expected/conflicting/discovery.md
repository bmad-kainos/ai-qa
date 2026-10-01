# Discovery — conflicting

| Domain | Status | Conclusion | Evidence | Note |
|---|---|---|---|---|
| Test command | ⚠ Conflict | Older guide uses `npm test`; contributor guide uses Playwright | `README.md:3`, `CONTRIBUTING.md:3`, `package.json:4-7` | Both commands exist but select different suites. |
| Jira deployment | ⚠ Conflict | Internal self-hosted URL suggests Server/DC; atlassian.net URL suggests Cloud | `README.md:3`, `CONTRIBUTING.md:3`, `docs/adr/0001-legacy-tracker.md:3` | Do not silently pick newer URL. |
| Test stack | ◐ Inferred | Playwright dependency exists | `package.json:8-10` | No test source/config sample available. |
| Git/PR | ? Could not check | No historical branch or PR data | Fixture context | Inspect when in real repository. |

Sample: README, CONTRIBUTING, ADR and manifest (4/4 sources of convention statements). Examples: `README.md:3`, `CONTRIBUTING.md:3`, `package.json:5-6`.

## Needs your input

- Which test command is authoritative for QA and does the legacy command have a use?
- Is the work-item deployment Cloud, Server/DC, or both? Confirm with `serverInfo` if accessible.
