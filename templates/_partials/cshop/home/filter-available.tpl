{**
 * C-Shop — keep only products orderable now.
 * In: $cshop_source (products), $cshop_limit. Out (parent scope): $cshopFiltered
 *}
{$cshopItems = []}
{foreach from=$cshop_source item=cshopProduct}
  {if $cshopItems|count < $cshop_limit && $cshopProduct.availability == 'available'}
    {$cshopItems[] = $cshopProduct}
  {/if}
{/foreach}
{assign var='cshopFiltered' value=$cshopItems scope='parent'}
