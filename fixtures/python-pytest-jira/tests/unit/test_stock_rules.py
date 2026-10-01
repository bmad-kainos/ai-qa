from stock.rules import is_valid_quantity


def test_positive_stock_quantity_is_valid():
    assert is_valid_quantity(4)


def test_negative_stock_quantity_is_invalid():
    assert not is_valid_quantity(-1)