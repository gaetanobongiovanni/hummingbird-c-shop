{**
 * C-Shop — information bar.
 * Left: shop promises (translatable, Shop.Theme.Cshop). Only facts that are true
 * for the shop: e-invoicing, secure payments, phone assistance from
 * ps_contactinfo (Shop parameters > Contact). Right: displayNav2 (language,
 * currency, extra links).
 *}
<div class="header-top cs-info-bar d-none d-md-block">
  <div class="container-md cs-info-bar__inner">
    <ul class="cs-info-bar__usp">
      <li class="cs-info-bar__usp-item">
        <span class="material-icons" aria-hidden="true">receipt_long</span>
        {l s='Electronic invoice for businesses and public bodies' d='Shop.Theme.Cshop'}
      </li>
      <li class="cs-info-bar__usp-item">
        <span class="material-icons" aria-hidden="true">lock</span>
        {l s='Secure payments' d='Shop.Theme.Cshop'}
      </li>
      {widget_block name='ps_contactinfo'}
        {if !empty($contact_infos.phone)}
          <li class="cs-info-bar__usp-item">
            <span class="material-icons" aria-hidden="true">call</span>
            {l s='Assistance' d='Shop.Theme.Cshop'}
            <a href="tel:{$contact_infos.phone|replace:' ':''}">{$contact_infos.phone}</a>
          </li>
        {elseif !empty($contact_infos.email)}
          <li class="cs-info-bar__usp-item">
            <span class="material-icons" aria-hidden="true">mail</span>
            <a href="mailto:{$contact_infos.email}">{$contact_infos.email}</a>
          </li>
        {/if}
      {/widget_block}
    </ul>

    {if !empty($header_nav_2)}
      <div class="header-top__right cs-info-bar__right">
        {$header_nav_2 nofilter}
      </div>
    {/if}
  </div>
</div>
