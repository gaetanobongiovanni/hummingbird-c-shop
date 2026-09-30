/**
 * C-Shop — quantity rules (minimum order quantity and order multiples).
 *
 * Inputs rendered with `data-ps-component="cs-qty"`, `min` and `step`
 * attributes are snapped to a valid quantity when the user leaves the field.
 * This is UI guidance only: server-side enforcement of multiples belongs to
 * the module that provides `order_multiple` (see product-data.tpl).
 */
import EVENTS from '@constants/events-map';
import cshopSelectors from './selectors';

/**
 * Returns the closest valid quantity >= value that respects min and step.
 * Examples: (1, 1, 10) -> 10, (12, 5, 6) -> 12, (7, 1, 1) -> 7, (0, 3, 1) -> 3
 */
export const snapQuantity = (value: number, min: number, step: number): number => {
  const safeMin = Number.isFinite(min) && min > 0 ? Math.floor(min) : 1;
  const safeStep = Number.isFinite(step) && step > 1 ? Math.floor(step) : 1;
  const base = Number.isFinite(value) ? Math.max(Math.floor(value), safeMin) : safeMin;

  return Math.ceil(base / safeStep) * safeStep;
};

const readNumberAttribute = (input: HTMLInputElement, name: string, fallback: number): number => {
  const value = Number(input.getAttribute(name));

  return Number.isFinite(value) && value > 0 ? value : fallback;
};

export const normaliseInput = (input: HTMLInputElement): boolean => {
  const min = readNumberAttribute(input, 'min', 1);
  const step = readNumberAttribute(input, 'step', 1);
  const current = Number(input.value);
  const snapped = snapQuantity(current, min, step);

  if (current !== snapped) {
    input.value = String(snapped);

    return true;
  }

  return false;
};

const isCsQtyInput = (target: EventTarget | null): target is HTMLInputElement => target instanceof HTMLInputElement
  && target.matches(cshopSelectors.qtyRules.input);

export const normaliseAll = (root: ParentNode = document): void => {
  root.querySelectorAll<HTMLInputElement>(cshopSelectors.qtyRules.input).forEach((input) => {
    // Cart inputs use 0 to remove a line: never snap those.
    if (input.dataset.updateUrl === undefined) {
      normaliseInput(input);
    }
  });
};

const initQtyRules = (): void => {
  normaliseAll();

  // Delegated so that Ajax-refreshed listings / product blocks are covered.
  document.addEventListener('focusout', (event: FocusEvent) => {
    if (isCsQtyInput(event.target) && event.target.dataset.updateUrl === undefined) {
      normaliseInput(event.target);
    }
  });

  const {prestashop} = window;

  [EVENTS.updateProductList, EVENTS.updatedProduct].forEach((eventName: string) => {
    prestashop?.on(eventName, () => normaliseAll());
  });
};

export default initQtyRules;
