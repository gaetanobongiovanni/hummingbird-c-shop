/**
 * C-Shop cookie consent banner.
 *
 * Consent is kept in the first-party cookie "cshop_consent" as
 * "<version>.<analytics 0|1>.<marketing 0|1>.<unix time>", valid 180 days.
 * A different version (changed in the back office) asks again.
 *
 * - Google Consent Mode v2 is updated on every choice (the default "denied"
 *   is printed in <head> by the module before any Google tag).
 * - Scripts written as <script type="text/plain" data-cs-consent="analytics">
 *   (or "marketing") run only after that consent.
 * - Any element with [data-cs-cookie-open] or href="#cookie-settings" reopens
 *   the preferences.
 * - window.CshopConsent exposes get(), has(category) and open().
 * - The "cshop:consent" event is dispatched on document after each choice.
 *
 * Kept ASCII-only: PrestaShop's CCC concatenates module assets.
 */
(function () {
  'use strict';

  var COOKIE = 'cshop_consent';
  var MAX_AGE = 180 * 24 * 60 * 60;
  var CATEGORIES = ['analytics', 'marketing'];

  function readCookie(name) {
    var parts = document.cookie ? document.cookie.split(';') : [];
    for (var i = 0; i < parts.length; i++) {
      var p = parts[i].replace(/^\s+/, '');
      if (p.indexOf(name + '=') === 0) {
        return decodeURIComponent(p.substring(name.length + 1));
      }
    }
    return null;
  }

  /** Parses the cookie value; null if missing, malformed or of another version. */
  function parse(value, version) {
    if (!value) {
      return null;
    }
    var m = /^(\d+)\.([01])\.([01])\.(\d+)$/.exec(value);
    if (!m || m[1] !== String(version)) {
      return null;
    }
    return { analytics: m[2] === '1', marketing: m[3] === '1', time: parseInt(m[4], 10) };
  }

  function serialize(consent, version, now) {
    return [version, consent.analytics ? 1 : 0, consent.marketing ? 1 : 0, Math.floor(now / 1000)].join('.');
  }

  function gtagUpdate(consent) {
    window.dataLayer = window.dataLayer || [];
    var g = window.gtag || function () { window.dataLayer.push(arguments); };
    g('consent', 'update', {
      analytics_storage: consent.analytics ? 'granted' : 'denied',
      ad_storage: consent.marketing ? 'granted' : 'denied',
      ad_user_data: consent.marketing ? 'granted' : 'denied',
      ad_personalization: consent.marketing ? 'granted' : 'denied'
    });
    window.dataLayer.push({
      event: 'cshop_consent_update',
      cshop_consent_analytics: consent.analytics,
      cshop_consent_marketing: consent.marketing
    });
  }

  /** Turns <script type="text/plain" data-cs-consent="x"> into real scripts once allowed. */
  function activateScripts(consent) {
    var blocked = document.querySelectorAll('script[type="text/plain"][data-cs-consent]');
    for (var i = 0; i < blocked.length; i++) {
      var old = blocked[i];
      if (!consent[old.getAttribute('data-cs-consent')]) {
        continue;
      }
      var s = document.createElement('script');
      for (var j = 0; j < old.attributes.length; j++) {
        var a = old.attributes[j];
        if (a.name !== 'type' && a.name !== 'data-cs-consent') {
          s.setAttribute(a.name, a.value);
        }
      }
      if (!old.src) {
        s.text = old.text;
      }
      old.parentNode.replaceChild(s, old);
    }
  }

  function init(root) {
    var version = root.getAttribute('data-cs-version') || '1';
    var banner = root.querySelector('[data-cs-cookie-banner]');
    var dialog = root.querySelector('[data-cs-cookie-dialog]');
    var current = parse(readCookie(COOKIE), version);
    var lastFocus = null;

    function save(consent) {
      var secure = window.location.protocol === 'https:' ? '; Secure' : '';
      document.cookie = COOKIE + '=' + serialize(consent, version, Date.now())
        + '; Max-Age=' + MAX_AGE + '; Path=/; SameSite=Lax' + secure;
      current = { analytics: !!consent.analytics, marketing: !!consent.marketing, time: Math.floor(Date.now() / 1000) };
      gtagUpdate(current);
      activateScripts(current);
      hideAll();
      var ev;
      try {
        ev = new CustomEvent('cshop:consent', { detail: { analytics: current.analytics, marketing: current.marketing } });
      } catch (e) {
        ev = document.createEvent('CustomEvent');
        ev.initCustomEvent('cshop:consent', false, false, { analytics: current.analytics, marketing: current.marketing });
      }
      document.dispatchEvent(ev);
    }

    function hideAll() {
      banner.hidden = true;
      dialog.hidden = true;
      root.classList.remove('is-open');
      if (lastFocus && lastFocus.focus) {
        lastFocus.focus();
      }
    }

    function showBanner() {
      banner.hidden = false;
      dialog.hidden = true;
      root.classList.add('is-open');
    }

    function openDialog() {
      lastFocus = document.activeElement;
      var state = current || { analytics: false, marketing: false };
      for (var i = 0; i < CATEGORIES.length; i++) {
        var box = dialog.querySelector('[data-cs-category="' + CATEGORIES[i] + '"]');
        if (box) {
          box.checked = !!state[CATEGORIES[i]];
        }
      }
      banner.hidden = true;
      dialog.hidden = false;
      root.classList.add('is-open');
      var first = dialog.querySelector('input:not([disabled]), button');
      if (first) {
        first.focus();
      }
    }

    function fromDialog() {
      var c = {};
      for (var i = 0; i < CATEGORIES.length; i++) {
        var box = dialog.querySelector('[data-cs-category="' + CATEGORIES[i] + '"]');
        c[CATEGORIES[i]] = !!(box && box.checked);
      }
      return c;
    }

    root.addEventListener('click', function (e) {
      var t = e.target.closest ? e.target.closest('[data-cs-action]') : null;
      if (!t) {
        return;
      }
      var action = t.getAttribute('data-cs-action');
      if (action === 'accept') {
        save({ analytics: true, marketing: true });
      } else if (action === 'reject') {
        save({ analytics: false, marketing: false });
      } else if (action === 'customise') {
        openDialog();
      } else if (action === 'save') {
        save(fromDialog());
      } else if (action === 'back') {
        if (current) {
          hideAll();
        } else {
          showBanner();
        }
      }
    });

    document.addEventListener('click', function (e) {
      var t = e.target.closest ? e.target.closest('[data-cs-cookie-open], a[href="#cookie-settings"]') : null;
      if (t) {
        e.preventDefault();
        openDialog();
      }
    });

    document.addEventListener('keydown', function (e) {
      if ((e.key === 'Escape' || e.key === 'Esc') && !dialog.hidden) {
        if (current) {
          hideAll();
        } else {
          showBanner();
        }
      }
    });

    window.CshopConsent = {
      get: function () {
        return current ? { analytics: current.analytics, marketing: current.marketing } : null;
      },
      has: function (category) {
        return !!(current && current[category]);
      },
      open: openDialog
    };

    if (current) {
      activateScripts(current);
    } else {
      showBanner();
    }
  }

  function boot() {
    var root = document.querySelector('[data-cs-cookie]');
    if (root) {
      init(root);
    }
  }

  window.CshopConsentInternals = { parse: parse, serialize: serialize };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
}());
