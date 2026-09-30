/**
 * C-Shop — quote request tests.
 */
import {copySelectedCombination} from './quote-request';

describe('copySelectedCombination', () => {
  it('copies group[] fields and replaces previous copies', () => {
    document.body.innerHTML = `
      <form id="add-to-cart-or-refresh">
        <input name="token" value="t"><input name="qty" value="3">
        <select name="group[1]"><option value="2" selected>M</option></select>
        <input type="radio" name="group[2]" value="8"><input type="radio" name="group[2]" value="11" checked>
      </form>
      <form data-ps-component="cs-quote"><input name="qty" value="50"></form>`;
    const quote = document.querySelector<HTMLFormElement>('[data-ps-component="cs-quote"]') as HTMLFormElement;
    const product = document.querySelector<HTMLFormElement>('#add-to-cart-or-refresh');

    copySelectedCombination(quote, product);
    copySelectedCombination(quote, product);
    const data = new FormData(quote);

    expect(data.getAll('group[1]')).toEqual(['2']);
    expect(data.getAll('group[2]')).toEqual(['11']);
    expect(data.getAll('qty')).toEqual(['50']);
    expect(data.has('token')).toBe(false);
  });
});
