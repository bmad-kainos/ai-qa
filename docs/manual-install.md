# Manual installation

Use these steps when the installer scripts cannot be run. The repository root is the target.

1. From an AI-QA checkout, copy only `.github/agents/qa*.agent.md`, `.github/skills/qa-*/` (including all nested references and assets), and `.github/ai-qa/framework/` to the same paths in your project. Do not copy rendered instructions or anything under `.github/ai-qa/project/` or `baselines/`.
2. Create `.github/copilot-instructions.md` if it does not exist. Preserve all existing content and add or replace only this marked pointer block:

	```markdown
	<!-- ai-qa:start -->
	AI-QA agents: @qa and @qa-configure.
	Framework: `.github/ai-qa/framework/`.
	Project layer: `.github/ai-qa/project/` (written only by qa-configure).
	Safety: `.github/ai-qa/framework/method/safety.md`.
	<!-- ai-qa:end -->
	```

3. Add or replace only the marked block below in the repository `.gitignore`:

```gitignore
# ai-qa:start
qa-work/**
!qa-work/*/
!qa-work/*/index.md
!qa-work/*/outputs/
!qa-work/*/outputs/**
# ai-qa:end
```

4. Optionally create `.github/ai-qa/manifest.json` with `schema`, `framework_version`, `prefix`, `created_files`, and a `files` object containing one path-to-SHA-256 entry per installed agent, skill, and framework file. This allows the scripts to verify, update, and uninstall the manual installation safely. If you omit it, manage those assets manually.

To uninstall manually, remove only the copied agent files, skill directories, and `.github/ai-qa/framework/` files. Remove the two marked blocks, preserving all surrounding content. Remove `.github/copilot-instructions.md` or `.gitignore` only if you created the file and it is otherwise empty. Keep `.github/ai-qa/project/`, baselines, and `qa-work/`.

Never copy `tools/` or `.github/ai-qa/project/` into the target. Open the target in VS Code and run `qa-configure` to create the project-owned layer after reviewing its proposed diff (L5). Do not add `.vscode/mcp.json` unless MCP is chosen and approved.
