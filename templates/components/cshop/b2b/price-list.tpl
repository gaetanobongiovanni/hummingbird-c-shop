{**
 * C-Shop B2B — customer price list table (UI only).
 * Params: $rows = [['reference','name','url','pack','min','price','customer_price'], …],
 *         $title (opt.), $download_url (opt., e.g. CSV export provided by the module)
 *}
{if !empty($rows)}
  <section class="cs-price-list" aria-labelledby="cs-price-list-title">
    <div class="cs-section__header">
      <h2 id="cs-price-list-title" class="cs-section__title">{$title|default:{l s='Your price list' d='Shop.Theme.Cshop'}}</h2>
      {if !empty($download_url)}
        <a class="btn btn-outline-primary btn-sm" href="{$download_url}" rel="nofollow">
          <i class="material-icons" aria-hidden="true">&#xE2C4;</i>{l s='Download' d='Shop.Theme.Actions'}
        </a>
      {/if}
    </div>
    <div class="cs-table-wrapper">
      <table class="cs-table cs-table--striped">
        <thead>
          <tr>
            <th scope="col">{l s='Code' d='Shop.Theme.Cshop'}</th>
            <th scope="col">{l s='Product' d='Shop.Theme.Catalog'}</th>
            <th scope="col">{l s='Pack' d='Shop.Theme.Cshop'}</th>
            <th scope="col" class="cs-table__num">{l s='Min.' d='Shop.Theme.Cshop'}</th>
            <th scope="col" class="cs-table__num">{l s='List price' d='Shop.Theme.Cshop'}</th>
            <th scope="col" class="cs-table__num">{l s='Your price' d='Shop.Theme.Cshop'}</th>
          </tr>
        </thead>
        <tbody>
          {foreach from=$rows item=csRow}
            <tr>
              <td class="cs-code">{$csRow.reference|default:''}</td>
              <th scope="row">{if !empty($csRow.url)}<a href="{$csRow.url}">{$csRow.name}</a>{else}{$csRow.name}{/if}</th>
              <td>{$csRow.pack|default:''}</td>
              <td class="cs-table__num">{$csRow.min|default:''}</td>
              <td class="cs-table__num">{$csRow.price|default:''}</td>
              <td class="cs-table__num"><strong>{$csRow.customer_price|default:''}</strong></td>
            </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </section>
{/if}
