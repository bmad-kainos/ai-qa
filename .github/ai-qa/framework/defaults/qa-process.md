# QA process defaults

These are framework candidates, not project findings. Configure may apply them after discovery and confirmation, marking each applied value `★` with a date. Project-approved conventions take precedence, but cannot weaken `method/safety.md`.

## Readiness

Use `method/readiness.md`: six evidence-backed 1–5 scores, Green/Amber/Red, one QA ownership classification and exactly one matching recommendation. Red stops design pending refinement.

## Definition of done and QA evidence

Candidate: stable FR/NFR IDs, evidence-linked coverage, scenario decisions including Scenarios Not Written, 13-area regression assessment, automation rationale, actual run evidence or explicit Not run, and an accurate QA Summary. Do not claim passing coverage from file existence.

## Test plan destination and timing

Candidate local destination: `qa-work/<work-id>/outputs/test-plan.md`. Publish only on request after exact destination/content approval (L4). For Confluence scenario uploads, wait until the user has reviewed the plan and is ready to test.

## Comment templates

No project comment template default. Use a project-confirmed template; draft in chat and obtain exact-content/destination L4 approval before posting.

## Extra regression areas

No project-specific areas by default. Always include the 13 framework areas in `method/regression-areas.md`; add discovered project-specific areas without removing required areas.

## Fix loop

Maximum 3 iterations; stop early if the same failure repeats. Fix test defects only, and only files created or modified in this work item. Never change product code, delete/skip/disable tests, or loosen assertions unless the relevant FR supports it. Append each iteration to `execution.md`.

## Commands safe to run (L3 exemptions)

None by default. Mark a command safe only after project evidence and explicit confirmation define scope, environment, duration, data effects and cleanup. Otherwise apply L3.

## Work-id rule

Resolve explicit argument → ticket from current branch matching project `Ticket syntax` / `Branch patterns` → `adhoc-<yyyymmdd>-<slug>`, per `method/work-id-and-git.md`.

## qa-work policy

Default: commit `index.md` and `outputs/`; ignore everything else. Projects may change this policy here after discovery and confirmation. Never commit secrets or confidential data.

## Scenario format

Candidate default: `bdd` (Given / When / Then). The alternative is `steps` (numbered steps with expected results). Both are defined in `method/scenario-format.md`. Configure asks when evidence conflicts or is absent; a value applied without evidence is marked `★` with a date.

## Locale

Candidate default: `en-GB`.

## Team options (not defaults)

- Keep the Confluence page empty until testing begins.
- Use `.sql` test data.
- Require 10–45 character branch descriptions.

Apply an option only when confirmed by project evidence or the user; do not silently enable it.