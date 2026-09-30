/**
 * C-Shop — listing view switch tests.
 */
import {applyView, readStoredView, STORAGE_KEY} from './listing-view';

const markup = `
  <section id="products" data-ps-component="cs-listing" data-ps-state="grid">
    <div data-ps-ref="cs-view-switch" hidden>
      <button type="button" data-ps-action="cs-listing-view" data-ps-view="grid" aria-pressed="true"></button>
      <button type="button" data-ps-action="cs-listing-view" data-ps-view="list" aria-pressed="false"></button>
    </div>
  </section>`;

describe('listing view', () => {
  beforeEach(() => {
    document.body.innerHTML = markup;
  });

  it('applies the list view to the container and buttons', () => {
    const container = document.querySelector<HTMLElement>('[data-ps-component="cs-listing"]') as HTMLElement;
    applyView(container, 'list');

    const [grid, list] = Array.from(container.querySelectorAll<HTMLButtonElement>('button'));

    expect(container.getAttribute('data-ps-state')).toBe('list');
    expect(grid.getAttribute('aria-pressed')).toBe('false');
    expect(list.getAttribute('aria-pressed')).toBe('true');
    expect(container.querySelector<HTMLElement>('[data-ps-ref="cs-view-switch"]')?.hidden).toBe(false);
  });

  it('reads a stored view and falls back to grid', () => {
    expect(readStoredView({getItem: (key: string) => (key === STORAGE_KEY ? 'list' : null)})).toBe('list');
    expect(readStoredView({getItem: () => 'tiles'})).toBe('grid');
    expect(readStoredView(null)).toBe('grid');
    expect(readStoredView({
      getItem: () => {
        throw new Error('denied');
      },
    })).toBe('grid');
  });
});
