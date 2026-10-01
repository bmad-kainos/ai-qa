type Product = { id: string; name: string; price: number };

async function renderCatalogue(): Promise<void> {
  const response = await fetch('/api/catalogue');
  if (!response.ok) {
    throw new Error(`Catalogue request failed: ${response.status}`);
  }

  const products = (await response.json()) as Product[];
  const list = document.querySelector<HTMLUListElement>('#products');
  if (!list) {
    throw new Error('Product list element is missing');
  }

  list.replaceChildren(...products.map((product) => {
    const item = document.createElement('li');
    item.dataset.productId = product.id;
    item.textContent = `${product.name} - £${product.price.toFixed(2)}`;
    return item;
  }));
}

void renderCatalogue();