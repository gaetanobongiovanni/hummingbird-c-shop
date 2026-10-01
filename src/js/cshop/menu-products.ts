/**
 * C-Shop — mega menu: a category without sub-categories shows a preview of
 * its products in the right panel instead of an empty space.
 *
 * Data: the category page itself, asked as JSON (PrestaShop returns the
 * product search result when the request accepts application/json, the same
 * call the faceted search makes). Loaded once, the first time the tab opens.
 */
import cshopSelectors from './selectors';

export const PREVIEW_COUNT = 8;

export interface MenuProduct {
  name: string;
  url: string;
  price: string;
  image: string;
}

type Json = Record<string, unknown>;

const asRecord = (value: unknown): Json => (value && typeof value === 'object' ? value as Json : {});

export const previewUrl = (url: string, count = PREVIEW_COUNT): string => {
  const target = new URL(url, window.location.origin);
  target.searchParams.set('resultsPerPage', String(count));

  return target.toString();
};

/** Reads products and total from the listing JSON (tolerant to missing keys). */
export const parseListing = (data: unknown): { products: MenuProduct[]; total: number } => {
  const json = asRecord(data);
  const list = Array.isArray(json.products) ? json.products : [];

  const products = list.map((item) => {
    const product = asRecord(item);
    const sizes = asRecord(asRecord(product.cover).bySize);
    const image = asRecord(sizes.home_default).url ?? asRecord(sizes.small_default).url ?? '';

    return {
      name: String(product.name ?? ''),
      url: String(product.url ?? product.canonical_url ?? ''),
      price: String(product.price ?? ''),
      image: String(image),
    };
  }).filter((product) => product.name !== '' && product.url !== '');

  const total = Number(asRecord(json.pagination).total_items ?? products.length) || products.length;

  return {products, total};
};

const buildCard = (product: MenuProduct): HTMLAnchorElement => {
  const card = document.createElement('a');
  card.className = 'cs-menu-products__card';
  card.href = product.url;

  const media = document.createElement('span');
  media.className = 'cs-menu-products__media';

  if (product.image) {
    const img = document.createElement('img');
    img.src = product.image;
    img.alt = '';
    img.loading = 'lazy';
    img.decoding = 'async';
    img.width = 120;
    img.height = 120;
    media.append(img);
  }

  const name = document.createElement('span');
  name.className = 'cs-menu-products__name';
  name.textContent = product.name;

  const price = document.createElement('span');
  price.className = 'cs-menu-products__price';
  price.textContent = product.price;

  card.append(media, name, price);

  return card;
};

const message = (text: string): HTMLParagraphElement => {
  const p = document.createElement('p');
  p.className = 'cs-menu-products__message';
  p.textContent = text;

  return p;
};

export const renderPanel = (panel: HTMLElement, products: MenuProduct[], total: number): void => {
  const {psUrl = '', psTextAll = '', psTextEmpty = ''} = panel.dataset;

  if (!products.length) {
    panel.replaceChildren(message(psTextEmpty));

    return;
  }

  const grid = document.createElement('div');
  grid.className = 'cs-menu-products__grid';
  grid.append(...products.map(buildCard));

  const all = document.createElement('a');
  all.className = 'cs-menu-products__all';
  all.href = psUrl;
  all.textContent = psTextAll.replace('%count%', String(total));

  panel.replaceChildren(grid, all);
};

export const loadPanel = async (panel: HTMLElement, fetcher: typeof fetch = window.fetch.bind(window)): Promise<void> => {
  if (panel.dataset.psLoaded) {
    return;
  }
  panel.dataset.psLoaded = 'loading';
  panel.setAttribute('aria-busy', 'true');

  try {
    const response = await fetcher(previewUrl(panel.dataset.psUrl ?? ''), {
      headers: {Accept: 'application/json'},
      credentials: 'same-origin',
    });

    if (!response.ok) {
      throw new Error(String(response.status));
    }

    const {products, total} = parseListing(await response.json());
    renderPanel(panel, products.slice(0, PREVIEW_COUNT), total);
    panel.dataset.psLoaded = 'done';
  } catch {
    panel.replaceChildren(message(panel.dataset.psTextError ?? ''));
    delete panel.dataset.psLoaded; // try again next time
  } finally {
    panel.setAttribute('aria-busy', 'false');
  }
};

/** The menu script shows a panel by adding the "active" class: load it then. */
const initMenuProducts = (): void => {
  const panels = document.querySelectorAll<HTMLElement>(cshopSelectors.menuProducts.panel);

  if (!panels.length || typeof MutationObserver === 'undefined') {
    return;
  }

  const observer = new MutationObserver((mutations) => {
    mutations.forEach(({target}) => {
      const panel = target as HTMLElement;

      if (panel.classList.contains('active')) {
        loadPanel(panel);
      }
    });
  });

  panels.forEach((panel) => observer.observe(panel, {attributes: true, attributeFilter: ['class']}));
};

export default initMenuProducts;
