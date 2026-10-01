# Manual scenario format

Manual test scenarios are written in one of two formats. The project chooses one in `.github/ai-qa/project/conventions/qa-process.md` under **Scenario format**; `qa-configure` records it. If the setting is absent, use `bdd` and say that this is the framework default.

Everything else about a scenario is the same in both formats: the selection rules in `dedup-rule.md`, the categories, the quality criteria, the **Scenarios Not Written** list, `Covers: FRn, NFRn` traceability and the approval gates. Only the shape of the scenario body differs. Do not mix formats within one work item.

| Value | Name | Use when |
|---|---|---|
| `bdd` | Given / When / Then | The project writes acceptance criteria or manual tests as Given/When/Then, or has no preference (framework default) |
| `steps` | Numbered steps with expected results | The project writes manual tests as step tables or test-management style cases, or does not use BDD |

## Fields common to both formats

Every scenario has:

- A sequential number and a descriptive name.
- Category tags.
- `Covers: FRn, NFRn`.
- The environment, setup and test data, with how the data is named and cleaned up.
- An evidence placeholder, so the tester can attach screenshots or output.
- A result block, used when the scenario is executed: `Result`, `Status: PASS / FAIL / BLOCKED` and `Notes`.

## `bdd`

```gherkin
GIVEN <precondition>
WHEN <action>
THEN <expected result>
AND <additional assertion>
```

Merge several acceptance criteria that one business flow exercises into one scenario with multiple `AND` assertions.

## `steps`

```md
**Preconditions:** <environment, data and state before step 1>

| # | Action | Expected result | Evidence |
|---|---|---|---|
| 1 | <what the tester does> | <observable outcome> | |
| 2 | <next action> | <observable outcome> | |

**Cleanup:** <how to restore state and remove test data>
```

Each step has exactly one action and one observable expected result. Merge several acceptance criteria that one business flow exercises into one scenario with additional steps or additional expected results. Do not turn a step table into a script of UI clicks; each step still checks a business outcome or a real boundary.

## Publishing to Confluence

`qa-publish` renders the scenarios-only page. Never put analysis, risk or requirement breakdowns on that page.

Both formats share:

- A sequential zero-padded H3 per scenario: `Test Scenario 01 — <Scenario Title>`, blue `rgb(0,82,204)` when rendered.
- Only `Result`, `Status` and `Notes` after the scenario body.
- Verification CLI, SQL or API snippets in code blocks after the step or line they verify.

Per format:

- **`bdd`:** bold GIVEN, WHEN, THEN and AND labels, each on its own line, with a blank evidence line after each.
- **`steps`:** a Confluence table with the columns `#`, `Action`, `Expected result` and `Evidence`, with the Evidence column left empty for the tester. Preconditions go above the table and Cleanup below it.

Check the rendered page in either case; do not assume Markdown conversion is lossless.

## Choosing the format (qa-configure)

`qa-configure` decides the format during its Confirm step:

1. Look for evidence of the existing style: how acceptance criteria are written in recent tickets or docs, any manual test-case documents or templates, and the project's definition of done.
2. If the evidence is consistent, recommend that format as Option A and ask for confirmation.
3. If the evidence conflicts (`⚠`) or is absent (`∅`), ask once. Offer `bdd` as Option A, being the framework default, and `steps` as Option B.
4. Record the answer in `qa-process.md` with its status and evidence. If `bdd` is applied only as a default, mark it `★` with the date.

A project can change the setting later with `qa-configure refresh`. Artefacts already written keep their format until `qa-design-tests` is run again.
