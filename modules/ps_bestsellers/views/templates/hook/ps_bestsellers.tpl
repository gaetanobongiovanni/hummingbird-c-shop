{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}

{extends file="components/module-products.tpl"}

{block name='module_products_name'}ps-bestsellers{/block}

{block name='module_products_title'}
  {include file='components/section-title.tpl' title={l s='Best sellers' d='Shop.Theme.Catalog'}}
{/block}

{block name='module_products_header_link'}
  <a class="cs-section__link" href="{$allBestSellers}">{l s='All best sellers' d='Shop.Theme.Catalog'}</a>
{/block}
