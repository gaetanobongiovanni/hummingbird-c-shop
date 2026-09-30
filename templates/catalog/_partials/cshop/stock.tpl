{**
 * C-Shop — availability badge from native availability data.
 * States (PS 9): in_stock, available (back-order), last_remaining_items,
 * unavailable, discontinued. In: $product
 *}
{if $product.show_availability && $product.availability_message}
  {$csStockState = $product.availability|default:'in_stock'}
  <span class="cs-stock cs-stock--{$csStockState}">
    <span class="visually-hidden">{l s='Availability:' d='Shop.Theme.Cshop'}</span>
    {$product.availability_message}
  </span>
{/if}
