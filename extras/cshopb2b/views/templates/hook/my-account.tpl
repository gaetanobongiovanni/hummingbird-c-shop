{**
 * C-Shop B2B — business account status in "My account"
 *}
<div class="cs-b2b-status{if $cs_b2b.status == 'pending'} cs-b2b-status--pending{/if}" role="status">
  <i class="material-icons" aria-hidden="true">&#xE0AF;</i>
  <div>
    <strong>{$cs_b2b.company}</strong>
    <span>
      {if $cs_b2b.customer_type == 'rivenditore'}
        {if $cs_b2b.status == 'approved'}
          {l s='Reseller account: reseller prices active.' d='Modules.Cshopb2b.Shop'}
        {elseif $cs_b2b.status == 'pending'}
          {l s='Reseller request under review: we will email you as soon as reseller prices are active. Meanwhile you can order at list price.' d='Modules.Cshopb2b.Shop'}
        {else}
          {l s='Business account.' d='Modules.Cshopb2b.Shop'}
        {/if}
      {elseif $cs_b2b.customer_type == 'ente'}
        {l s='Public body account.' d='Modules.Cshopb2b.Shop'}
      {else}
        {l s='Business account.' d='Modules.Cshopb2b.Shop'}
      {/if}
    </span>
  </div>
</div>
