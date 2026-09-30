{**
 * C-Shop B2B — quote request (UI only).
 * Params: $action_url, $token (required); $product (opt., prefills the product);
 *         $min_qty (opt.)
 * Must be rendered outside other forms. On the product page the selected
 * combination (`group[…]` fields of #add-to-cart-or-refresh) is copied into this
 * form on submit, so the module can resolve id_product_attribute.
 *}
{if !empty($action_url) && !empty($token)}
  <details class="cs-quote">
    <summary class="btn btn-outline-primary cs-quote__toggle">
      <i class="material-icons" aria-hidden="true">&#xE8AD;</i>
      {l s='Request a quote' d='Shop.Theme.Cshop'}
    </summary>
    <form class="cs-quote__form" method="post" action="{$action_url}" data-ps-component="cs-quote">
      <input type="hidden" name="token" value="{$token}">
      {if !empty($product.id_product)}
        <input type="hidden" name="id_product" value="{$product.id_product}">
      {/if}
      <div class="mb-2">
        <label class="form-label" for="cs-quote-qty">{l s='Quantity' d='Shop.Theme.Catalog'}</label>
        <input class="form-control" id="cs-quote-qty" name="qty" type="number" inputmode="numeric" min="{$min_qty|default:1}" value="{$min_qty|default:1}" required>
      </div>
      <div class="mb-2">
        <label class="form-label" for="cs-quote-notes">{l s='Notes' d='Shop.Theme.Cshop'}</label>
        <textarea class="form-control" id="cs-quote-notes" name="notes" rows="3"></textarea>
      </div>
      <button type="submit" class="btn btn-primary">{l s='Send request' d='Shop.Theme.Cshop'}</button>
    </form>
  </details>
{/if}
