# Framework pack catalog and authoring notes

Select a pack only after inspecting the actual test runner, language, representative tests, `.github/ai-qa/project/project.md` and `.github/ai-qa/project/conventions/*.md`. Render an instruction template only for the selected project test paths. Project conventions take precedence; do not edit reusable packs to configure a project.

| Pack | Tier | Support |
|---|---|---|
| [playwright-ts](../playwright-ts/pack.md) | Full | Playwright TypeScript and JavaScript API/UI tests |
| [pytest](../pytest/pack.md) | Full | pytest Python unit, API and E2E tests; existing requests/httpx and Playwright-Python setups |
| [junit5-restassured](../junit5-restassured/pack.md) | Full | JUnit 5 + REST Assured Java/Kotlin API tests |
| [selenium-java](../selenium-java/pack.md) | Conventions | Selenium WebDriver Java |
| [cucumber-java](../cucumber-java/pack.md) | Conventions | Cucumber BDD Java |
| [cypress-ts](../cypress-ts/pack.md) | Conventions | Cypress TypeScript |
| [jest-vitest](../jest-vitest/pack.md) | Conventions | Jest/Vitest TypeScript |

Full packs include `generation.md` and real source examples under `examples/`. Conventions packs provide guidance only. Full does not mean dependencies are installed, a generated test passed, or an environment is verified. If no pack matches, use observed project tests with reduced confidence. If no framework exists, record `∅` and offer the gated scaffold workflow.

## Add a pack

Use this template directory as the structural starting point for a new pack. Fill every field in `pack.md`; set `applyTo: "{{globs}}"` in `instructions.template.md`; narrow rendered globs to observed project paths; and include the template sections. Full packs also need generation guidance and real, non-markdown-wrapped source examples. Keep runner-specific details out of shared language-style instruction files. Project `.github/ai-qa/project/conventions/testing.md` takes precedence over pack defaults.

Adapted from Feabhas `.github/instructions/frameworks/README.md` and `_TEMPLATE.md`, `.github/skills/api-tests/**`, and `.github/skills/openapi-to-tests/SKILL.md` at `b788dc10809d1fbc3e4a199b02b7ee83fd11baaf`. Retain the Feabhas MIT copyright and licence notice in distribution.
