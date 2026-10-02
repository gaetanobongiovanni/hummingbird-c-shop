{**
 * C-Shop: brands in the left column of catalogue pages, as a collapsible
 * block like the categories (ps_brandlist widget variables: id, name, link).
 *}
{widget_block name='ps_brandlist'}
  {if !empty($brands)}
    <div class="left-block cs-collapsible cs-left-brands">
      <h2 class="left-block__title h3">
        <button
          class="cs-collapsible__toggle collapsed"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#cs-left-brands"
          aria-expanded="false"
          aria-controls="cs-left-brands"
        >
          {l s='Brands' d='Shop.Theme.Catalog'}
          <span class="cs-collapsible__count">{$brands|count}</span>
        </button>
      </h2>

      <div id="cs-left-brands" class="collapse cs-collapsible__body">
        <nav aria-label="{l s='Brands' d='Shop.Theme.Catalog'}">
          <ul class="cs-left-brands__list">
            {foreach from=$brands item=brand}
              <li>
                <a class="cs-left-brands__link{if $page.page_name == 'manufacturer' && isset($manufacturer.id) && $manufacturer.id == $brand.id_manufacturer} is-current{/if}" href="{$brand.link}">{$brand.name}</a>
              </li>
            {/foreach}
          </ul>
          <a class="cs-left-brands__all" href="{$page_link}">{l s='All brands' d='Shop.Theme.Cshop'}</a>
        </nav>
      </div>
    </div>
  {/if}
{/widget_block}
