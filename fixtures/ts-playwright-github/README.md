# Catalogue Web

Catalogue Web is a small TypeScript storefront backed by a catalogue HTTP API. The browser client is in `src/`; the API contract is [docs/openapi.yaml](docs/openapi.yaml). The GitHub project uses issue numbers such as `#123` in pull requests.

## Local development

Use Node.js 22. Run `npm install`, then `npm run dev` to start the Vite app at `http://localhost:3000`. Run `npm test` for the full Playwright suite, `npm run test:api` for API-boundary checks, or `npm run test:e2e` for browser flows. Playwright writes JUnit XML to `test-results/junit.xml`.

Start the local PostgreSQL dependency with `docker compose up -d`. Tests stub the HTTP boundary and do not require database credentials or shared services.

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch, commit, and pull request conventions. The current deployment and data boundary is recorded in [ADR 0001](docs/adr/0001-catalogue-api.md).
