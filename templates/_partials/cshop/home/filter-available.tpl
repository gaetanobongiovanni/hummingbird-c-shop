{**
 * C-Shop — keep only products in stock (PS 9 states in_stock / last_remaining_items).
 * In: $cshop_source (products), $cshop_limit. Out (parent scope): $cshopFiltered
 *}
{$cshopItems = []}
{foreach from=$cshop_source item=cshopProduct}
  {if $cshopItems|count < $cshop_limit && ($cshopProduct.availability == 'in_stock' || $cshopProduct.availability == 'last_remaining_items')}
    {$cshopItems[] = $cshopProduct}
  {/if}
{/foreach}
{assign var='cshopFiltered' value=$cshopItems scope='parent'}
