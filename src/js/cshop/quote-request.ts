/**
 * C-Shop — quote request (UI only): copies the currently selected product
 * combination (`group[...]` fields of the add-to-cart form) into the quote form
 * before it is submitted to the quote module.
 */
const QUOTE_FORM = 'form[data-ps-component="cs-quote"]';
const PRODUCT_FORM = '#add-to-cart-or-refresh';
const COPIED = 'data-ps-ref';
const COPIED_VALUE = 'cs-quote-copied';

export const copySelectedCombination = (quoteForm: HTMLFormElement, productForm: HTMLFormElement | null): void => {
  quoteForm.querySelectorAll(`[${COPIED}="${COPIED_VALUE}"]`).forEach((input) => input.remove());

  if (!productForm) {
    return;
  }

  new FormData(productForm).forEach((value, name) => {
    if (name.startsWith('group[') && typeof value === 'string') {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = name;
      input.value = value;
      input.setAttribute(COPIED, COPIED_VALUE);
      quoteForm.append(input);
    }
  });
};

const initQuoteRequest = (): void => {
  document.addEventListener('submit', (event: SubmitEvent) => {
    const form = event.target;

    if (form instanceof HTMLFormElement && form.matches(QUOTE_FORM)) {
      copySelectedCombination(form, document.querySelector<HTMLFormElement>(PRODUCT_FORM));
    }
  });
};

export default initQuoteRequest;
