/**
 * C-Shop — quick order tests.
 */
import {parsePastedLines, addRow, fillRows} from './quick-order';

const row = (index: number) => `
  <tr data-ps-ref="cs-quick-order-row">
    <td><input name="items[${index}][code]" type="text"></td>
    <td><input name="items[${index}][qty]" type="number" value="1"></td>
  </tr>`;

const markup = `
  <form data-ps-component="cs-quick-order">
    <table><tbody data-ps-target="cs-quick-order-rows">${row(0)}${row(1)}</tbody></table>
    <template data-ps-template="cs-quick-order-row">
      <tr data-ps-ref="cs-quick-order-row">
        <td><input name="items[__INDEX__][code]" type="text" aria-label="row __ROW__"></td>
        <td><input name="items[__INDEX__][qty]" type="number" value="1"></td>
      </tr>
    </template>
  </form>`;

describe('parsePastedLines', () => {
  it('accepts spaces, tabs, semicolons and commas', () => {
    expect(parsePastedLines('ABC123 5\nHP-305XL;2\n\nC13T\t10\nX1,3')).toEqual([
      {code: 'ABC123', qty: 5},
      {code: 'HP-305XL', qty: 2},
      {code: 'C13T', qty: 10},
      {code: 'X1', qty: 3},
    ]);
  });

  it('defaults invalid or missing quantities to 1', () => {
    expect(parsePastedLines('ONLYCODE\nNEG -4\nZERO 0')).toEqual([
      {code: 'ONLYCODE', qty: 1},
      {code: 'NEG', qty: 1},
      {code: 'ZERO', qty: 1},
    ]);
  });
});

describe('quick order rows', () => {
  beforeEach(() => {
    document.body.innerHTML = markup;
  });

  const form = (): HTMLElement => document.querySelector<HTMLElement>('form') as HTMLElement;

  it('adds a row with a unique index', () => {
    const added = addRow(form());

    expect(added?.querySelector('input')?.getAttribute('name')).toBe('items[2][code]');
    expect(added?.querySelector('input')?.getAttribute('aria-label')).toBe('row 3');
  });

  it('fills empty rows first and creates more when needed', () => {
    fillRows(form(), [{code: 'A', qty: 2}, {code: 'B', qty: 3}, {code: 'C', qty: 4}]);
    const codes = Array.from(form().querySelectorAll<HTMLInputElement>('input[name$="[code]"]')).map((input) => input.value);
    const qtys = Array.from(form().querySelectorAll<HTMLInputElement>('input[name$="[qty]"]')).map((input) => input.value);

    expect(codes).toEqual(['A', 'B', 'C']);
    expect(qtys).toEqual(['2', '3', '4']);
  });
});
