# Adding a pack

Packs live in `.github/ai-qa/framework/packs/<id>/`. Start from `packs/_TEMPLATE/`.

## Files

| File | Tier | Contents |
|---|---|---|
| `pack.md` | all | id, tier, languages, levels, detection signals, default paths, run-by-path and run-by-tag command templates, report format, anti-patterns |
| `instructions.template.md` | all | Front-matter with `applyTo: "{{globs}}"`, then the template sections: Locators / selectors, Waiting & synchronisation, Assertions, Structure & fixtures, Test data, Anti-patterns. Must state that the project's conventions take precedence |
| `generation.md` | full | How `qa-generate-tests` writes tests with this stack: inventory first, categories (happy, contract, negative, boundary, security, headers), file layout, fixtures/builders, lint/compile |
| `examples/` | full | Real, small, idiomatic source files (for example an Orders API contract and boundary suite) |

## Rules

- Detection signals must be observable in a repository (dependencies, config files, imports). An extension alone is not enough.
- Command templates are templates. `qa-configure` records the project's real commands in `conventions/testing.md`, and skills only use those.
- `applyTo` is rendered only from discovered project paths, and only selected packs are rendered.
- Don't add language-style instruction files; packs cover test conventions only.
- Don't pin models, add AI-generated markers or add runtime dependencies to the target.

## Checklist

1. Add the pack folder with the files for its tier.
2. Add the pack to `packs/README.md`.
3. Add a CHANGELOG entry. If existing installations need re-rendering, add `refresh-required: <version>` to `docs/migrations.md`.
4. Run `python3 -m unittest discover -s tests`.
