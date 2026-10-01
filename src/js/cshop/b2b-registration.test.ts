import initB2bRegistration, {matchesType, taxCodeHint} from './b2b-registration';

const field = (name: string, show: string, required: string, type = 'text') => `
  <div data-ps-ref="cs-b2b-field" data-ps-b2b-show="${show}" data-ps-b2b-required="${required}">
    <label class="form-label" id="field-${name}-label">${name}</label>
    <input name="${name}" type="${type}">
  </div>`;

const radio = (name: string, value: string, checked = false) => `<input type="radio" name="${name}" value="${value}"${checked ? ' checked' : ''}>`;

const render = (): HTMLElement => {
  document.body.innerHTML = `
    <section data-ps-component="cs-b2b-registration">
      <div data-ps-ref="cs-b2b-field" data-ps-b2b-show="always" data-ps-b2b-required="always">
        ${radio('cs_customer_type', 'privato', true)}${radio('cs_customer_type', 'azienda')}
        ${radio('cs_customer_type', 'rivenditore')}${radio('cs_customer_type', 'ente')}
      </div>
      <fieldset data-ps-ref="cs-b2b-business">
        <div data-ps-ref="cs-b2b-field" data-ps-b2b-show="azienda rivenditore" data-ps-b2b-required="azienda rivenditore">
          ${radio('cs_legal_form', 'ditta')}${radio('cs_legal_form', 'societa')}
        </div>
        ${field('cs_company', 'azienda rivenditore ente', 'azienda rivenditore ente')}
        ${field('cs_vat', 'azienda rivenditore ente', 'azienda rivenditore')}
        ${field('cs_tax_code', 'azienda rivenditore ente', 'azienda rivenditore ente')}
        ${field('cs_ipa', 'ente', 'ente')}
        ${field('cs_visura', 'rivenditore', 'rivenditore', 'file')}
      </fieldset>
    </section>`;
  initB2bRegistration();

  return document.querySelector('[data-ps-component="cs-b2b-registration"]') as HTMLElement;
};

const choose = (name: string, value: string): void => {
  const input = document.querySelector<HTMLInputElement>(`input[name="${name}"][value="${value}"]`) as HTMLInputElement;
  input.checked = true;
  input.dispatchEvent(new Event('change', {bubbles: true}));
};

const input = (name: string) => document.querySelector<HTMLInputElement>(`input[name="${name}"]`) as HTMLInputElement;

describe('b2b registration', () => {
  it('matches type lists', () => {
    expect(matchesType('azienda rivenditore', 'azienda')).toBe(true);
    expect(matchesType('azienda rivenditore', 'ente')).toBe(false);
    expect(matchesType('always', 'privato')).toBe(true);
    expect(matchesType('', 'ente')).toBe(false);
  });

  it('hints a personal tax code only for sole traders', () => {
    expect(taxCodeHint('azienda', 'ditta').maxLength).toBe(16);
    expect(taxCodeHint('azienda', 'societa').maxLength).toBe(11);
    expect(taxCodeHint('ente', 'ditta').maxLength).toBe(11);
  });

  it('private customers see no business fields', () => {
    render();
    expect((document.querySelector('[data-ps-ref="cs-b2b-business"]') as HTMLElement).hidden).toBe(true);
    expect(input('cs_company').disabled).toBe(true);
  });

  it('resellers must upload the visura, companies do not see it', () => {
    render();
    choose('cs_customer_type', 'rivenditore');
    expect(input('cs_visura').disabled).toBe(false);
    expect(input('cs_visura').required).toBe(true);

    choose('cs_customer_type', 'azienda');
    expect(input('cs_visura').disabled).toBe(true);
    expect(input('cs_vat').required).toBe(true);
  });

  it('public bodies get the IPA code and an optional VAT number', () => {
    render();
    choose('cs_customer_type', 'ente');
    expect(input('cs_ipa').required).toBe(true);
    expect(input('cs_vat').required).toBe(false);
    expect(input('cs_legal_form').disabled).toBe(true);
  });

  it('switches the tax code hint with the legal form', () => {
    render();
    choose('cs_customer_type', 'azienda');
    choose('cs_legal_form', 'ditta');
    expect(input('cs_tax_code').maxLength).toBe(16);
    choose('cs_legal_form', 'societa');
    expect(input('cs_tax_code').maxLength).toBe(11);
  });
});

describe('b2b registration labels', () => {
  it('marks the label of required fields', () => {
    render();
    choose('cs_customer_type', 'azienda');
    expect(document.querySelector('#field-cs_vat-label')?.classList.contains('required')).toBe(true);
    expect(document.querySelector('#field-cs_ipa-label')?.classList.contains('required')).toBe(false);
  });
});
