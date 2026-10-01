{**
 * C-Shop B2B — business customers list (Customers > B2B requests)
 *}
<div class="panel">
  <div class="panel-heading">
    <i class="icon-briefcase"></i> {l s='Business customers' d='Modules.Cshopb2b.Admin'}
  </div>

  <ul class="nav nav-pills" style="margin-bottom:15px">
    {foreach from=$cs_statuses key=key item=label}
      <li{if $key == $cs_filter} class="active"{/if}>
        <a href="{$cs_self|escape:'html':'UTF-8'}&amp;status={$key|escape:'url'}">{$label|escape:'html':'UTF-8'}</a>
      </li>
    {/foreach}
  </ul>

  {if empty($cs_rows)}
    <p class="alert alert-info">{l s='No customers in this list.' d='Modules.Cshopb2b.Admin'}</p>
  {else}
    <div class="table-responsive">
      <table class="table">
        <thead>
          <tr>
            <th>{l s='Date' d='Modules.Cshopb2b.Admin'}</th>
            <th>{l s='Company name' d='Modules.Cshopb2b.Admin'}</th>
            <th>{l s='Type' d='Modules.Cshopb2b.Admin'}</th>
            <th>{l s='Legal form' d='Modules.Cshopb2b.Admin'}</th>
            <th>{l s='VAT number' d='Modules.Cshopb2b.Admin'}</th>
            <th>{l s='Contact' d='Modules.Cshopb2b.Admin'}</th>
            <th>{l s='Status' d='Modules.Cshopb2b.Admin'}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {foreach from=$cs_rows item=row}
            <tr>
              <td>{dateFormat date=$row.date_add full=0}</td>
              <td><strong>{$row.company|escape:'html':'UTF-8'}</strong></td>
              <td>{$cs_types[$row.customer_type]|default:$row.customer_type|escape:'html':'UTF-8'}</td>
              <td>{$cs_forms[$row.legal_form]|default:'-'|escape:'html':'UTF-8'}</td>
              <td>{$row.vat_number|default:'-'|escape:'html':'UTF-8'}</td>
              <td>{$row.firstname|escape:'html':'UTF-8'} {$row.lastname|escape:'html':'UTF-8'}<br><small>{$row.email|escape:'html':'UTF-8'}</small></td>
              <td>
                <span class="badge{if $row.status == 'pending'} badge-warning{elseif $row.status == 'approved'} badge-success{elseif $row.status == 'rejected'} badge-danger{/if}">
                  {$cs_status_labels[$row.status]|default:'-'|escape:'html':'UTF-8'}
                </span>
              </td>
              <td class="text-right">
                <a class="btn btn-default" href="{$cs_self|escape:'html':'UTF-8'}&amp;id_customer={$row.id_customer|intval}">
                  <i class="icon-search"></i> {l s='Open' d='Modules.Cshopb2b.Admin'}
                </a>
              </td>
            </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  {/if}
</div>
