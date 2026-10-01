# Contributing

How to add a test pack or a provider. For every change:

1. Add a CHANGELOG entry.
2. If existing installations must re-render or reconfigure, add a `refresh-required: <version>` line to [migrations](migrations.md).
3. Run `python3 -m unittest discover -s tests`.

Don't pin models, add AI-generated markers, or add runtime dependencies or client code to the framework files.

## Adding a pack

Packs live in `.github/ai-qa/framework/packs/<id>/`. Start from `packs/_TEMPLATE/`.

| File | Tier | Contents |
|---|---|---|
| `pack.md` | all | id, tier, languages, levels, detection signals, default paths, run-by-path and run-by-tag command templates, report format, anti-patterns |
| `instructions.template.md` | all | Front-matter with `applyTo: "{{globs}}"`, then the template sections: Locators / selectors, Waiting & synchronisation, Assertions, Structure & fixtures, Test data, Anti-patterns. Must state that the project's conventions take precedence |
| `generation.md` | full | How `qa-generate-tests` writes tests with this stack: inventory first, categories (happy, contract, negative, boundary, security, headers), file layout, fixtures/builders, lint/compile |
| `examples/` | full | Real, small, idiomatic source files |

Rules:

- Detection signals must be observable in a repository (dependencies, config files, imports). An extension alone is not enough.
- Command templates are templates. `qa-configure` records the project's real commands in `conventions/testing.md`, and skills only use those.
- `applyTo` is rendered only from discovered project paths, and only selected packs are rendered.
- Packs cover test conventions only. Don't add language-style instruction files.

Also add the pack to `packs/README.md`.

## Adding a provider

Providers live in `.github/ai-qa/framework/providers/<provider>.md`. The operations they implement, and the fields each must return, are in `providers/operations.md`.

A provider file contains:

1. **Deployment sections** (for example `## Deployment: Cloud` and `## Deployment: Server/DC`): how to identify the deployment, the API version, the auth method and the endpoint differences. Deployment logic lives only here, never in skills.
2. **For each operation and each supported transport:**
   - **MCP:** tool-name hints, with a note to verify them against the available tools.
   - **CLI:** exact commands.
   - **REST:** both `curl` and `Invoke-RestMethod` recipes. Tokens come from environment variables named in `conventions/integrations.md` and are never printed.
   - **Manual:** a paste-in or paste-out procedure, with output written to `qa-work/<id>/outputs/`.
3. **Format rules:** how Markdown converts to the provider's body format (for example Jira wiki/ADF, Confluence storage, ADO Markdown).
4. **Verification status:** mark untested variants **unverified**.

Rules:

- MCP is optional. A manual fallback must always exist.
- L4 operations are invoked only through `qa-publish`, which applies the gate protocol. `qa-create-pr` is the exception: it creates PRs through `repo.pr.create` behind its own L4 gate.
- If the preferred transport fails, the skill says so and falls back to the next one.

Also:

- Update the transport matrix in `operations.md`.
- Add the provider's evidence signals to `method/discovery.md` (Integrations domain) so `qa-configure` can recognise it.
- Add the provider to `templates/conventions/integrations.md`.
