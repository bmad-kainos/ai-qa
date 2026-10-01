# pytest + Python Orders API example

A small worked test suite for an Orders API, following the conventions in [generation.md](../generation.md).

```text
pytest-api/
├── conftest.py                 # shared fixtures (api_client, valid_order)
├── orders/
│   └── pricing.py              # tiny pure helper under test (unit example)
└── tests/
    ├── unit/test_order_helpers.py
    ├── integration/test_orders_contract.py
    ├── integration/test_orders_boundaries.py
    └── e2e/test_checkout_journey.py
```

Run with the project's installed pytest command. Set `API_BASE_URL` for integration/E2E tests; unit tests need no network. These illustrative tests have not been run and expect an isolated, available Orders API.
