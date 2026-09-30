{**
 * C-Shop B2B — customer product lists (UI only).
 * Params: $lists = [['name','count','url','add_to_cart_url'(opt.)], …], $create_url (opt.)
 *}
{if !empty($lists) || !empty($create_url)}
  <section class="cs-product-lists" aria-labelledby="cs-product-lists-title">
    <div class="cs-section__header">
      <h2 id="cs-product-lists-title" class="cs-section__title">{l s='My product lists' d='Shop.Theme.Cshop'}</h2>
      {if !empty($create_url)}
        <a class="btn btn-outline-primary btn-sm" href="{$create_url}" rel="nofollow">{l s='New list' d='Shop.Theme.Cshop'}</a>
      {/if}
    </div>
    {if !empty($lists)}
      <ul class="cs-product-lists__grid">
        {foreach from=$lists item=csList}
          <li class="cs-card cs-card--interactive">
            <a class="cs-card__title stretched-link" href="{$csList.url}">{$csList.name}</a>
            <p class="cs-card__text">{l s='%count% products' sprintf=['%count%' => $csList.count|default:0] d='Shop.Theme.Cshop'}</p>
            {if !empty($csList.add_to_cart_url)}
              <a class="btn btn-accent btn-sm cs-product-lists__cta" href="{$csList.add_to_cart_url}" rel="nofollow">{l s='Add all to cart' d='Shop.Theme.Cshop'}</a>
            {/if}
          </li>
        {/foreach}
      </ul>
    {/if}
  </section>
{/if}
