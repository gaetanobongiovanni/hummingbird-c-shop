{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}

{extends file="components/module-products.tpl"}

{block name='module_products_name'}ps-featuredproducts{/block}

{block name='module_products_title'}
  {if $page.page_name == 'index'}
    {include file='components/section-title.tpl' title={l s='Available products' d='Shop.Theme.Cshop'}}
  {else}
    {include file='components/section-title.tpl' title={l s='Featured products' d='Shop.Theme.Catalog'}}
  {/if}
{/block}

{block name='module_products_header_link'}
  <a class="cs-section__link" href="{$allProductsLink}">{l s='All featured products' d='Shop.Theme.Catalog'}</a>
{/block}

{* C-Shop: on the homepage only products in stock are listed (max 10) *}
{block name='module_products_list'}
  {if $page.page_name == 'index'}
    {include file='_partials/cshop/home/filter-available.tpl' cshop_source=$products cshop_limit=10}
    {if $cshopFiltered|count}
      <div class="module-products__list">
        {include file='catalog/_partials/productlist.tpl' products=$cshopFiltered}
      </div>
    {/if}
  {else}
    {$smarty.block.parent}
  {/if}
{/block}
