# Output Format: Detailed

Use for: sprint review talking points, retrospective input, sprint report evidence, and detailed release notes.

---

## Format

```txt
Sprint / Period Summary -- [DATE] to [DATE]
==========================================

Overview
--------
[2-3 sentence summary of the period's work. What was the main focus? What was
 delivered? What is now possible that wasn't before?]


Features Delivered
------------------

[Feature name from commit or logical group]
Commits: abc1234, def5678
What changed: [Full description -- what was built, what it does]
Why it matters: [Business or technical value delivered]
Demo notes: [If relevant -- what to show in sprint review and how]

[Repeat for each feature]


Bug Fixes
---------

[Fix description]
Commit: abc1234
What was broken: [Description of the problem]
What was fixed: [Description of the resolution]
Impact: [Who / what was affected before the fix]


Infrastructure & CI Changes
---------------------------
[Describe pipeline, build, infrastructure-as-code, and deployment changes. Note if any changes
affect how developers work day-to-day.]


Test Coverage Added
-------------------
[Describe what tests were added, what they cover, and any coverage improvement.]


Breaking Changes
----------------
[!] [If any BREAKING CHANGE commits exist, list them explicitly here with
migration notes or impact on consumers. If none, write: None.]


Carry-Over / Not Completed
--------------------------
[Optional: note anything that was in-progress but not merged by the period end]
```

---

## Rules

- Write commit hashes inline as plain text (no backticks or links)
- Write demo notes for any feature items that are visible or verifiable
- Always include a Breaking Changes section (even if empty, state "None")
- Identify Carry-Over items if prior work-item context is available

---

## Workflow Tips

- Run on the confirmed base branch after the period close to capture all merged work
- For each feature item, the Demo notes field gives you a sprint review talking point
- If a configured work-item key appears in a commit message, use `workitem.get` for context only if the provider is configured; don't imply lookup succeeded when unavailable
- Carry-over items not merged will not appear in the git log; check configured in-progress work items separately when appropriate
