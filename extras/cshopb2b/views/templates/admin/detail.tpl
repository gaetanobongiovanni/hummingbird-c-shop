{**
 * C-Shop B2B — one business customer: data, visura, approval
 *}
<div class="panel">
  <div class="panel-heading">
    <i class="icon-briefcase"></i> {$cs_row.company|escape:'html':'UTF-8'}
    <span class="badge{if $cs_row.status == 'pending'} badge-warning{elseif $cs_row.status == 'approved'} badge-success{elseif $cs_row.status == 'rejected'} badge-danger{/if}">
      {$cs_status_labels[$cs_row.status]|default:'-'|escape:'html':'UTF-8'}
    </span>
  </div>

  <div class="row">
    <div class="col-md-6">
      <dl class="dl-horizontal">
        <dt>{l s='Type' d='Modules.Cshopb2b.Admin'}</dt>
        <dd>{$cs_types[$cs_row.customer_type]|default:$cs_row.customer_type|escape:'html':'UTF-8'}</dd>
        {if $cs_row.legal_form}
          <dt>{l s='Legal form' d='Modules.Cshopb2b.Admin'}</dt>
          <dd>{$cs_forms[$cs_row.legal_form]|default:'-'|escape:'html':'UTF-8'}</dd>
        {/if}
        <dt>{l s='VAT number' d='Modules.Cshopb2b.Admin'}</dt>
        <dd>{$cs_row.vat_number|default:'-'|escape:'html':'UTF-8'}</dd>
        <dt>{l s='Tax code' d='Modules.Cshopb2b.Admin'}</dt>
        <dd>{$cs_row.tax_code|default:'-'|escape:'html':'UTF-8'}</dd>
        {if $cs_row.sdi_code}
          <dt>{l s='SDI code' d='Modules.Cshopb2b.Admin'}</dt>
          <dd>{$cs_row.sdi_code|escape:'html':'UTF-8'}</dd>
        {/if}
        {if $cs_row.ipa_code}
          <dt>{l s='IPA code' d='Modules.Cshopb2b.Admin'}</dt>
          <dd>{$cs_row.ipa_code|escape:'html':'UTF-8'}</dd>
        {/if}
        <dt>PEC</dt>
        <dd>{$cs_row.pec|default:'-'|escape:'html':'UTF-8'}</dd>
        <dt>{l s='Contact' d='Modules.Cshopb2b.Admin'}</dt>
        <dd>
          {$cs_customer->firstname|escape:'html':'UTF-8'} {$cs_customer->lastname|escape:'html':'UTF-8'} —
          <a href="mailto:{$cs_customer->email|escape:'html':'UTF-8'}">{$cs_customer->email|escape:'html':'UTF-8'}</a>
          <br><a href="{$cs_customer_link|escape:'html':'UTF-8'}">{l s='Open customer page' d='Modules.Cshopb2b.Admin'}</a>
        </dd>
        <dt>{l s='Registered on' d='Modules.Cshopb2b.Admin'}</dt>
        <dd>{dateFormat date=$cs_row.date_add full=1}</dd>
        {if $cs_row.note}
          <dt>{l s='Note' d='Modules.Cshopb2b.Admin'}</dt>
          <dd>{$cs_row.note|escape:'html':'UTF-8'|nl2br nofilter}</dd>
        {/if}
      </dl>
    </div>

    {if $cs_row.customer_type == 'rivenditore'}
      <div class="col-md-6">
        <h4>{l s='Chamber of commerce extract' d='Modules.Cshopb2b.Admin'}</h4>
        {if $cs_has_visura}
          <p>
            <a class="btn btn-default" target="_blank" rel="noopener" href="{$cs_self|escape:'html':'UTF-8'}&amp;action=download&amp;id_customer={$cs_row.id_customer|intval}">
              <i class="icon-file-text"></i> {$cs_row.visura_name|escape:'html':'UTF-8'}
            </a>
          </p>
        {else}
          <p class="alert alert-warning">{l s='No file uploaded: ask the customer to send it before approving.' d='Modules.Cshopb2b.Admin'}</p>
        {/if}

        <form method="post" action="{$cs_self|escape:'html':'UTF-8'}&amp;id_customer={$cs_row.id_customer|intval}">
          <div class="form-group">
            <label for="cshopb2b_note">{l s='Note (sent to the customer if you reject)' d='Modules.Cshopb2b.Admin'}</label>
            <textarea class="form-control" id="cshopb2b_note" name="cshopb2b_note" rows="3">{$cs_row.note|escape:'html':'UTF-8'}</textarea>
          </div>
          <button type="submit" name="cshopb2b_action" value="approve" class="btn btn-success"{if $cs_row.status == 'approved'} disabled{/if}>
            <i class="icon-check"></i> {l s='Approve: activate reseller prices' d='Modules.Cshopb2b.Admin'}
          </button>
          <button type="submit" name="cshopb2b_action" value="reject" class="btn btn-danger"{if $cs_row.status == 'rejected'} disabled{/if}>
            <i class="icon-remove"></i> {l s='Reject' d='Modules.Cshopb2b.Admin'}
          </button>
        </form>
      </div>
    {/if}
  </div>

  <div class="panel-footer">
    <a class="btn btn-default" href="{$cs_self|escape:'html':'UTF-8'}"><i class="process-icon-back"></i> {l s='Back to list' d='Modules.Cshopb2b.Admin'}</a>
  </div>
</div>
