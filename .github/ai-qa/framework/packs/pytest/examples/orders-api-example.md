# pytest Python — Orders API example (illustrative, unrun)

This **hypothetical** contract matches the Playwright example: `POST /orders`, valid `quantity` 1–9 yields **201** and a string `id`; invalid quantity or missing `customerId` yields **400** and `error.code`. Adapt to the real contract, installed HTTP client and project fixtures. An isolated approved environment supplies `API_BASE_URL`; do not add `httpx` merely to run this example.

```python
# Example conftest.py fragment, only when httpx is already used by the project.
import os

import httpx
import pytest


@pytest.fixture(scope="session")
def api_client():
    base_url = os.environ["API_BASE_URL"]
    with httpx.Client(base_url=base_url, timeout=10) as client:
        yield client


@pytest.fixture
def valid_order():
    return {"customerId": "isolated-example", "quantity": 5}
```

```python
# Example test_orders_contract.py fragment.
import pytest


class TestOrdersContract:
    def test_valid_order_returns_201(self, api_client, valid_order):
        response = api_client.post("/orders", json=valid_order)
        assert response.status_code == 201, response.text
        assert isinstance(response.json()["id"], str), response.text

    @pytest.mark.parametrize(
        ("quantity", "expected_status"),
        [(0, 400), (1, 201), (9, 201), (10, 400)],
        ids=["below-minimum", "at-minimum", "at-maximum", "above-maximum"],
    )
    def test_quantity_boundary(self, api_client, valid_order, quantity, expected_status):
        payload = {**valid_order, "quantity": quantity}
        response = api_client.post("/orders", json=payload)
        assert response.status_code == expected_status, (
            f"quantity={quantity}: expected {expected_status}, got {response.status_code}: {response.text}"
        )
        body = response.json()
        if expected_status == 400:
            assert body["error"]["code"], body
        else:
            assert isinstance(body["id"], str), body

    def test_missing_customer_id_returns_400(self, api_client, valid_order):
        payload = {key: value for key, value in valid_order.items() if key != "customerId"}
        response = api_client.post("/orders", json=payload)
        assert response.status_code == 400, response.text
        assert response.json()["error"]["code"], response.text
```

No scenario has been executed. Fresh mutable fixtures avoid test-order dependence; use established auth, seeding, cleanup and contract schemas before adaptation.
