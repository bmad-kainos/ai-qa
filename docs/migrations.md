# Migrations

## v1.0.0

Initial version; no previous framework manifests to migrate. After an update, review any `.ai-qa-new` conflicts before running `qa-configure refresh`. Framework updates do not migrate or overwrite `.github/ai-qa/project/` or baselines. Compare changed methods or packs to the project's rendered instructions; refresh is the only writer of project-owned adaptations.

To flag a framework release that requires adaptation refresh, add a standalone `refresh-required: <version>` line for each applicable version. The installer prints `This update requires qa-configure refresh` when that version falls between the installed and new framework versions.
