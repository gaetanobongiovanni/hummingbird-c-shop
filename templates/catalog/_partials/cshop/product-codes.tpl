{**
 * C-Shop — product identifiers. In: $cs, $cs_codes_full (bool), $cs_codes_class
 *}
{if $cs.reference || $cs.oem_code || (!empty($cs_codes_full) && ($cs.supplier_code || $cs.ean))}
  <dl class="cs-codes {$cs_codes_class|default:''}">
    {if $cs.reference}
      <div class="cs-codes__item">
        <dt>{l s='Code' d='Shop.Theme.Cshop'}:</dt>
        <dd class="cs-code">{$cs.reference}</dd>
      </div>
    {/if}
    {if !empty($cs_codes_full) && $cs.supplier_code}
      <div class="cs-codes__item">
        <dt>{l s='Supplier code' d='Shop.Theme.Cshop'}:</dt>
        <dd class="cs-code">{$cs.supplier_code}</dd>
      </div>
    {/if}
    {if $cs.oem_code}
      <div class="cs-codes__item">
        <dt>{l s='OEM code' d='Shop.Theme.Cshop'}:</dt>
        <dd class="cs-code">{$cs.oem_code}</dd>
      </div>
    {/if}
    {if !empty($cs_codes_full) && $cs.ean}
      <div class="cs-codes__item">
        <dt>{l s='EAN' d='Shop.Theme.Cshop'}:</dt>
        <dd class="cs-code">{$cs.ean}</dd>
      </div>
    {/if}
  </dl>
{/if}
