{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}

{* C-Shop: promotions section (prices-drop products) *}
{extends file="components/module-products.tpl"}

{block name='module_products_name'}ps-specials{/block}

{block name='module_products_title'}
  {include file='components/section-title.tpl' title={l s='Promotions' d='Shop.Theme.Cshop'}}
{/block}

{block name='module_products_header_link'}
  <a class="cs-section__link" href="{$allSpecialProductsLink}">{l s='All promotions' d='Shop.Theme.Cshop'}</a>
{/block}
