{**
 * C-Shop — pack, minimum and multiples.
 * In: $cs, $cs_rules_id (opt.), $cs_hide_min (opt., when the core minimum message is shown)
 *}
{$csShowMin = $cs.min_order > 1 && empty($cs_hide_min)}
{if $cs.pack_quantity > 1 || $csShowMin || $cs.step > 1}
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
    {if $csShowMin}
      <li>{l s='Min. order: %qty%' sprintf=['%qty%' => $cs.min_order] d='Shop.Theme.Cshop'}</li>
    {/if}
    {if $cs.step > 1}
      <li>{l s='Multiples of %qty%' sprintf=['%qty%' => $cs.step] d='Shop.Theme.Cshop'}</li>
    {/if}
  </ul>
{/if}
