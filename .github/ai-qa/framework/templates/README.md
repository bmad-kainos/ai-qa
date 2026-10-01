# Generic adaptation templates

These files are **framework-owned installable sources**, not project configuration. The
installer copies this directory under `.github/ai-qa/framework/templates/` but must **not**
create `.github/ai-qa/project/` or active `.github/instructions/qa*.instructions.md`.

After read-only discovery and an explicit L5 preview/approval, `qa-configure` renders
`project.md`, `discovery.md` and precisely `conventions/{git,testing,qa-process,integrations,reporting}.md`
into the corresponding project-owned paths. `instructions/qa-project.instructions.md`
and `instructions/qa-pack.instructions.md` are inert source templates; Configure
renders them to target `.github/instructions/qa-project.instructions.md` and
`.github/instructions/qa-<pack>.instructions.md` only with separate L5 approval.
Never leave placeholder globs in active rules.
Installation and updates must preserve project-owned configuration and user content.
