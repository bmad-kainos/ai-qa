# Playwright + TypeScript Orders API example

A worked Orders API test suite following the Playwright API conventions in [generation.md](../generation.md).

```text
playwright-ts-api/
├── playwright.config.ts
└── tests/
    ├── fixtures/payloads.ts
    ├── api/
    │   ├── orders.contract.spec.ts
    │   └── orders.boundaries.spec.ts
    └── e2e/
        └── checkout.journey.spec.ts
```

Run with the project's installed Playwright runner and set `API_BASE_URL` for the target API. These illustrative tests have not been run and expect an isolated, available Orders API.
