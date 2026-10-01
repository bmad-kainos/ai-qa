from fastapi import FastAPI, HTTPException

from stock.rules import is_valid_quantity

app = FastAPI(title="Stock API")
app.state.quantities = {"book-1": 12}


@app.get("/stock/{sku}")
def get_stock(sku: str) -> dict[str, int | str]:
    quantity = app.state.quantities.get(sku)
    if quantity is None:
        raise HTTPException(status_code=404, detail="SKU not found")
    if not is_valid_quantity(quantity):
        raise HTTPException(status_code=500, detail="Invalid stock state")
    return {"sku": sku, "quantity": quantity}