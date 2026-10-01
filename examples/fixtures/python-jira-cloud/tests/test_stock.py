def test_sku_is_required():
    payload = {"quantity": 2}
    assert "sku" not in payload
