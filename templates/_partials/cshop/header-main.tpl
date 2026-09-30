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
      <div class="cs-header__search">
        {widget name='ps_searchbar'}
      </div>
    {/block}

    {block name='cshop_header_actions'}
      <nav class="cs-header__actions" aria-label="{l s='Your account' d='Shop.Theme.Customeraccount'}">
        {widget name='ps_customersignin'}

        {* Revealed by JS only when the blockwishlist module is active (see src/js/cshop/header.ts) *}
        <div class="header-block cs-header__wishlist" data-ps-component="cs-wishlist-link" hidden>
          <a class="header-block__action-btn" href="{$link->getModuleLink('blockwishlist', 'lists', [], true)}" rel="nofollow" aria-label="{l s='My wishlists' d='Shop.Theme.Customeraccount'}">
            <i class="material-icons header-block__icon" aria-hidden="true">&#xE87E;</i>
            <span class="header-block__title d-none d-lg-inline">{l s='Wishlist' d='Shop.Theme.Customeraccount'}</span>
          </a>
        </div>

        {if !$configuration.is_catalog}
          {widget name='ps_shoppingcart'}
        {/if}
      </nav>
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
