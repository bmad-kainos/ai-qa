# Framework pack catalog

Exactly seven packs live at `packs/<id>/`. Configure chooses an applicable pack **only after** inspecting actual test runner, language, existing tests, `.github/ai-qa/project/project.md` and `.github/ai-qa/project/conventions/*.md`. Each pack has `pack.md` and an `instructions.template.md` that can be adapted into the project conventions layer after approval. Do not edit reusable packs to configure a project. Overlapping file extensions do not prove a runner; use only the selected pack.

| Pack | Tier | Support |
|---|---|---|
| [playwright-ts](playwright-ts/pack.md) | Full | Playwright TypeScript UI and HTTP |
| [pytest](pytest/pack.md) | Full | pytest Python unit, API and E2E |
| [junit5-restassured](junit5-restassured/pack.md) | Full | JUnit 5 + REST Assured Java API |
| [selenium-java](selenium-java/pack.md) | Conventions | Selenium WebDriver Java |
| [cucumber-java](cucumber-java/pack.md) | Conventions | Cucumber BDD Java |
| [cypress-ts](cypress-ts/pack.md) | Conventions | Cypress TypeScript |
| [jest-vitest](jest-vitest/pack.md) | Conventions | Jest/Vitest TypeScript |

Full packs also provide `generation.md` and a Markdown `examples/` directory showing traceable inventories and fenced, illustrative Orders API source snippets. Snippets are not installed test files. Full means actionable guidance, **not** that dependencies are installed, generated tests pass, or an environment is verified. Conventions packs contain guidance only; never invent a runnable harness or install packages solely from a pack.

For OpenAPI and REST contracts, select a full pack matching the **existing** runner. Inventory documented paths, inputs, responses and security; cover valid, invalid, boundary, auth and schema cases only where contract-backed. Unspecified status codes or formats are questions, not facts. If no selected pack fits, document a manual test inventory and request/inspect established conventions. Never publish secrets or run state-changing tests without authorization.

Adapted from Feabhas `.github/instructions/frameworks/**`, `.github/skills/api-tests/**` and `.github/skills/openapi-to-tests/SKILL.md` at `b788dc10809d1fbc3e4a199b02b7ee83fd11baaf`; retain its MIT copyright/license notice in distribution.
