---
name: Cucumber + Java test conventions
description: Best practices for Cucumber BDD tests in Java.
applyTo: "{{globs}}"
---

# Cucumber + Java — test conventions

> Rendered by `qa-configure` for this project's selected test paths only. The project's `.github/ai-qa/project/conventions/testing.md` and neighbouring tests take precedence over this pack guidance (precedence: user instruction > project conventions > neighbouring code > pack > framework defaults).

## Gherkin (.feature)
- Write **declarative** scenarios about behaviour, not imperative UI clicks. Say "When the user signs in", not "When the user clicks #login".
- One behaviour per scenario; use `Scenario Outline` + `Examples` for data variations.
- Use `Background` only for steps truly common to every scenario. Avoid conjunction steps ("When X and Y").

## Step definitions
- Keep step defs thin — delegate to Page Objects / service helpers.
- Share state between steps with dependency injection (PicoContainer / Spring), never `static` fields.
- Reuse steps; don't duplicate near-identical glue.

## Tags & hooks
- Use tags (`@smoke`, `@regression`) to select subsets; keep `@Before`/`@After` hooks minimal and scoped by tag.

## Anti-patterns
- No imperative UI detail in `.feature` files, no shared static state, no assertions in `.feature` steps' wording, no giant scenarios.
