# Configure

`qa-configure` is the only writer of the project layer:

- `.github/ai-qa/project/**`
- rendered `.github/instructions/qa-*.instructions.md`
- `.vscode/mcp.json`

Every write is L5: you see the diff first, and nothing is written without an explicit approval. The full procedure is in `.github/agents/qa-configure.agent.md`. The discovery rules are in `.github/ai-qa/framework/method/discovery.md`.

## Procedure

1. **Preflight.** Read the manifest and installed version, then decide whether this is a first run or a refresh.
2. **Local discovery.** Run read-only checks across every domain: repo shape, languages and build, frameworks and data, test stack → pack, test conventions, execution, CI/CD, git, PRs, CODEOWNERS, definition of done, docs, integrations and Project Context. Discovery never runs the suite.
3. **Integrations.**
   - Identify providers.
   - Identify deployments: `*.atlassian.net` → Cloud ◐, a self-hosted URL → Server/DC ◐. Confirm with a read-only `serverInfo` probe or the MCP configuration, otherwise ask once.
   - Order transports from preferred to fallback.
4. **Optional remote-docs pass.** This runs only for a Confluence space or Azure Wiki root that you name. It reads index pages first and keeps reading to a minimum.
5. **Confirm.**
   - One question at a time, only for ⚠, behaviour-relevant ◐, ? and relevant ∅ findings. Each question shows the evidence, Option A (recommended) and the alternatives.
   - "Accept all" is supported, and there is one optional constraints question.
   - It never asks what the repo already answers, and never asks for secrets: only environment-variable names.
   - It decides the manual scenario format: `bdd` (Given / When / Then) or `steps` (numbered steps with expected results). It looks at how acceptance criteria and any existing manual tests are written, recommends that style as Option A, and asks once with `bdd` as Option A if the evidence conflicts or is missing.
6. **Defaults.** Fill ∅/✗ gaps from `framework/defaults/`, marked ★ with the date.
7. **Packs.** Select a pack per test path.
8. **Diff and L5 approval.**
9. **Write** the approved files.
10. **Verify.**
    - Conventions match the cited examples.
    - The test command exists, checked with help/list only and never run.
    - `project.md` cites its sources.
    - A read-only provider probe succeeds.
11. **Summary.** Report what is ready, what is degraded, the first commands to try, and offer `qa-baseline`.

## Statuses

| Mark | Meaning |
|---|---|
| ✓ | Observed |
| ◐ | Inferred (basis and sample stated) |
| ⚠ | Conflict (both sides shown) |
| ∅ | Not found |
| ? | Could not check |
| ✗ | No consistent convention |
| ★ | Default established (Configure only, dated) |

Statuses are never merged, and an inference is never presented as an observation. Sampling is guidance, not a threshold. Configure reports what it sampled, the proportion that matched and 2–3 real examples. For git and PR conventions, recent evidence beats volume.

## Files written

| File | Contents |
|---|---|
| `project.md` | Summary, Components, Technology stack, Environments, Data stores and external dependencies, CI/CD, Test landscape, Constraints, Documentation sources, Unknowns and conflicts, Provenance. Each section has a confidence level and sources |
| `discovery.md` | Discovery report grouped by domain, ending with *Needs your input* |
| `conventions/git.md` | Base branch, branch patterns and examples, commit style and types, ticket syntax, PR title pattern and types, PR templates and exemplar, draft and reviewer policy |
| `conventions/testing.md` | Per test path: pack, locations, naming, fixtures and builders, tags, commands (all/path/tag), reports, environments and base URLs, test-data rules, manual-testing ownership |
| `conventions/qa-process.md` | Readiness, DoD and evidence, plan destination and timing, comment templates, extra regression areas, fix-loop limits, commands safe to run, work-id rule, qa-work policy, scenario format (`bdd` or `steps`), locale (default en-GB), team options |
| `conventions/integrations.md` | Per capability: provider, deployment, base URL, identifiers, transports, auth method, environment-variable names |
| `conventions/reporting.md` | Audiences, formats, channel templates, tech-report defaults, file naming, documentation pages |
| `.github/instructions/qa-project.instructions.md` | `applyTo` = the project's test globs |
| `.github/instructions/qa-<pack>.instructions.md` | One per selected pack, rendered with project paths and a note that project conventions take precedence |
| `.vscode/mcp.json` | Only when MCP is chosen |

## Defaults (★ when applied)

| Area | Default |
|---|---|
| Branches | `feature\|bugfix\|chore/<ticket>-<slug>` |
| Commits | Conventional Commits |
| PR title | `<type>: <summary> (<ticket>)` |
| PR body | Summary + List of Changes |
| Publishing | On request |
| Locale | en-GB |
| Fix loop | Maximum 3 iterations |

Team options carried over from the Generic POC are off by default:

- Keep the Confluence page empty until testing starts.
- Use `.sql` test data.
- Limit branch descriptions to 10–45 characters.

## Packs

If no pack matches, AI-QA uses the existing project tests and warns that confidence is reduced. If there is no test framework at all, it reports ∅, records ★ and offers a gated scaffold (`qa-generate-tests scaffold`; dependency install is L5). `applyTo` globs come only from discovered paths, and only the selected packs are rendered.

## Refresh

`@qa-configure refresh` re-runs discovery and diffs the result against the current files. It asks only about changes. It never rewrites `<!-- ai-qa:user -->` sections. Skills that detect drift record it in their artefacts and suggest a refresh; they never edit project files themselves.
