# <Pack title>

| Field | Value |
|---|---|
| id | `<pack-id>` |
| tier | `full` or `conventions` |
| languages | `<language list>` |
| levels | `<supported levels>` |
| detection signals | `<manifest/config/test evidence; require representative sources>` |
| default paths | `<paths, used only when project conventions do not specify them>` |
| run by path | `<runner command template; project Commands take precedence>` |
| run by tag | `<runner command template; require existing tag support>` |
| report format | `<configured structured report and execution.md evidence>` |
| anti-patterns | `<stack-specific prohibited patterns>` |

## Locators / selectors
- <how to find elements/resources robustly; what to avoid>

## Waiting & synchronisation
- <auto-waiting versus explicit signals; the no-sleep rule>

## Assertions
- <preferred assertion style and observable contract>

## Structure & fixtures
- <test grouping, setup/teardown, isolation and parallelism>

## Test data
- <factories/builders, freshness, environment and secrets>

## Anti-patterns
- <short list of stack-specific patterns never to use>