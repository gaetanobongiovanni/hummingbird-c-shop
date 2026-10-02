/**
 * Run: npx jest extras/cshopcookie
 */
const fs = require('fs');
const path = require('path');

const SCRIPT = fs.readFileSync(path.join(__dirname, '../views/js/cookie.js'), 'utf8');

const MARKUP = `
  <div data-cs-cookie data-cs-version="2">
    <section data-cs-cookie-banner hidden>
      <button data-cs-action="reject" class="x">x</button>
      <button data-cs-action="customise">c</button>
      <button data-cs-action="reject" class="r">r</button>
      <button data-cs-action="accept">a</button>
    </section>
    <section data-cs-cookie-dialog hidden>
      <input type="checkbox" data-cs-category="analytics">
      <input type="checkbox" data-cs-category="marketing">
      <button data-cs-action="back">b</button>
      <button data-cs-action="save">s</button>
    </section>
  </div>
  <a href="#cookie-settings" id="footer">prefs</a>
  <script type="text/plain" data-cs-consent="analytics">window.__analytics = true;</script>
  <script type="text/plain" data-cs-consent="marketing">window.__marketing = true;</script>
`;

function clearCookie() {
  document.cookie = 'cshop_consent=; Max-Age=0; Path=/';
}

function boot(cookie) {
  clearCookie();
  if (cookie) {
    document.cookie = `cshop_consent=${cookie}; Path=/`;
  }
  document.body.innerHTML = MARKUP;
  delete window.__analytics;
  delete window.__marketing;
  window.dataLayer = [];
  delete window.gtag;
  // eslint-disable-next-line no-eval
  window.eval(SCRIPT);
}

const $ = (s) => document.querySelector(s);
const consentCalls = () => window.dataLayer.filter((e) => e[0] === 'consent');

describe('cshopcookie banner', () => {
  test('parse accepts only the current version and the exact format', () => {
    boot();
    const { parse } = window.CshopConsentInternals;
    expect(parse('2.1.0.1700000000', '2')).toEqual({ analytics: true, marketing: false, time: 1700000000 });
    expect(parse('1.1.1.1700000000', '2')).toBeNull();
    expect(parse('2.2.0.1', '2')).toBeNull();
    expect(parse('', '2')).toBeNull();
  });

  test('first visit shows the banner and runs no optional script', () => {
    boot();
    expect($('[data-cs-cookie-banner]').hidden).toBe(false);
    expect(window.__analytics).toBeUndefined();
    expect(window.CshopConsent.get()).toBeNull();
  });

  test('the X refuses everything and saves the choice', () => {
    boot();
    $('.x').click();
    expect(document.cookie).toMatch(/cshop_consent=2\.0\.0\.\d+/);
    expect($('[data-cs-cookie-banner]').hidden).toBe(true);
    expect(window.CshopConsent.has('analytics')).toBe(false);
    expect(window.__analytics).toBeUndefined();
    expect(consentCalls().pop()[2].analytics_storage).toBe('denied');
  });

  test('accept all releases blocked scripts and grants consent mode', () => {
    boot();
    $('[data-cs-action="accept"]').click();
    expect(window.__analytics).toBe(true);
    expect(window.__marketing).toBe(true);
    const update = consentCalls().pop()[2];
    expect(update.analytics_storage).toBe('granted');
    expect(update.ad_user_data).toBe('granted');
  });

  test('customise saves only the chosen categories', () => {
    boot();
    $('[data-cs-action="customise"]').click();
    expect($('[data-cs-cookie-dialog]').hidden).toBe(false);
    $('[data-cs-category="analytics"]').checked = true;
    $('[data-cs-action="save"]').click();
    expect(document.cookie).toMatch(/cshop_consent=2\.1\.0\.\d+/);
    expect(window.__analytics).toBe(true);
    expect(window.__marketing).toBeUndefined();
  });

  test('a saved choice hides the banner and runs allowed scripts at once', () => {
    boot('2.1.0.1700000000');
    expect($('[data-cs-cookie-banner]').hidden).toBe(true);
    expect(window.__analytics).toBe(true);
    expect(window.__marketing).toBeUndefined();
  });

  test('a choice of an older version asks again', () => {
    boot('1.1.1.1700000000');
    expect($('[data-cs-cookie-banner]').hidden).toBe(false);
    expect(window.__analytics).toBeUndefined();
  });

  test('the footer link reopens the preferences with the saved state', () => {
    boot('2.0.1.1700000000');
    $('#footer').click();
    expect($('[data-cs-cookie-dialog]').hidden).toBe(false);
    expect($('[data-cs-category="analytics"]').checked).toBe(false);
    expect($('[data-cs-category="marketing"]').checked).toBe(true);
  });
});
