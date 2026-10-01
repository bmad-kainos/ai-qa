# Output Format: Standard

Use for: weekly team notes, team lead communications, and other configured team channels.

---

## Format

```txt
Team update -- week of [DATE] to [DATE]
================================================

New Features
------------
The team implemented [description of feature commits, written as full sentences].
[One paragraph per feature or logical group of related commits.]

Bug Fixes
---------
[Description of fix commits as full sentences.]

Infrastructure & CI
-------------------
[CI/build commits -- focus on what improved and why it matters.]

Testing
-------
[Test commits -- what coverage was added or improved.]

Code Quality
------------
[Refactor/docs commits -- keep brief unless significant.]
```

---

## Rules

- Write in plain English, not commit message shorthand
- Group related commits into a single paragraph rather than listing each one
- Explain the why where the commit message makes it clear
- Omit maintenance/dependency updates unless they resolve a security issue
- Flag any BREAKING CHANGE commits prominently

---

## Workflow Tips

- Run near the end or start of a working week
- The standard format is designed for pasting into a project-approved team channel or documentation page
- Exclude maintenance/dependency bumps from the output — they add noise without value
- For security fixes, always mention them explicitly even if brief
