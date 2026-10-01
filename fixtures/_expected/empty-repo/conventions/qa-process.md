# QA process — expected Configure defaults

- ★ Default established 2026-10-01 after user approval: locale `en-GB`; publish only on request.
- ★ Default established 2026-10-01 after user approval: commit `qa-work/<id>/index.md` and `outputs/`; ignore other work artefacts.
- ★ Default established 2026-10-01 after user approval: failure fix loop is limited to three iterations and never edits product code.
- ∅ Definition of done, project QA evidence, plan destination, manual ownership and safe test commands are not found.
- Until project commands are configured, no test command is assumed. Environment-dependent or long test execution remains subject to the L3 gate.

Defaults require user confirmation; they are not observations from `README.md:3`.
