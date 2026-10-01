---
name: qa-tech-report
description: Generate a technical or stakeholder report from live git history for a requested date range; use for concise, standard, detailed, business or weekly updates.
argument-hint: "[date range and concise/standard/detailed/business/weekly format]"
user-invocable: true
---

# Tech Report Generation
Extract and format git commit history into structured summaries suitable for sprint reviews, weekly team notes and stakeholder communications.

## When to use
Use when someone asks to generate a tech report, weekly update or team notes; summarise what shipped in a date range; prepare sprint review talking points; produce a concise “what did we deliver?” summary; or report project activity to a team or stakeholder.

**Perfect for:**
- Preparing sprint review demo talking points
- Writing weekly team notes
- Generating a changelog for a release
- Reviewing what changed in a date range before writing a test plan
- Onboarding someone to recent changes

**Not suitable for:**
- Reviewing code quality
- Generating test cases from commits
- Publishing reports without `qa-publish`

## Reads
Always read `.github/ai-qa/project/project.md` for project components and report grouping; `.github/ai-qa/project/conventions/reporting.md` sections `Audiences`, `Formats`, `Channel templates`, `Tech-report defaults` and `File naming`; `conventions/git.md` section `Commit types`; and `conventions/integrations.md` for the work-item provider if weekly mode is requested. Read `.github/ai-qa/framework/method/safety.md`, `git.md`, `artefacts.md`, `precedence.md`, `.github/ai-qa/framework/defaults/reporting.md` only when conventions are absent, the selected file under `references/`, live git history and any current prior artefacts. If the project layer is missing, use read-only session evidence and suggest `qa-configure`.

## Work-id
Resolve per `.github/ai-qa/framework/method/git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Invoke with a date range and output mode. Examples:

```text
since 2 weeks ago, concise
since 2026-05-19, standard
since 2026-05-01, detailed for sprint review
last sprint (2026-05-19 to 2026-06-01), standard
since last Monday, concise
```

Optionally narrow by path or branch:

```text
since 2 weeks ago, standard — src/ only
since 2026-05-19, detailed — confirmed base branch
```

Resolve relative dates to exact calendar bounds and state timezone. Get the requested ref, audience and mode (`concise` by default; `standard`, `detailed`, `business` or `weekly` when requested). If scope is missing or ambiguous, ask rather than silently widening it. A work ID is not assumed to be a tracker key.

## Procedure
### Mandatory first step — always run the git command
Before writing a single word of report output, run the git log command matching the requested range against the confirmed ref, with `--no-merges`:

```bash
# Open-ended range (start date only)
git log --since="<start-date>" --no-merges --format="%h | %ad | %an | %s" --date=short

# Bounded range (start and end given)
git log --after="<start-date>" --before="<end-date>" --no-merges --format="%h | %ad | %an | %s" --date=short
```

Use the requested path/ref filters when supplied and record the exact command, ref, timezone and range. The live git history is the only valid source for what changed in that range; do not infer from prior conversation, cached knowledge or workspace files.

### No commits — hard stop rule
If the command returns no output, the period has no commits. Calculate the exact calendar dates for the requested range (for example, “last 3 weeks” from today's date means today minus 21 days through today). Output only this, saved as the project-configured report file name:

```txt
Period: [START DATE] to [END DATE]

