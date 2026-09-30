{**
 * C-Shop — availability badge from native availability data.
 * States (PS 9): in_stock, available (back-order), last_remaining_items,
 * unavailable, discontinued. The Back Office label is used when configured,
 * otherwise a short label for the state. In: $product
 *}
{if $product.show_availability && !empty($product.availability)}
  {$csStockState = $product.availability}
  {if !empty($product.availability_message)}
    {$csStockLabel = $product.availability_message}
  {elseif $csStockState == 'in_stock'}
    {$csStockLabel = {l s='In stock' d='Shop.Theme.Cshop'}}
  {elseif $csStockState == 'available'}
    {$csStockLabel = {l s='Available on order' d='Shop.Theme.Cshop'}}
  {elseif $csStockState == 'last_remaining_items'}
    {$csStockLabel = {l s='Last items in stock' d='Shop.Theme.Cshop'}}
  {elseif $csStockState == 'discontinued'}
    {$csStockLabel = {l s='Discontinued' d='Shop.Theme.Cshop'}}
  {else}
    {$csStockLabel = {l s='Out of stock' d='Shop.Theme.Cshop'}}
  {/if}
  <span class="cs-stock cs-stock--{$csStockState}">
    <span class="visually-hidden">{l s='Availability:' d='Shop.Theme.Cshop'}</span>
    {$csStockLabel}
  </span>
{/if}
