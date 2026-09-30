/**
 * C-Shop — quick order by code (UI only).
 * Adds / removes rows and fills them from a pasted list. The form is submitted
 * to the URL provided by the quick-order module, which owns all the logic.
 */
import cshopSelectors from './selectors';

export interface QuickOrderLine {
  code: string;
  qty: number;
}

const sel = cshopSelectors.quickOrder;

/**
 * Parses "CODE QTY", "CODE;QTY", "CODE,QTY" or "CODE<TAB>QTY" lines.
 * Missing / invalid quantities default to 1. Empty lines are ignored.
 */
export const parsePastedLines = (text: string): QuickOrderLine[] => text
  .split(/\r?\n/)
  .map((line) => line.trim())
  .filter((line) => line.length > 0)
  .map((line) => {
    const [code = '', rawQty = ''] = line.split(/[;\t,]|\s+/).filter((part) => part.length > 0);
    const qty = Number.parseInt(rawQty, 10);

    return {code, qty: Number.isFinite(qty) && qty > 0 ? qty : 1};
  })
  .filter((line) => line.code.length > 0);

const getRows = (form: HTMLElement): HTMLTableRowElement[] => Array.from(
  form.querySelectorAll<HTMLTableRowElement>(sel.row),
);

export const addRow = (form: HTMLElement): HTMLTableRowElement | null => {
  const body = form.querySelector<HTMLElement>(sel.rows);
  const template = form.querySelector<HTMLTemplateElement>(sel.template);

  if (!body || !template) {
    return null;
  }

  // Index must be unique: use the highest existing index + 1.
  const indexes = getRows(form).map((row) => {
    const name = row.querySelector<HTMLInputElement>('input')?.name ?? '';
    const match = /items\[(\d+)\]/.exec(name);

    return match ? Number(match[1]) : -1;
  });
  const index = Math.max(-1, ...indexes) + 1;
  const html = template.innerHTML
    .replace(/__INDEX__/g, String(index))
    .replace(/__ROW__/g, String(getRows(form).length + 1));

  body.insertAdjacentHTML('beforeend', html);
  const rows = getRows(form);

  return rows[rows.length - 1] ?? null;
};

const clearRow = (row: HTMLTableRowElement): void => {
  const [code, qty] = Array.from(row.querySelectorAll<HTMLInputElement>('input'));

  if (code) {
    code.value = '';
  }
  if (qty) {
    qty.value = '1';
  }
};

export const fillRows = (form: HTMLElement, lines: QuickOrderLine[]): void => {
  const rows = getRows(form).filter((row) => row.querySelector<HTMLInputElement>('input')?.value.trim() === '');

  lines.forEach((line) => {
    let row = rows.shift();

    if (!row) {
      row = addRow(form) ?? undefined;
    }
    if (!row) {
      return;
    }

    const [code, qty] = Array.from(row.querySelectorAll<HTMLInputElement>('input'));

    if (code) {
      code.value = line.code;
    }
    if (qty) {
      qty.value = String(line.qty);
    }
  });
};

const initQuickOrder = (): void => {
  document.querySelectorAll<HTMLFormElement>(sel.form).forEach((form) => {
    form.addEventListener('click', (event: Event) => {
      const target = (event.target as HTMLElement | null)?.closest<HTMLElement>('[data-ps-action]');

      if (!target) {
        return;
      }

      if (target.matches(sel.addRow)) {
        addRow(form)?.querySelector<HTMLInputElement>('input')?.focus();
      } else if (target.matches(sel.removeRow)) {
        const row = target.closest<HTMLTableRowElement>(sel.row);

        if (row && getRows(form).length > 1) {
          row.remove();
        } else if (row) {
          clearRow(row);
        }
        form.querySelector<HTMLInputElement>(`${sel.row} input`)?.focus();
      } else if (target.matches(sel.applyPaste)) {
        const paste = form.querySelector<HTMLTextAreaElement>(sel.paste);

        if (paste) {
          fillRows(form, parsePastedLines(paste.value));
          paste.value = '';
        }
      }
    });
  });
};

export default initQuickOrder;
