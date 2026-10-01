import pytest


@pytest.mark.integration
def test_stock_endpoint_returns_available_quantity(client):
    response = client.get("/stock/book-1")

    assert response.status_code == 200
    assert response.json() == {"sku": "book-1", "quantity": 12}


@pytest.mark.integration
def test_unknown_sku_returns_not_found(client):
    response = client.get("/stock/missing")

    assert response.status_code == 404