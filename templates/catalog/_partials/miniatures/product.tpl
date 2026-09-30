{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{$componentName = 'product-miniature'}
{* C-Shop: normalised codes, pack, minimum and multiples ($cs) *}
{include file='catalog/_partials/cshop/product-data.tpl' product=$product}

{block name='product_miniature_item'}
  <article
    class="{$componentName} js-{$componentName}"
    data-id-product="{$product.id_product}"
    data-id-product-attribute="{$product.id_product_attribute}"
  >
    <div class="{$componentName}__inner">
      {block name='product_miniature_top'}
        <div class="{$componentName}__top">
          {include file='catalog/_partials/product-flags.tpl'}

          {include file='catalog/_partials/miniatures/product-image.tpl'}

          {include file='catalog/_partials/miniatures/product-quickview.tpl'}
        </div>
      {/block}

      {block name='product_miniature_bottom'}
        <div class="{$componentName}__bottom">
          <div class="{$componentName}__infos">
            {block name='cshop_product_brand'}
              {if $cs.brand}
                <span class="{$componentName}__brand">{$cs.brand}</span>
              {/if}
            {/block}

            {block name='product_name'}
              <a class="{$componentName}__title" href="{$product.url}" aria-label="{l s='View product %product_name%' sprintf=['%product_name%' => $product.name] d='Shop.Theme.Catalog'}">{$product.name}</a>
            {/block}

            {block name='cshop_product_codes'}
              {include file='catalog/_partials/cshop/product-codes.tpl' cs=$cs cs_codes_class="{$componentName}__codes"}
            {/block}

            {block name='cshop_product_stock'}
              <div class="{$componentName}__stock">
                {include file='catalog/_partials/cshop/stock.tpl' product=$product}
              </div>
            {/block}

            {block name='product_variants'}
              {if $product.main_variants}
                <div class="{$componentName}__variants">
                  {include file='catalog/_partials/variant-links.tpl' variants=$product.main_variants}
                </div>
              {/if}
            {/block}

            {if $product.show_price}
              <div class="{$componentName}__prices">
                {block name='product_price'}
                  {hook h='displayProductPriceBlock' product=$product type="before_price"}

                  <div class="{$componentName}__price" aria-label="{l s='Price' d='Shop.Theme.Catalog'}">
                    {capture name='custom_price'}{hook h='displayProductPriceBlock' product=$product type='custom_price' hook_origin='products_list'}{/capture}
                    {if '' !== $smarty.capture.custom_price}
                      {$smarty.capture.custom_price nofilter}
                    {else}
                      {$product.price}
                    {/if}
                  </div>

                  {hook h='displayProductPriceBlock' product=$product type='unit_price'}

                  {if !empty($product.unit_price_full)}
                    <span class="{$componentName}__unit-price">{$product.unit_price_full}</span>
                  {/if}

                  {hook h='displayProductPriceBlock' product=$product type='weight'}
                {/block}

                {block name='product_discount_price'}
                  {if $product.show_price}
                    <div class="{$componentName}__discount-price">
                      {if $product.has_discount}
                        {hook h='displayProductPriceBlock' product=$product type="old_price"}

                        <span class="{$componentName}__regular-price" aria-label="{l s='Regular price' d='Shop.Theme.Catalog'}">{$product.regular_price}</span>
                      {/if}
                    </div>
                  {/if}
                {/block}
              </div>
            {/if}

            {block name='product_reviews'}
              {hook h='displayProductListReviews' product=$product}
            {/block}

            {block name='cshop_product_rules'}
              {include file='catalog/_partials/cshop/order-rules.tpl' cs=$cs cs_rules_id="cs-rules-{$product.id_product}-{$product.id_product_attribute}"}
            {/block}
          </div>

          {block name='product_actions'}
            <div class="{$componentName}__actions">
              {if $product.add_to_cart_url}
                <form class="{$componentName}__form" action="{$urls.pages.cart}" method="post">
                  <input type="hidden" value="{$product.id_product}" name="id_product">
                  {if $product.id_product_attribute}
                      <input type="hidden" value="{$product.id_product_attribute}" name="id_product_attribute">
                  {/if}
                  <input type="hidden" name="token" value="{$static_token}">
  
                  {$csQtyValue = $product.quantity_wanted|default:1}
                  {if $csQtyValue < $cs.min}{$csQtyValue = $cs.min}{/if}
                  {$csQtyAttrs = [
                    "id" => "quantity_wanted_{$product.id_product}",
                    "value" => "{$csQtyValue}",
                    "min" => "{$cs.min}",
                    "step" => "{$cs.step}",
                    "data-ps-component" => "cs-qty"
                  ]}
                  {if $cs.pack_quantity > 1 || $cs.min > 1 || $cs.step > 1}
                    {$csQtyAttrs['aria-describedby'] = "cs-rules-{$product.id_product}-{$product.id_product_attribute}"}
                  {/if}
                  <div class="quantity-button js-quantity-button">
                    {include file='components/qty-input.tpl' attributes=$csQtyAttrs}
                  </div>
  
                  <button 
                    data-button-action="add-to-cart" 
                    class="product-miniature__add btn btn-accent btn-square-icon"
                    aria-label="{l s='Add to cart %product_name%' sprintf=['%product_name%' => $product.name] d='Shop.Theme.Actions'}"
                    title="{l s='Add to cart %product_name%' sprintf=['%product_name%' => $product.name] d='Shop.Theme.Actions'}"
                    data-ps-ref="add-to-cart"
                  >
                    <i class="material-icons" aria-hidden="true">&#xe854;</i>
                    <span class="product-miniature__add-text">{l s='Add to cart' d='Shop.Theme.Actions'}</span>
                  </button>
                </form>
              {else}
                <a href="{$product.url}" class="product-miniature__details btn btn-outline-primary" aria-label="{l s='See details for %product_name%' sprintf=['%product_name%' => $product.name] d='Shop.Theme.Actions'}">
                  {l s='See details' d='Shop.Theme.Actions'}
                </a>
              {/if}
            </div>
          {/block}
        </div>
      {/block}
    </div>
  </article>
{/block}
