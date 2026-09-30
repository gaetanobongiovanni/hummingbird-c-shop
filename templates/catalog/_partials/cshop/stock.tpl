{**
 * C-Shop — availability badge from native availability data.
 * In: $product
 *}
{if $product.show_availability && $product.availability_message}
  {$csStockState = $product.availability|default:'available'}
  <span class="cs-stock cs-stock--{$csStockState}">
    <span class="visually-hidden">{l s='Availability:' d='Shop.Theme.Cshop'}</span>
    {$product.availability_message}
  </span>
{/if}
