{**
 * C-Shop — information bar (assistance, delivery, commercial conditions).
 * Content comes from configurable modules only (no hard-coded data):
 *  - displayNav1: ps_contactinfo (phone / e-mail for assistance), ps_linklist…
 *  - displayNav2: language / currency selectors, extra links
 * Delivery and commercial-conditions messages come from `blockreassurance`
 * (hooked on displayAfterBodyOpeningTag, configured in Back Office).
 *}
{if !empty($header_nav_1) || !empty($header_nav_2)}
  <div class="header-top cs-info-bar d-none d-md-block">
    <div class="container-md cs-info-bar__inner">
      <div class="header-top__left cs-info-bar__left">
        <span class="material-icons cs-info-bar__icon" aria-hidden="true">&#xE0CD;</span>
        {$header_nav_1 nofilter}
      </div>

      <div class="header-top__right cs-info-bar__right">
        {$header_nav_2 nofilter}
      </div>
    </div>
  </div>
{/if}
