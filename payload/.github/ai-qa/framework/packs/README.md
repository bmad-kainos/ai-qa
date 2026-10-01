# Framework pack catalogue

`qa-configure` selects packs per test path after inspecting the actual runner, the dependencies and representative tests. It renders `instructions.template.md` to `.github/instructions/qa-<pack>.instructions.md`, with `applyTo` set to discovered paths only. Never edit packs to configure a project. Project conventions take precedence over pack guidance.

| Pack | Tier | Covers | Files |
|---|---|---|---|
| [playwright-ts](playwright-ts/pack.md) | Full | Playwright TypeScript/JavaScript, API + UI | pack, instructions, generation, examples |
| [pytest](pytest/pack.md) | Full | pytest (+ requests/httpx, Playwright-Python) | pack, instructions, generation, examples |
| [junit5-restassured](junit5-restassured/pack.md) | Full | JUnit 5 + REST Assured, Java/Kotlin API | pack, instructions, generation, examples |
| [selenium-java](selenium-java/pack.md) | Conventions | Selenium WebDriver, Java | pack, instructions |
| [cucumber-java](cucumber-java/pack.md) | Conventions | Cucumber BDD, Java | pack, instructions |
| [cypress-ts](cypress-ts/pack.md) | Conventions | Cypress, TypeScript | pack, instructions |
| [jest-vitest](jest-vitest/pack.md) | Conventions | Jest / Vitest, TypeScript | pack, instructions |

If no pack matches, AI-QA uses the existing project tests and warns that confidence is reduced. If no framework exists, it reports ∅, records ★ and offers a gated scaffold. A full-tier pack provides actionable generation guidance. It doesn't mean dependencies are installed or that generated tests pass.

Start new packs from [_TEMPLATE](_TEMPLATE/README.md). Pack content is adapted from Feabhas `.github/instructions/frameworks/**` and `.github/skills/api-tests/**` (MIT, see `../LICENSE-feabhas.txt`).
