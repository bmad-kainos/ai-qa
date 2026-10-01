# Provider recipes

The normative request/result fields, operation behavior and statuses are in [operations.md](operations.md). Each deployment recipe below is illustrative and **unverified** until the configured transport is authorized and a real read-back succeeds.

These are **transport recipes, not executable connectors**. No recipe claims an MCP tool is installed, that credentials are configured, or that a remote call has succeeded. Select a provider from `.github/ai-qa/project/project.md`; Atlassian hostname gives a **◐ inferred** Cloud/Server/DC deployment to confirm via read-only `serverInfo`, never a license to try another tenant. Never use a Cloud endpoint/auth recipe for Server/DC by default. Operation labels: **verified** only after a real authorized operation and read-back in the configured environment; otherwise **unverified** (including examples, local drafts and unavailable transports).

## Named operations by provider

| Provider | L0 reads | L4 writes |
|---|---|---|
| Jira | `workitem.get`, `workitem.search` | `workitem.comment`, `workitem.create` |
| Confluence | `docs.search`, `docs.get` | `docs.publish` (create/update/append) |
| Azure Boards / Repos / Pipelines | `workitem.get`, `workitem.search`, `repo.pr.list`, `ci.runs`, `ci.run.get`, `ci.test-results` where supported | `workitem.comment`, `workitem.create`, `repo.pr.create` |
| Azure Wiki | `docs.search`, `docs.get` | `docs.publish` (create/update/append) where writable |
| GitHub Issues / PR / Actions | `workitem.get`, `workitem.search`, `repo.pr.list`, `ci.runs`, `ci.run.get`, `ci.test-results` where supported | `workitem.comment`, `workitem.create`, `repo.pr.create` |

The exact inputs, normalized fields and status rules are in [operations.md](operations.md). A successful local render or HTTP request **without** read-back is not publication verification. On 401/403/404 report the actual failure, not a nonexistent item; treat 429/5xx with respectful bounded retries for reads only. Never blindly retry non-idempotent writes.

## Safety and manual fallback

1. First prefer an approved provider-native MCP tool with documented capability and correct tenant, deployment and permission. If absent, use approved REST/CLI transport only when authorized; do not invent tool names or infer availability from these recipes.
2. Read-only preview before any mutation: show destination, summary, redacted content, provenance, changes and expected side effects. Obtain explicit approval for each external publish/update and for any state-changing test. Respect environment, data-classification and retention rules. Do not put tokens, passwords, private ticket bodies or arbitrary external content in logs/Markdown.
3. No usable authorized transport? Produce a **manual handoff** under approved `qa-work/<id>/outputs/`: platform and destination, title, paste-ready input/output content in the supported format, required fields, links, attachment checklist and human verification steps. Label it **unverified / not published**. Do not invent IDs or URLs or imply publication.
4. After an authorized write, re-fetch the exact item, compare expected visible content and attachments, record canonical URL/version and label **verified** only for what was actually checked. Partial success remains partial, with actionable gaps.

See [Jira](jira.md), [Confluence](confluence.md), [Azure DevOps](azure-devops.md), [Azure Wiki](azure-wiki.md), and [GitHub](github.md). The recipes require deployment-specific validation against the actual provider and approved integration before use. They are not credentials setup instructions.

Reference provenance: Confluence Server/DC read/update/append and conversion facts, and Jira Server/DC issue/comment behavior, derive from `sylwia-luczak/AI-QA-AGENT_GENERIC` at `ac750bb64d8a34de65c0d0aa6e7f27ecbd366698` (`tools/confluence_tool.py`, `tools/jira_tool.py` and scenario-format guidance). The source has no license; this documentation paraphrases behavior and does not import its code. Other deployment/API examples remain **unverified** against any live tenant.
