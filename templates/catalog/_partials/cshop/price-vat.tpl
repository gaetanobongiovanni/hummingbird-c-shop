{**
 * C-Shop — the "other" VAT price, for business and private customers.
 * Shows "x,xx € + IVA" when prices are displayed tax included, or
 * "x,xx € IVA incl." when they are displayed tax excluded.
 * In: $product, $cs_vat_class (opt.)
 *}
{if $configuration.taxes_enabled
  && isset($product.price_amount_tax_excluded) && isset($product.price_amount_tax_included)
  && $product.price_amount_tax_excluded != $product.price_amount_tax_included}
  <span class="cs-vat {$cs_vat_class|default:''}">
    {if $configuration.display_prices_tax_incl}
      {l s='%price% + VAT' sprintf=['%price%' => $product.price_tax_excluded] d='Shop.Theme.Cshop'}
    {else}
      {l s='%price% incl. VAT' sprintf=['%price%' => $product.price_tax_included] d='Shop.Theme.Cshop'}
    {/if}
  </span>
{/if}