No commits were made during this period.
```

Stop. Do not fall back to an earlier period. Do not mention prior work or explain what the project does. Do not query work items or add commentary to this report. For an empty period, preserve this exact report text; record the report and the hard-stop outcome in the index gate/evidence log.

### Prerequisites
All modes require git access. Weekly mode additionally requires an available configured work-item provider to query in-progress items; without one, report that next-period data is not available rather than inventing commitments.

### Overview and output modes
Five output modes serve different audiences. Load only the requested mode's format file:

| Mode | Audience | Format | File |
|---|---|---|---|
| **Concise** (default) | Quick reference, internal team | Bulleted list of work items | `references/output-concise.md` |
| **Standard** | Weekly notes, team lead | Full-sentence descriptions grouped by type | `references/output-standard.md` |
| **Detailed** | Sprint review, retrospective, audit | Comprehensive change descriptions with context | `references/output-detailed.md` |
| **Business** | Non-technical stakeholders | Outcome-focused, jargon-light bullets | `references/output-business.md` |
| **Weekly** | Team weekly update | This week / Next week / Blockers in project format | `references/output-weekly.md` |

Use **concise** unless the user explicitly requests another mode. When trigger phrases overlap, Weekly takes precedence if the request explicitly mentions a weekly team update. Determine the mode, read only its `references/output-*.md`, and use only the plain-text template under its “Format” section while applying its “Rules”.

| Mode | When requested | File to read |
|---|---|---|
| **Concise** (default) | No mode specified, or “concise” | `references/output-concise.md` |
| **Standard** | “standard”, “weekly notes” | `references/output-standard.md` |
| **Detailed** | “detailed”, “sprint review”, “retrospective” | `references/output-detailed.md` |
| **Business** | “business”, “non-technical” | `references/output-business.md` |
| **Weekly** | “weekly update”, “team weekly update” | `references/output-weekly.md` |

Before generating any output:
1. Determine the requested mode (default: concise).
2. Read the corresponding `references/output-*.md` file.
3. Use only the plain-text template shown under “Format” in that file, and apply its “Rules” as constraints.

### Git commands
These commands are provided for reproducibility; run the date-range command before writing claims.

#### List all commits since a date (one-line overview)
```bash
git log --since="2 weeks ago" --no-merges --oneline
git log --since="2026-05-19" --no-merges --oneline
```

#### List commits with author, date and subject
```bash
git log --since="2 weeks ago" --no-merges --format="%h | %ad | %an | %s" --date=short
```

#### List commits with full body (for detailed mode)
```bash
git log --since="2 weeks ago" --no-merges \
	--format="commit %h%nDate:    %ad%nAuthor:  %an%nSubject: %s%nBody:%n%b%n---" \
	--date=short
```

#### Filter by path
```bash
git log --since="2 weeks ago" --no-merges --oneline -- <confirmed-path>/
```

#### Date range between two specific dates
```bash
git log --after="<start-date>" --before="<end-date>" --no-merges --oneline
```

#### Supported `--since` date formats
| Input | Example |
|---|---|
| Relative | `"2 weeks ago"`, `"last Monday"`, `"3 days ago"` |
| ISO 8601 | `"2026-05-19"` |
| Descriptive | `"yesterday"`, `"last month"` |

#### Filter commits by configured type
Build filters from the project's `Commit types` section; the examples below use a placeholder rather than assuming a project type:

```bash
# One confirmed type
git log --since="2 weeks ago" --no-merges --format="%s" | grep "^<confirmed-type>"

