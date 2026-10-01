# Selenium + Java — conventions tier

**ID:** `selenium-java` · **Tier:** conventions · **Template:** [instructions.template.md](instructions.template.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `selenium-java` / `conventions` / Java / browser integration, E2E |
| Detection signals | Selenium WebDriver dependency, existing driver lifecycle and Page Objects |
| Default paths (only if no project convention) | `src/test/java/**` for tests; existing page-object package |
| Run by path/tag | Existing Maven/Gradle test-class selector; runner tags/categories only if configured |
| Report | Selected cases, environment, observed result and evidence in approved `qa-work/<id>/` after L1 |
| Anti-patterns | `Thread.sleep`, shared static driver, mixed waits, absolute XPath, hardcoded driver paths |

Select only when existing Java test sources/config show Selenium WebDriver. Follow the project's JUnit/TestNG version and Page Object conventions.

- Keep locators and page interaction in page/component objects; tests express behavior and assert observable results.
- Prefer stable `By.id` or stable CSS selectors, not absolute XPath or position-dependent paths.
- Use explicit `WebDriverWait` and `ExpectedConditions` for actual state. No `Thread.sleep` and do not combine implicit with explicit waits.
- Create/close the driver with the existing test lifecycle; always quit reliably and isolate parallel tests. Use the project's existing driver manager, not hardcoded executable paths.
- Use existing assertion library with meaningful failure messages, controlled test data and externally managed credentials.

Do not invent a runnable Java test harness, packages or browser infrastructure from these conventions. Execute only existing targeted tests when environment and permissions allow.
