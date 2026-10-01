# Manual installation

Copy the framework-owned `.github/agents/qa*.agent.md`, `.github/skills/qa-*/` and `.github/ai-qa/framework/` paths to the target repository without modifying their contents. Put a pointer to the two agents between `<!-- ai-qa:start -->` and `<!-- ai-qa:end -->` in `.github/copilot-instructions.md` (create that file if missing). Add the marked `.gitignore` block below at the project root:

```gitignore
# ai-qa:start
qa-work/**
!qa-work/*/
!qa-work/*/index.md
!qa-work/*/outputs/
!qa-work/*/outputs/**
# ai-qa:end
```

The installer additionally records SHA-256 hashes in `.github/ai-qa/manifest.json` so update and uninstall can preserve user modifications; manual installations must maintain that inventory themselves. Never copy `tools/`, `examples/`, `.github/ai-qa/project/` or fixture-specific config into the target. Open the target in VS Code and run `qa-configure` to create the project-owned layer after reviewing its proposed diff (L5). Only render instructions for discovered test paths and selected packs. Do not add `.vscode/mcp.json` unless MCP is chosen and approved.
