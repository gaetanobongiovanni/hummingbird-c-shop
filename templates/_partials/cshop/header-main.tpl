{**
 * C-Shop — main header row: menu toggle, logo, prominent search, account actions
 * and the category mega-menu (desktop). Layout is a CSS grid, see
 * src/scss/cshop/layout/_header.scss.
 *}
<div class="header-bottom cs-header">
  <div class="container-md cs-header__grid">
    <div class="cs-header__logo">
      {if $shop.logo_details}
        {if $page.page_name == 'index'}<h1 class="header-bottom__h1 mb-0">{/if}
          {renderLogo}
        {if $page.page_name == 'index'}</h1>{/if}
      {else}
        <a class="cs-header__shop-name" href="{$urls.pages.index}">{$shop.name}</a>
      {/if}
    </div>

    {block name='cshop_header_search'}
      {if $page.page_name == 'checkout'}
        {* Checkout: no search or menu to leave the page by mistake, a reassurance line instead *}
        <div class="cs-header__search cs-header__secure">
          <i class="material-icons" aria-hidden="true">&#xE897;</i>
          <span><strong>{l s='Secure checkout' d='Shop.Theme.Cshop'}</strong> <span class="cs-header__secure-note">{l s='Encrypted connection, payments protected' d='Shop.Theme.Cshop'}</span></span>
        </div>
      {else}
        <div class="cs-header__search">
          {widget name='ps_searchbar'}
        </div>
      {/if}
    {/block}

    {block name='cshop_header_actions'}
      {if $page.page_name == 'checkout'}
      <nav class="cs-header__actions" aria-label="{l s='Checkout' d='Shop.Theme.Checkout'}">
        {if $shop.email}
          <div class="header-block d-none d-lg-block">
            <a class="header-block__action-btn" href="mailto:{$shop.email}" aria-label="{l s='Need help?' d='Shop.Theme.Cshop'} {$shop.email}">
              <i class="material-icons header-block__icon" aria-hidden="true">&#xE158;</i>
              <span class="header-block__title">{l s='Need help?' d='Shop.Theme.Cshop'}</span>
            </a>
          </div>
        {/if}
        <div class="header-block">
          <a class="header-block__action-btn" href="{$urls.pages.cart}?action=show" aria-label="{l s='Back to cart' d='Shop.Theme.Cshop'}">
            <i class="material-icons header-block__icon" aria-hidden="true">&#xE5C4;</i>
            <span class="header-block__title">{l s='Back to cart' d='Shop.Theme.Cshop'}</span>
          </a>
        </div>
      </nav>
      {else}
      <nav class="cs-header__actions" aria-label="{l s='Your account' d='Shop.Theme.Customeraccount'}">
        {widget name='ps_customersignin'}

        {* Revealed by JS only when the blockwishlist module is active (see src/js/cshop/header.ts) *}
        <div class="header-block cs-header__wishlist" data-ps-component="cs-wishlist-link" hidden>
          <a class="header-block__action-btn" href="{$link->getModuleLink('blockwishlist', 'lists', [], true)}" rel="nofollow" aria-label="{l s='My wishlists' d='Shop.Theme.Cshop'}">
            <i class="material-icons header-block__icon" aria-hidden="true">&#xE87E;</i>
            <span class="header-block__title d-none d-lg-inline">{l s='Wishlist' d='Shop.Theme.Cshop'}</span>
          </a>
        </div>

        {if !$configuration.is_catalog}
          {widget name='ps_shoppingcart'}
        {/if}
      </nav>
      {/if}
    {/block}

    {block name='cshop_header_menu'}
      {* ps_mainmenu renders the desktop mega-menu, the mobile toggle and the off-canvas menu *}
      <div class="cs-header__menu">
        {widget name='ps_mainmenu'}
      </div>
    {/block}
  </div>

  {capture name="header_top_hook"}{hook h='displayTop'}{/capture}
  {if !empty($smarty.capture.header_top_hook)}
    <div class="container-md cs-header__extra">
      {$smarty.capture.header_top_hook nofilter}
    </div>
  {/if}
</div>