# Review commit subjects and group them according to every confirmed type
git log --since="2 weeks ago" --no-merges --format="%s"
```

Do not run a type filter that is not supported by the confirmed convention. If there is no project type convention, framework candidates may guide grouping only when identified as defaults.

### Commit types and breaking changes
Parse commit messages using `Commit types` from `.github/ai-qa/project/conventions/git.md`. If that section is not established, use `.github/ai-qa/framework/defaults/git.md` as a candidate only, label it a framework default and do not present it as an observed project convention. Keep the source table's audience guidance as applicable:

| Type | Typical audience |
|---|---|
| Feature/capability | Sprint review, stakeholders |
| Bug fix | Sprint review, QA |
| Refactor | Team notes |
| Test additions or changes | QA, team notes |
| CI/build/infrastructure | Team notes |
| Documentation | Team notes |
| Maintenance | Usually omit from stakeholder summaries |
| Performance improvement | Sprint review |
| Security fix | Always include and flag explicitly |

The following are common Conventional Commit examples only, not a default project restriction: `feat:` (new feature or capability), `fix:` (bug fix), `refactor:` (code restructure without behaviour change), `test:` (test additions or changes), `ci:` (CI/CD pipeline changes), `build:` (build system/infrastructure as code), `docs:` (documentation), `chore:` (maintenance/dependency updates), `perf:` (performance improvement) and `security:` (security fix). Use the project's configured names and meanings instead of this example list whenever they differ.

**Breaking changes** are marked with `!` after the type or with `BREAKING CHANGE:` in the commit body. Always call these out explicitly in every output format. If commit messages are not typed according to the configured convention, group them under “Other changes”, note the inconsistency and label them `[untyped]`; do not fabricate types.

### Output file
Use the configured file naming convention and destination in `conventions/reporting.md`. If absent, mark `TECH_UPDATE_[START-DATE]_to_[END-DATE].txt` in `qa-work/<work-id>/outputs/` as the framework candidate, using the actual calendar dates rather than today's date by default. For example: `TECH_UPDATE_2026-05-12_to_2026-06-02.txt`. Output is plain text: use no Markdown formatting in the report body; use hyphens for bullets and plain dashes or equals signs for section dividers. The standard and detailed formats may have their own plain-text headings.

### Weekly mode — additional step
After the nonempty git log, use configured provider operation `workitem.search` for current in-progress items. Scope it using confirmed project/work-item conventions and a finite page size; follow pagination and report partial/incomplete results honestly. Use item summaries (not IDs) to populate “Next week”. Never hard-code a project key or issue tracker. Prioritise:
1. Items where commits were made in the requested date range (cross-reference the git log output).
2. Build/delivery-focused items over review or discovery tasks.
3. Older in-progress items that are more likely to be near completion.

Keep to 3 bullets maximum. If more items match, select the best 3 and separately tell the user which were omitted and why so they can override the selection. Project channel formatting comes from `conventions/reporting.md` `Channel templates`; do not impose Slack-specific formatting.

### Handling edge cases
**No commits in the date range:** follow the hard stop above; do not scroll past it.

**Commits not following the configured type convention:** group non-conventional commits under “Other changes”; note the inconsistency so the team can improve commit hygiene; do not fabricate types—label them `[untyped]`.

**Merge commits:** always use `--no-merges` to exclude them; merge commits add noise without adding information to summaries.

**Security commits:** explicitly flag evidenced security fixes in every output mode, even if brief.

**Breaking changes:** explicitly call out every evidenced breaking change and any supported migration impact.

**Weekly data unavailable:** keep the requested weekly format, but identify unavailable in-progress work-item data as `not available`; do not invent next-week plans.

**Publication:** never publish the report automatically. Use `qa-publish` after showing the exact payload and receiving independent L4 approval.

## Output
For a requested saved report, write to `qa-work/<work-id>/outputs/<configured-filename>` with the frontmatter required by `.github/ai-qa/framework/method/artefacts.md`: `work-id`, `skill: qa-tech-report`, `framework-version`, `created` (UTC ISO-8601) and `inputs` (git range/ref, timezone and referenced artefact revisions). Preserve the no-commits output template exactly; record its provenance and hard-stop result in the index without adding report commentary. Provide dated period/ref, mode, grouped achievements, verified QA evidence, risks, unknowns and commit/PR links or hashes. Distinguish authored, merged, released and deployed states. A commit alone is not evidence of deployment or passing QA.

Update `qa-work/<work-id>/index.md` with the output link, source commit range/ref, inputs, freshness and report status. Mark superseded reports stale when inputs change. Do not include sensitive content from commits or logs.

## Side effects and safety
| Action | Level | Gate |
|---|---|---|
| Read git history and scoped provider work items | L0 | No gate; live, bounded and authorised reads |
| Write local report and index | L1 | No separate gate for standalone output; workflow-plan approval applies in orchestration; non-default branch only |
| Publish report externally | L4 | Separate `qa-publish` exact-payload/destination gate |

Do not invent releases, delivery dates, metrics, work-item status or “next week” commitments. Recheck git head before output; if commits changed during drafting, regenerate. No merge or external write is implied.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
