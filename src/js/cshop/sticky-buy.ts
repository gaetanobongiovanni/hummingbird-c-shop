/**
 * C-Shop — mobile sticky buy bar on the product page.
 * Visible only while the real add-to-cart button is out of view; its button
 * delegates to the real one, so quantity, combination and module logic are
 * unchanged. The price is kept in sync after combination changes.
 */
import EVENTS from '@constants/events-map';

const BAR = '[data-ps-component="cs-sticky-buy"]';
const ACTION = '[data-ps-action="cs-sticky-buy"]';
const PRICE = '[data-ps-ref="cs-sticky-buy-price"]';
const REAL_BUTTON = '.product__actions [data-button-action="add-to-cart"]';
const REAL_PRICE = '.product__actions .product__price, .js-product-prices .product__price';

export const syncPrice = (bar: HTMLElement): void => {
  const target = bar.querySelector<HTMLElement>(PRICE);
  const source = document.querySelector<HTMLElement>(REAL_PRICE);

  if (target && source) {
    // Keep only the visible price text (drop the visually-hidden "Price:" label)
    const clone = source.cloneNode(true) as HTMLElement;
    clone.querySelectorAll('.visually-hidden').forEach((el) => el.remove());
    target.textContent = clone.textContent?.trim() ?? '';
  }
};

const initStickyBuy = (): void => {
  const bar = document.querySelector<HTMLElement>(BAR);

  if (!bar || !('IntersectionObserver' in window)) {
    return;
  }

  let observed: HTMLElement | null = null;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      bar.hidden = entry.isIntersecting;
    });
  });

  const observeRealButton = (): void => {
    const real = document.querySelector<HTMLElement>(REAL_BUTTON);

    if (real && real !== observed) {
      if (observed) {
        observer.unobserve(observed);
      }
      observer.observe(real);
      observed = real;
    }
  };

  observeRealButton();
  syncPrice(bar);
  document.body.classList.add('cs-has-sticky-buy');

  bar.addEventListener('click', (event: Event) => {
    if ((event.target as HTMLElement | null)?.closest(ACTION)) {
      const real = document.querySelector<HTMLButtonElement>(REAL_BUTTON);

      if (real && !real.disabled) {
        real.click();
      } else {
        real?.scrollIntoView({behavior: 'smooth', block: 'center'});
      }
    }
  });

  // The add-to-cart block is re-rendered on combination change
  window.prestashop?.on(EVENTS.updatedProduct, () => {
    observeRealButton();
    syncPrice(bar);
  });
};

export default initStickyBuy;
