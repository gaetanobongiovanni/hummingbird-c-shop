{**
 * Google Consent Mode v2 defaults, printed in <head> before any Google tag.
 * A choice already saved (same version) is applied at once, so returning
 * visitors are measured from the first hit.
 *}
<script data-cs-consent-default>
{literal}
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
(function () {
  var g = {analytics: false, marketing: false};
  var m = /(?:^|;\s*)cshop_consent=(\d+)\.([01])\.([01])\.\d+/.exec(document.cookie);
{/literal}
  if (m && m[1] === '{$cshopcookie.version|intval}') {literal}{ g.analytics = m[2] === '1'; g.marketing = m[3] === '1'; }
  gtag('consent', 'default', {
    ad_storage: g.marketing ? 'granted' : 'denied',
    ad_user_data: g.marketing ? 'granted' : 'denied',
    ad_personalization: g.marketing ? 'granted' : 'denied',
    analytics_storage: g.analytics ? 'granted' : 'denied',
    functionality_storage: 'granted',
    security_storage: 'granted',
    wait_for_update: 500
  });
  gtag('set', 'ads_data_redaction', true);
}());
{/literal}
</script>
