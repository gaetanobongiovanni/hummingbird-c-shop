import initBrandShuffle, {parseBrands, pickRandom} from './brand-shuffle';

describe('pickRandom', () => {
  it('returns the requested number of distinct items', () => {
    const items = Array.from({length: 50}, (_, i) => i);
    const picked = pickRandom(items, 12);

    expect(picked).toHaveLength(12);
    expect(new Set(picked).size).toBe(12);
  });

  it('returns every item when asking for more than available', () => {
    expect(pickRandom([1, 2, 3], 12).sort()).toEqual([1, 2, 3]);
  });
});

describe('parseBrands', () => {
  it('keeps only well-formed entries and survives bad JSON', () => {
    expect(parseBrands('[{"n":"3M","u":"/b/3m","i":"/img/m/1.jpg"},{"n":1}]')).toHaveLength(1);
    expect(parseBrands('nope')).toEqual([]);
  });
});

describe('initBrandShuffle', () => {
  it('rebuilds the grid with the requested count from the JSON list', () => {
    const list = Array.from({length: 30}, (_, i) => ({n: `Brand ${i}`, u: `/b/${i}`, i: `/img/m/${i}.jpg`}));
    document.body.innerHTML = `
      <div data-ps-component="cs-brand-shuffle" data-ps-count="12">
        <ul data-ps-ref="cs-brand-grid"><li>fallback</li></ul>
        <script type="application/json" data-ps-ref="cs-brand-data">${JSON.stringify(list)}</script>
      </div>`;

    initBrandShuffle();

    const tiles = document.querySelectorAll('[data-ps-ref="cs-brand-grid"] > li');
    expect(tiles).toHaveLength(12);
    expect(tiles[0].querySelector('img')?.getAttribute('src')).toMatch(/^\/img\/m\/\d+\.jpg$/);
  });
});
