# Method B: ZAPI Script

## Step 1: Fetch the story

Use the configured work-item provider to fetch the story. Request its title, description, status and type.

From the response, extract:
- **Story key** (the configured work-item identifier)
- **Story summary** (used in the Test issue summary)
- **Acceptance Criteria** - lines matching the configured AC format in the description
- **Testing Notes** - lines under a `Testing Notes` heading
- **Out of Scope** - lines under an `Out of Scope` heading (do NOT create steps for these)

---

## Step 2: Create one Test issue for the story

Create a single `Test` issue using the configured provider's work-item creation operation, if and when a future Zephyr-capable integration is approved.

**Summary format:** `Tests: <WORK-ITEM-KEY> - <story summary>`

**Description** - a structured table summarising all ACs and testing notes. Verification steps are entered separately via the ZAPI in Step 3; this table is a human-readable at-a-glance reference on the issue itself.

Use the target provider's supported work-item format:

```
*Story:* [<WORK-ITEM-KEY>|<configured-work-item-url>]
*Story Summary:* <story summary>
*Sprint:* <sprint name>
*Test Approach:* <manual or automated approach>
*Test Type:* Functional

*Preconditions:*
- <list any environment or setup requirements before the test can be run>
- <sprint test cycle created, if applicable>

*Acceptance Criteria and Testing Notes Coverage:*

|| AC Ref || Step Description || Test Data / Preconditions || Expected Result || Attachment Required ||
| AC01 | <what the tester does for this AC> | <input values, URLs, config, or "None"> | <observable outcome confirming the AC is met> | Yes - <describe evidence> / No |
| AC02 | <what the tester does for this AC> | <input values, URLs, config, or "None"> | <observable outcome confirming the AC is met> | Yes - <describe evidence> / No |
| TN01 | <what the tester does for this testing note> | <input values or "None"> | <expected outcome> | Yes - <describe evidence> / No |

*Out of Scope:*
- <items from the story's Out of Scope section, or "None">
```

**Table column guidance:**
- **AC Ref** - AC01, AC02, ..., TN01, TN02 for Testing Notes
- **Step Description** - plain-English description of the action the tester takes
- **Test Data / Preconditions** - URLs, file paths, payload values, or environment state needed. Write "None" if not applicable
- **Expected Result** - the specific, observable outcome that confirms the AC is satisfied
- **Attachment Required** - `Yes - <what to capture>` (e.g. screenshot, curl output, console log) or `No`

Record the returned **issue key** and **numeric issue ID**. Both are needed in subsequent steps.

---

## Step 3: Add structured test steps via the Zephyr ZAPI

Post each AC as a numbered step to the Zephyr test steps endpoint. This populates the **Step / Test Data / Expected Result** table in the Zephyr Test Details panel.

The endpoint is: `POST /rest/zapi/latest/teststep/{issueId}`

> **`issueId`** is the numeric issue ID from Step 2, not the key.
>
> **Auth note:** The Zephyr ZAPI only accepts HTTP Basic auth with `username:password`. It does not accept Personal Access Tokens (PATs) or Bearer tokens. PATs work for standard Jira REST endpoints but are rejected by the ZAPI with `401 AUTHENTICATED_FAILED`. This is a Zephyr Server limitation. Use an approved secret store for the actual password; never paste it into a command, file or chat.

```python
import os, httpx

JIRA_URL = os.environ["JIRA_URL"]
ZAPI_AUTH = (os.environ["JIRA_USER"], os.environ["JIRA_PASSWORD"])

def add_test_steps(issue_id: str, steps: list[dict]) -> None:
    """
    Post structured test steps to a Zephyr Test issue.

    Each step dict must have:
      - "step":   the action to perform (what the tester does)
      - "data":   test data or preconditions (empty string "" if none)
      - "result": the expected outcome for this specific step
    """
    for i, step in enumerate(steps, start=1):
        response = httpx.post(
            f"{JIRA_URL}/rest/zapi/latest/teststep/{issue_id}",
            json={
                "step": step["step"],
                "data": step.get("data", ""),
                "result": step["result"],
            },
            auth=ZAPI_AUTH,
        )
        if response.status_code in (200, 201):
            print(f"  ✓ Step {i} added")
        else:
            print(f"  ✗ Step {i} FAILED - {response.status_code}: {response.text}")
```

