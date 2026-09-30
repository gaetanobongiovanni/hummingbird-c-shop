/**
 * C-Shop — sticky buy bar tests.
 */
import {syncPrice} from './sticky-buy';

describe('syncPrice', () => {
  it('copies the visible price without the hidden label', () => {
    document.body.innerHTML = `
      <div class="product__actions"><div class="product__price"><span class="visually-hidden">Prezzo:</span> 3,53 €</div></div>
      <div data-ps-component="cs-sticky-buy"><span data-ps-ref="cs-sticky-buy-price"></span></div>`;
    const bar = document.querySelector<HTMLElement>('[data-ps-component="cs-sticky-buy"]') as HTMLElement;
    syncPrice(bar);

    expect(bar.querySelector('[data-ps-ref="cs-sticky-buy-price"]')?.textContent).toBe('3,53 €');
  });
});
