{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{block name='module_products'}
  {block name='module_products_variables'}
    {assign var="need_container" value="true"}
  {/block}

  {* C-Shop: sections share the cs-section header (title + "see all" link) *}
  <section class="{block name='module_products_name'}{/block} cs-module-products">
    <div class="module-products {if isset($need_container) && $need_container}container{/if}">
      <div class="cs-section__header">
        {block name='module_products_title'}{/block}
        {block name='module_products_header_link'}{/block}
      </div>

      {block name='module_products_list'}
        {if $products}
          <div class="module-products__list">
            {include file='catalog/_partials/productlist.tpl' products=$products}
          </div>
        {/if}
      {/block}
        
      {block name='module_products_footer' hide}
        <div class="module-products__buttons">
          {$smarty.block.child}
        </div>
      {/block}
    </div>
  </section>
{/block}
