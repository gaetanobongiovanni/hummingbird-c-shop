/**
 * C-Shop — quantity rules tests.
 */
import {snapQuantity, normaliseInput, normaliseAll} from './qty-rules';

describe('snapQuantity', () => {
  it.each([
    [1, 1, 1, 1],
    [7, 1, 1, 7],
    [0, 3, 1, 3],
    [1, 1, 10, 10],
    [11, 1, 10, 20],
    [20, 1, 10, 20],
    [12, 5, 6, 12],
    [5, 5, 6, 6],
    [Number.NaN, 2, 1, 2],
    [3, 0, 0, 3],
  ])('snaps %p (min %p, step %p) to %p', (value, min, step, expected) => {
    expect(snapQuantity(value, min, step)).toBe(expected);
  });
});

describe('normaliseInput', () => {
  const createInput = (value: string, min: string, step: string, updateUrl?: string): HTMLInputElement => {
    const input = document.createElement('input');
    input.setAttribute('data-ps-component', 'cs-qty');
    input.setAttribute('min', min);
    input.setAttribute('step', step);
    input.value = value;

    if (updateUrl) {
      input.dataset.updateUrl = updateUrl;
    }
    document.body.append(input);

    return input;
  };

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('rounds up to the next multiple and reports the change', () => {
    const input = createInput('3', '1', '5');

    expect(normaliseInput(input)).toBe(true);
    expect(input.value).toBe('5');
  });

  it('keeps a valid quantity untouched', () => {
    const input = createInput('10', '5', '5');

    expect(normaliseInput(input)).toBe(false);
    expect(input.value).toBe('10');
  });

  it('never snaps cart inputs (0 removes the line)', () => {
    const listing = createInput('1', '1', '12');
    const cart = createInput('0', '1', '12', '/cart?update=1');

    normaliseAll();

    expect(listing.value).toBe('12');
    expect(cart.value).toBe('0');
  });
});
