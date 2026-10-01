import {loadPanel, parseListing, previewUrl} from './menu-products';

const listing = {
  products: [
    {
      name: 'Penna blu', url: 'https://shop.test/p/1', price: '1,20 €', cover: {bySize: {home_default: {url: 'https://shop.test/1.jpg'}}},
    },
    {
      name: 'Penna rossa', url: 'https://shop.test/p/2', price: '1,30 €', cover: null,
    },
    {name: '', url: 'https://shop.test/p/3'},
  ],
  pagination: {total_items: 42},
};

const panel = (): HTMLElement => {
  document.body.innerHTML = `<div data-ps-component="cs-menu-products" data-ps-url="https://shop.test/12-penne"
    data-ps-text-all="Vedi tutti i %count% prodotti" data-ps-text-empty="Nessun prodotto" data-ps-text-error="Errore"></div>`;

  return document.querySelector('[data-ps-component]') as HTMLElement;
};

describe('menu products', () => {
  it('asks the category for a few products', () => {
    expect(previewUrl('https://shop.test/12-penne?q=x', 8)).toBe('https://shop.test/12-penne?q=x&resultsPerPage=8');
  });

  it('reads products and total, skipping incomplete ones', () => {
    const {products, total} = parseListing(listing);
    expect(products).toHaveLength(2);
    expect(products[0].image).toBe('https://shop.test/1.jpg');
    expect(products[1].image).toBe('');
    expect(total).toBe(42);
  });

  it('renders cards and the "see all" link once', async () => {
    const el = panel();
    const fetcher = jest.fn().mockResolvedValue({ok: true, json: async () => listing});
    await loadPanel(el, fetcher as unknown as typeof fetch);
    await loadPanel(el, fetcher as unknown as typeof fetch);

    expect(fetcher).toHaveBeenCalledTimes(1);
    expect(fetcher.mock.calls[0][1].headers.Accept).toBe('application/json');
    expect(el.querySelectorAll('a[href="https://shop.test/p/1"]')).toHaveLength(1);
    expect(el.textContent).toContain('Vedi tutti i 42 prodotti');
  });

  it('shows the empty and error messages', async () => {
    const empty = panel();
    await loadPanel(empty, jest.fn().mockResolvedValue({ok: true, json: async () => ({products: []})}) as unknown as typeof fetch);
    expect(empty.textContent).toBe('Nessun prodotto');

    const failing = panel();
    await loadPanel(failing, jest.fn().mockResolvedValue({ok: false, status: 500}) as unknown as typeof fetch);
    expect(failing.textContent).toBe('Errore');
    expect(failing.dataset.psLoaded).toBeUndefined();
  });
});
