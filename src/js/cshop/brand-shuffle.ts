/**
 * C-Shop — homepage brands: show a random selection on every visit.
 * The server renders the first brands as a no-JS fallback and the full list
 * as JSON; here we pick `data-ps-count` random brands and rebuild the tiles.
 * Brands whose logo fails to load keep the initial badge (img removes itself).
 */
import cshopSelectors from './selectors';

export interface BrandItem {
  n: string; // name
  u: string; // link
  i: string; // logo URL
}

export const pickRandom = <T>(items: readonly T[], count: number, random: () => number = Math.random): T[] => {
  const pool = [...items];

  // partial Fisher-Yates: only the first `count` positions are shuffled
  for (let i = 0; i < Math.min(count, pool.length); i += 1) {
    const j = i + Math.floor(random() * (pool.length - i));
    [pool[i], pool[j]] = [pool[j], pool[i]];
  }

  return pool.slice(0, count);
};

export const parseBrands = (json: string | null | undefined): BrandItem[] => {
  try {
    const data: unknown = JSON.parse(json ?? '[]');

    return Array.isArray(data)
      ? data.filter((b): b is BrandItem => typeof b?.n === 'string' && typeof b?.u === 'string' && typeof b?.i === 'string')
      : [];
  } catch {
    return [];
  }
};

const buildTile = (brand: BrandItem): HTMLLIElement => {
  const li = document.createElement('li');
  li.className = 'cs-brand-grid__item';

  const link = document.createElement('a');
  link.className = 'cs-brand-grid__link';
  link.href = brand.u;

  const logo = document.createElement('span');
  logo.className = 'cs-brand-grid__logo';
  logo.dataset.initial = brand.n.charAt(0).toUpperCase();

  const img = document.createElement('img');
  img.src = brand.i;
  img.alt = '';
  img.width = 98;
  img.height = 98;
  img.loading = 'lazy';
  img.addEventListener('error', () => img.remove(), {once: true});
  logo.append(img);

  const name = document.createElement('span');
  name.className = 'cs-brand-grid__name';
  name.textContent = brand.n;

  link.append(logo, name);
  li.append(link);

  return li;
};

const initBrandShuffle = (): void => {
  document.querySelectorAll<HTMLElement>(cshopSelectors.brandShuffle.container).forEach((container) => {
    const grid = container.querySelector<HTMLElement>(cshopSelectors.brandShuffle.grid);
    const brands = parseBrands(container.querySelector(cshopSelectors.brandShuffle.data)?.textContent);
    const count = Number(container.dataset.psCount) || 12;

    if (!grid || brands.length <= count) {
      return;
    }

    grid.replaceChildren(...pickRandom(brands, count).map(buildTile));
  });
};

export default initBrandShuffle;
