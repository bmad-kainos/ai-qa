# Adding a provider

Providers live in `.github/ai-qa/framework/providers/<provider>.md`. The operation contract they implement is in `operations.md`.

## Contract

A provider implements some or all of these operations:

| Level | Operations |
|---|---|
| L0 | `workitem.get`, `workitem.search`, `docs.search`, `docs.get`, `repo.pr.list`, `ci.runs`, `ci.run.get`, `ci.test-results` |
| L4 | `workitem.comment`, `workitem.create`, `docs.publish` (create/update/append), `repo.pr.create` |

Each operation must return the fields that `operations.md` requires. For example, `workitem.get` returns title, description, ACs, type, status, links, comments and updated.

## File structure

1. **Deployment sections** (for example `## Deployment: Cloud` and `## Deployment: Server/DC`). Each section covers how to identify the deployment, the API version, the auth method and the endpoint differences. Deployment logic lives **only** here, never in skills.
2. **For each operation and each supported transport:**
   - **MCP:** tool-name hints, with a note to verify them against the available tools.
   - **CLI:** exact commands.
   - **REST:** both `curl` and `Invoke-RestMethod` recipes. Tokens come from environment variables named in `conventions/integrations.md` and are never printed.
   - **Manual:** a paste-in or paste-out procedure, with output written to `qa-work/<id>/outputs/`.
3. **Format rules:** how Markdown converts to the provider's body format (for example Jira wiki/ADF, Confluence storage, ADO Markdown).
4. **Verification status:** mark untested variants **unverified**.

## Rules

- MCP is optional. A manual fallback must always exist.
- L4 operations are invoked only through `qa-publish`, which applies the gate protocol. `qa-create-pr` is the exception: it creates PRs through `repo.pr.create` behind its own L4 gate.
- If the preferred transport fails, the skill says so and falls back to the next one.
- Never add client code or libraries to the framework files.

## Checklist

1. Add the provider file and update the transport matrix in `operations.md` and `docs/architecture.md`.
2. Teach `qa-configure` how to recognise the provider: add its evidence signals to `method/discovery.md` (Integrations domain) and add the provider to `templates/conventions/integrations.md`.
3. Add a CHANGELOG entry. Add `refresh-required:` to `docs/migrations.md` if installations need reconfiguring.
