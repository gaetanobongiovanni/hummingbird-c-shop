{**
 * C-Shop B2B — previous orders with reorder action (UI only).
 * Params: $orders = [['reference','date','total','status','details_url','reorder_url'], …]
 * (the native order history page already exposes `reorder_url` per order).
 *}
{if !empty($orders)}
  <section class="cs-reorder-list" aria-labelledby="cs-reorder-list-title">
    <h2 id="cs-reorder-list-title" class="cs-section__title">{l s='Reorder from previous orders' d='Shop.Theme.Cshop'}</h2>
    <div class="cs-table-wrapper">
      <table class="cs-table cs-table--striped">
        <thead>
          <tr>
            <th scope="col">{l s='Order reference' d='Shop.Theme.Checkout'}</th>
            <th scope="col">{l s='Date' d='Shop.Theme.Checkout'}</th>
            <th scope="col" class="cs-table__num">{l s='Total price' d='Shop.Theme.Checkout'}</th>
            <th scope="col">{l s='Status' d='Shop.Theme.Checkout'}</th>
            <th scope="col"><span class="visually-hidden">{l s='Actions' d='Shop.Theme.Cshop'}</span></th>
          </tr>
        </thead>
        <tbody>
          {foreach from=$orders item=csOrder}
            <tr>
              <th scope="row">{if !empty($csOrder.details_url)}<a href="{$csOrder.details_url}">{$csOrder.reference}</a>{else}{$csOrder.reference}{/if}</th>
              <td>{$csOrder.date|default:''}</td>
              <td class="cs-table__num">{$csOrder.total|default:''}</td>
              <td>{$csOrder.status|default:''}</td>
              <td>
                {if !empty($csOrder.reorder_url)}
                  <a class="btn btn-outline-primary btn-sm" href="{$csOrder.reorder_url}" rel="nofollow">{l s='Reorder' d='Shop.Theme.Actions'}</a>
                {/if}
              </td>
            </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </section>
{/if}
