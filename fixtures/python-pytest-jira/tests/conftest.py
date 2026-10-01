import pytest
from fastapi.testclient import TestClient

from stock.api import app


@pytest.fixture
def client():
    app.state.quantities = {"book-1": 12}
    with TestClient(app) as test_client:
        yield test_client