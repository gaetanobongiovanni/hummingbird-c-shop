{**
 * C-Shop homepage — quick reorder & B2B shortcuts.
 * Uses native customer pages; `displayCshopQuickOrder` is an optional hook for
 * a quick-order module (render templates/components/cshop/b2b/quick-order.tpl).
 *}
{if !$configuration.is_catalog}
  <section class="cs-section cs-section--tight" aria-labelledby="cs-home-reorder-title">
    <div class="container">
      <div class="cs-reorder">
        <div class="cs-reorder__text">
          <h2 id="cs-home-reorder-title" class="cs-section__title">{l s='Quick reorder' d='Shop.Theme.Cshop'}</h2>
          <p class="cs-section__subtitle">
            {if $customer.is_logged}
              {l s='Open a previous order and add all its products to the cart again.' d='Shop.Theme.Cshop'}
            {else}
              {l s='Sign in to reorder from your previous orders.' d='Shop.Theme.Cshop'}
            {/if}
          </p>
        </div>
        <div class="cs-reorder__actions">
          {if $customer.is_logged}
            <a class="btn btn-primary" href="{$urls.pages.history}">{l s='Order history and reorder' d='Shop.Theme.Cshop'}</a>
          {else}
            <a class="btn btn-primary" href="{$urls.pages.authentication}?back={$urls.pages.history|urlencode}" rel="nofollow">{l s='Sign in' d='Shop.Theme.Actions'}</a>
          {/if}
        </div>
        {capture name='cshop_quick_order'}{hook h='displayCshopQuickOrder'}{/capture}
        {if !empty($smarty.capture.cshop_quick_order)}
          <div class="cs-reorder__module">{$smarty.capture.cshop_quick_order nofilter}</div>
        {/if}
      </div>
    </div>
  </section>
{/if}
