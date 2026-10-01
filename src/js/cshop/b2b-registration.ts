/**
 * C-Shop — B2B registration form (fields added by the cshopb2b module).
 *
 * Each business field sits in a wrapper with:
 *   data-ps-b2b-show="azienda rivenditore ente"  types that see the field
 *   data-ps-b2b-required="azienda rivenditore"   types that must fill it
 * Hidden fields are disabled, so the browser neither validates nor submits
 * them. The module validates everything again on the server.
 */
import cshopSelectors from './selectors';

const ALWAYS = 'always';

export const matchesType = (list: string | undefined, type: string): boolean => {
  const values = (list ?? '').split(/\s+/).filter(Boolean);

  return values.includes(ALWAYS) || values.includes(type);
};

/** Tax code hint: personal code (16 chars) for sole traders, 11 digits otherwise. */
export const taxCodeHint = (type: string, legalForm: string): { placeholder: string; maxLength: number } => (
  type !== 'ente' && legalForm === 'ditta'
    ? {placeholder: 'RSSMRA85T10A562S', maxLength: 16}
    : {placeholder: '01234567890', maxLength: 11}
);

const checkedValue = (form: HTMLElement, name: string): string => (
  form.querySelector<HTMLInputElement>(`input[name="${name}"]:checked`)?.value ?? ''
);

const applyState = (container: HTMLElement): void => {
  const {b2b} = cshopSelectors;
  const type = checkedValue(container, 'cs_customer_type') || 'privato';
  const legalForm = checkedValue(container, 'cs_legal_form');
  const isBusiness = type !== 'privato';

  const business = container.querySelector<HTMLElement>(b2b.business);

  if (business) {
    business.hidden = !isBusiness;
  }

  container.querySelectorAll<HTMLElement>(b2b.field).forEach((wrapper) => {
    const visible = matchesType(wrapper.dataset.psB2bShow, type);
    const required = visible && matchesType(wrapper.dataset.psB2bRequired, type);

    wrapper.hidden = !visible;
    wrapper.querySelectorAll<HTMLInputElement>('input, select, textarea').forEach((input) => {
      // the type radios stay enabled; everything else follows the visibility
      if (input.name !== 'cs_customer_type') {
        input.disabled = !visible;
      }
      // radio groups: one required radio is enough for the browser
      if (input.name !== 'cs_customer_type') {
        input.required = required;
      }
    });
    wrapper.querySelector('label[id$="-label"]')?.classList.toggle('required', required);
  });

  const taxCode = container.querySelector<HTMLInputElement>(b2b.taxCode);

  if (taxCode) {
    const hint = taxCodeHint(type, legalForm);
    taxCode.placeholder = hint.placeholder;
    taxCode.maxLength = hint.maxLength;
  }
};

const initB2bRegistration = (): void => {
  document.querySelectorAll<HTMLElement>(cshopSelectors.b2b.container).forEach((container) => {
    container.addEventListener('change', (event) => {
      const target = event.target as HTMLInputElement | null;

      if (target?.name === 'cs_customer_type' || target?.name === 'cs_legal_form') {
        applyState(container);
      }
    });

    // codes are written in capitals (VAT number, tax code, SDI, IPA)
    container.addEventListener('input', (event) => {
      const target = event.target as HTMLInputElement | null;

      if (target && ['cs_tax_code', 'cs_sdi', 'cs_ipa', 'cs_vat'].includes(target.name)) {
        const {selectionStart, selectionEnd} = target;
        target.value = target.value.toUpperCase();
        target.setSelectionRange(selectionStart, selectionEnd);
      }
    });

    applyState(container);
  });
};

export default initB2bRegistration;