**Step authoring rules:**
- One step per AC - label each step clearly with the AC reference (e.g. `AC01:`)
- Add Testing Notes as additional steps after the ACs, labelled `TN01:`, `TN02:` etc.
- `data` holds preconditions, URLs, or input values the tester needs
- `result` is the expected outcome for that specific step
- The final step's `result` should be the overall pass condition for the test

**Example steps:**
```python
add_test_steps("<numeric-issue-id>", [
    {
        "step": "AC01: <describe the action the tester takes for this AC>",
        "data": "<input values, URLs, config, or empty string if none>",
        "result": "<observable outcome that confirms the AC is met. Screenshot attached if required.>",
    },
    {
        "step": "AC02: <describe the action the tester takes for this AC>",
        "data": "<input values or empty string>",
        "result": "<expected outcome>",
    },
    {
        "step": "TN01: <describe the action for this testing note>",
        "data": "<any specific setup or input>",
        "result": "<expected outcome>",
    },
])
        "result": "<observable result from the configured checks>",
    },
    {
        "step": "TN01: <check the agreed workflow trigger and rerun behaviour>",
        "data": "<confirmed trigger configuration>",
        "result": "<evidence from the distinct runs>",
    },
])
```

---

## Step 4: Link the Test issue to the parent Story

Use the configured provider's issue-link operation to create an "is tested by" link:

```
link_type="<confirmed link type>"
inward_issue_key="<TEST-KEY>"  # Test issue
outward_issue_key="<STORY-KEY>"  # Story
```

If the link type is unavailable, read the configured provider's link types first; do not guess.

---

## Step 5: Post a testing progress comment on the Story

Post a comment on the Story using the configured provider after preparing the exact payload and receiving explicit approval. The comment format has two states:

**State A - Initial (tests created, not yet executed):**

```
*Test case created for this story (<Sprint name>):*

|| Test Key || Summary || ACs Covered || Status ||
| [<TEST-KEY>|<url>] | Tests: <story summary> | AC01, AC02, AC03, AC04 | ⬜ Unexecuted |

Test linked to this story via the "Tests" ("is tested by") issue link.
Test added to the sprint test cycle, if applicable.

_Generated by the create-zephyr-tests reference, {date}_
```

**State B - After execution (update the comment once tests are run):**

Use the configured provider's supported comment-update capability to update the existing comment. Replace the status column and add an Evidence section and Outstanding checklist:

```
*Test case created and executed for this story (<Sprint name>):*

|| Test Key || Summary || ACs Covered || Status ||
| [<TEST-KEY>|<url>] | Tests: <story summary> | AC01, AC02, AC03, AC04 | ✅ Pass |

Test passed in the sprint cycle. Linked to story via the "Tests" ("is tested by") issue link.

*Evidence:*
- AC01: <brief description of evidence, e.g. screenshot attached to test issue>
- AC02: <run URL> - <what it showed>

*Outstanding before story can be closed:*
# <any remaining items, e.g. PR merged to the confirmed base branch>

_Updated by the create-zephyr-tests reference, {date}_
```

> If any ACs need a screenshot as evidence, note `(screenshot attached to test issue)` in the Evidence section and remind the user to attach it directly to the Zephyr Test issue before marking it as passed.

---

## Step 6: Output pytest marker stub (optional)

If the story will have automated pytest tests, output the marker to add once the test is written:

```python
# Add this marker to your pytest test class or method:

@pytest.mark.jira("<STORY-KEY>")       # Story
@pytest.mark.zephyr("<TEST-KEY>")     # Test issue key
class TestExampleStory:
    def test_ac01_...(self): ...
    def test_ac02_...(self): ...
```

This output is informational only. Use the configured test-generation skill to scaffold the actual test file.
