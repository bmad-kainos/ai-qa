# Cucumber + Java — conventions tier

**ID:** `cucumber-java` · **Tier:** conventions · **Template:** [instructions.template.md](instructions.template.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `cucumber-java` / `conventions` / Gherkin, Java / acceptance, E2E |
| Detection signals | `.feature`, Java glue and configured Cucumber runner |
| Default paths (only if no project convention) | `src/test/resources/features/**/*.feature`, existing Java glue package |
| Run by path/tag | Existing runner's feature path/line selector or established tag expression |
| Report | Scenario/source/tag, observed result and evidence in approved `qa-work/<id>/` after L1 |
| Anti-patterns | Imperative click scripts in Gherkin, static scenario state, giant scenarios, unscoped hooks |

Select when existing `.feature` and Java step definitions confirm Cucumber; determine the project's test runner, glue, dependency injection and tagging before suggesting changes.

- Write declarative Gherkin about business behavior: `When the user signs in`, not click-by-click DOM commands. One behavior per scenario; use Scenario Outline + Examples for meaningful variants.
- Keep Background limited to shared preconditions. Avoid giant scenarios, conjunction steps and asserting implementation details in Gherkin wording.
- Step definitions should be thin adapters to existing Page Objects/service helpers. Reuse steps; hold scenario state in the project's dependency injection context, never Java `static` shared fields.
- Use `@smoke` / `@regression` tags only when the project defines them. Keep `@Before` / `@After` hooks small and scoped; isolate data and cleanup.
- Trace scenarios to requirements and assert outcomes in glue. No hardcoded credentials or production-changing flows without permission.

These are conventions, not a generated build, runnable fixture suite or permission to install Cucumber. Validate with an existing targeted runner command.
