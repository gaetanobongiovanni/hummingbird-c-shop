{**
 * C-Shop B2B — panel on the back office customer page
 *}
<div class="card">
  <h3 class="card-header">
    <i class="material-icons">business</i>
    {l s='Business data' d='Modules.Cshopb2b.Admin'}
    {if $cs_b2b.status == 'pending'}
      <span class="badge badge-warning">{l s='Reseller to approve' d='Modules.Cshopb2b.Admin'}</span>
    {elseif $cs_b2b.status == 'approved'}
      <span class="badge badge-success">{l s='Approved reseller' d='Modules.Cshopb2b.Admin'}</span>
    {elseif $cs_b2b.status == 'rejected'}
      <span class="badge badge-danger">{l s='Reseller rejected' d='Modules.Cshopb2b.Admin'}</span>
    {/if}
  </h3>
  <div class="card-body">
    <p class="mb-1"><strong>{$cs_b2b.company|escape:'html':'UTF-8'}</strong></p>
    <p class="mb-1">
      {l s='VAT number' d='Modules.Cshopb2b.Admin'}: {$cs_b2b.vat_number|default:'-'|escape:'html':'UTF-8'} ·
      {l s='Tax code' d='Modules.Cshopb2b.Admin'}: {$cs_b2b.tax_code|default:'-'|escape:'html':'UTF-8'}
    </p>
    <p class="mb-3">
      {if $cs_b2b.sdi_code}SDI: {$cs_b2b.sdi_code|escape:'html':'UTF-8'} · {/if}
      {if $cs_b2b.ipa_code}IPA: {$cs_b2b.ipa_code|escape:'html':'UTF-8'} · {/if}
      PEC: {$cs_b2b.pec|default:'-'|escape:'html':'UTF-8'}
    </p>
    <a class="btn btn-outline-primary" href="{$cs_link|escape:'html':'UTF-8'}">
      {if $cs_b2b.status == 'pending'}
        {l s='Check the visura and approve' d='Modules.Cshopb2b.Admin'}
      {else}
        {l s='Open B2B details' d='Modules.Cshopb2b.Admin'}
      {/if}
    </a>
  </div>
</div>
