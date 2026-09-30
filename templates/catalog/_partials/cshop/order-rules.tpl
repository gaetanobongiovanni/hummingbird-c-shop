{**
 * C-Shop — pack, minimum and multiples. In: $cs, $product, $cs_rules_id (opt.)
 *}
{if $cs.pack_quantity > 1 || $cs.min > 1 || $cs.step > 1}
  <ul class="cs-qty__rules" {if !empty($cs_rules_id)}id="{$cs_rules_id}"{/if}>
    {if $cs.pack_quantity > 1}
      <li>
        {if $cs.pack_label}
          {l s='%label% of %qty% pcs' sprintf=['%label%' => $cs.pack_label, '%qty%' => $cs.pack_quantity] d='Shop.Theme.Cshop'}
        {else}
          {l s='Pack of %qty% pcs' sprintf=['%qty%' => $cs.pack_quantity] d='Shop.Theme.Cshop'}
        {/if}
      </li>
    {/if}
    {if $cs.min > 1}
      <li>{l s='Min. order: %qty%' sprintf=['%qty%' => $cs.min] d='Shop.Theme.Cshop'}</li>
    {/if}
    {if $cs.step > 1}
      <li>{l s='Multiples of %qty%' sprintf=['%qty%' => $cs.step] d='Shop.Theme.Cshop'}</li>
    {/if}
  </ul>
{/if}
