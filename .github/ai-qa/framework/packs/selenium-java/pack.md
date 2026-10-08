| Field | Value |
|---|---|
| id | `selenium-java` |
| tier | `conventions` |
| languages | Java |
| levels | Browser integration, E2E |
| detection signals | Selenium WebDriver dependency, configured driver lifecycle and representative Page Objects/tests |
| default paths | `src/test/java/**` for tests; existing page-object package only when paths are not configured |
| run by path | Maven: `./mvnw -Dtest="<ClassOrMethod>" test`; Gradle: `./gradlew test --tests "<fully.qualified.Class>"` (templates only) |
| run by tag | Existing JUnit `@Tag` or TestNG group selector only when configured; use the project's documented command |
| report format | Configured JUnit/TestNG report and `09_execution.md` case/environment/evidence summary |
| anti-patterns | `Thread.sleep`, shared static driver, mixed waits, absolute XPath, hardcoded driver paths, test logic in page objects |

Select only when existing Java test sources/config show Selenium WebDriver. Follow the project's JUnit/TestNG version, lifecycle and Page Object conventions. This is conventions guidance, not a runnable harness or permission to install browser infrastructure.
