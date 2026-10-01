# Commerce workspace

This repository contains two independently tested packages: `packages/api` owns the Orders HTTP API, and `packages/web` owns the customer storefront. The root uses npm workspaces. AI-QA v1 renders a single project test scope at a time, so discovery should report both package scopes and ask which package to configure.

## Workspace commands

Run `npm install` once at the root. Use `npm run test:api` for the API Playwright checks and `npm run test:web` for the web Vitest suite. `npm test` runs both. GitHub Actions runs both package checks on pull requests and pushes to `main`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for shared branch conventions and [ADR 0001](docs/adr/0001-workspace-boundaries.md) for package ownership.