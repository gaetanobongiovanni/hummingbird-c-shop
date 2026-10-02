{**
 * C-Shop cookie banner and preferences (shown by views/js/cookie.js).
 * Garante 10/06/2021: reject as easy as accept, the X closes refusing,
 * no cookie wall, choices can be changed from the footer link.
 *}
<div class="cs-cookie" data-cs-cookie data-cs-version="{$cshopcookie.version|intval}">
  <section class="cs-cookie__banner" data-cs-cookie-banner role="region" aria-labelledby="cs-cookie-title" hidden>
    <button type="button" class="cs-cookie__close" data-cs-action="reject" aria-label="{l s='Close and refuse optional cookies' d='Modules.Cshopcookie.Shop'}">
      <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path fill="currentColor" d="M18.3 5.71 12 12.01l-6.3-6.3-1.41 1.41 6.3 6.3-6.3 6.3 1.41 1.41 6.3-6.3 6.3 6.3 1.41-1.41-6.3-6.3 6.3-6.3z"/></svg>
    </button>
    <div class="cs-cookie__text">
      <p class="cs-cookie__title" id="cs-cookie-title">{l s='We respect your privacy' d='Modules.Cshopcookie.Shop'}</p>
      <p>
        {l s='We use technical cookies to make the shop work. With your consent we would also use statistics cookies, to understand how the site is used, and marketing cookies, to show you relevant offers.' d='Modules.Cshopcookie.Shop'}
        {l s='You can change your choice at any time from "Cookie preferences" at the bottom of the page.' d='Modules.Cshopcookie.Shop'}
        {if $cshopcookie.policy_url}<a href="{$cshopcookie.policy_url}">{l s='Read the cookie policy' d='Modules.Cshopcookie.Shop'}</a>{/if}
      </p>
    </div>
    <div class="cs-cookie__actions">
      <button type="button" class="btn btn-outline-primary" data-cs-action="customise">{l s='Customise' d='Modules.Cshopcookie.Shop'}</button>
      <button type="button" class="btn btn-primary" data-cs-action="reject">{l s='Refuse' d='Modules.Cshopcookie.Shop'}</button>
      <button type="button" class="btn btn-primary" data-cs-action="accept">{l s='Accept all' d='Modules.Cshopcookie.Shop'}</button>
    </div>
  </section>

  <section class="cs-cookie__dialog" data-cs-cookie-dialog role="dialog" aria-modal="false" aria-labelledby="cs-cookie-dialog-title" hidden>
    <p class="cs-cookie__title" id="cs-cookie-dialog-title">{l s='Cookie preferences' d='Modules.Cshopcookie.Shop'}</p>
    <p class="cs-cookie__intro">
      {l s='Choose which optional cookies to allow. Technical cookies are needed for the shop and are always active.' d='Modules.Cshopcookie.Shop'}
      {if $cshopcookie.policy_url}<a href="{$cshopcookie.policy_url}">{l s='Read the cookie policy' d='Modules.Cshopcookie.Shop'}</a>{/if}
    </p>

    <ul class="cs-cookie__categories">
      <li class="cs-cookie__category">
        <div class="cs-cookie__category-head">
          <span class="cs-cookie__category-name">{l s='Necessary' d='Modules.Cshopcookie.Shop'}</span>
          <span class="cs-cookie__always">{l s='Always active' d='Modules.Cshopcookie.Shop'}</span>
        </div>
        <p>{l s='Cart, sign-in, security and payment. Without them the shop cannot work.' d='Modules.Cshopcookie.Shop'}</p>
      </li>
      {if $cshopcookie.analytics}
        <li class="cs-cookie__category">
          <div class="cs-cookie__category-head">
            <label class="cs-cookie__category-name" for="cs-cookie-analytics">{l s='Statistics' d='Modules.Cshopcookie.Shop'}</label>
            <input class="cs-cookie__switch" type="checkbox" role="switch" id="cs-cookie-analytics" data-cs-category="analytics">
          </div>
          <p>{l s='They tell us, in aggregate form, which pages are visited and how the site is used, so we can improve it.' d='Modules.Cshopcookie.Shop'}</p>
        </li>
      {/if}
      {if $cshopcookie.marketing}
        <li class="cs-cookie__category">
          <div class="cs-cookie__category-head">
            <label class="cs-cookie__category-name" for="cs-cookie-marketing">{l s='Marketing' d='Modules.Cshopcookie.Shop'}</label>
            <input class="cs-cookie__switch" type="checkbox" role="switch" id="cs-cookie-marketing" data-cs-category="marketing">
          </div>
          <p>{l s='They let us and our partners show you offers in line with your interests, on this site and elsewhere.' d='Modules.Cshopcookie.Shop'}</p>
        </li>
      {/if}
    </ul>

    <div class="cs-cookie__actions">
      <button type="button" class="btn btn-outline-primary" data-cs-action="back">{l s='Back' d='Modules.Cshopcookie.Shop'}</button>
      <button type="button" class="btn btn-primary" data-cs-action="save">{l s='Save preferences' d='Modules.Cshopcookie.Shop'}</button>
      <button type="button" class="btn btn-primary" data-cs-action="accept">{l s='Accept all' d='Modules.Cshopcookie.Shop'}</button>
    </div>
  </section>
</div>
