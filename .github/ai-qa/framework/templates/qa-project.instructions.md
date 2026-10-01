---
applyTo: "{{test_globs}}"
---

# QA project instructions

For files matched by this `applyTo`, read the applicable sections of `.github/ai-qa/project/project.md` and `.github/ai-qa/project/conventions/testing.md`, plus other relevant project conventions. Follow the repository's established tests, fixtures, naming, assertions, test data and commands.

Precedence for project choices is: user instruction > project conventions > neighbouring code > selected pack > framework defaults. The safety gates in `.github/ai-qa/framework/method/safety.md` cannot be overridden by any of these. Never include secret values. If project evidence conflicts with conventions, record Drift and suggest `qa-configure refresh`; do not edit project configuration from a test-generation task.