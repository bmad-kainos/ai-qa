| Field | Value |
|---|---|
| id | `cucumber-java` |
| tier | `conventions` |
| languages | Gherkin, Java |
| levels | Acceptance, integration, E2E |
| detection signals | `.feature` files, Java glue/step definitions and configured Cucumber runner |
| default paths | `src/test/resources/features/**/*.feature`; existing Java glue package only when not configured |
| run by path | Maven: `./mvnw test -Dcucumber.features="<feature-path>"` (only if the configured runner supports it) |
| run by tag | Maven: `./mvnw test -Dcucumber.filter.tags="@<tag>"` (only for an established tag/runner configuration) |
| report format | Configured Cucumber JSON/JUnit XML report and `execution.md` scenario/tag/environment evidence |
| anti-patterns | Imperative click scripts in Gherkin, static scenario state, giant scenarios, unscoped hooks, invented tags |

Select when existing `.feature` and Java glue confirm Cucumber. Determine runner, glue, scenario-state injection and tags first. This conventions pack does not provide a runnable build or permission to install Cucumber.
