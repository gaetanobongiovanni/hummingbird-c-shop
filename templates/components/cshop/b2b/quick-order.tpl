{**
 * C-Shop B2B — quick order by product code (UI only).
 * Params (from the quick-order module):
 *   $action_url (string, required)  form target handled by the module
 *   $token      (string, required)  CSRF / static token expected by the module
 *   $rows       (int, optional)     initial empty rows, default 5
 *   $title      (string, optional)
 * Posts `items[n][code]` and `items[n][qty]`; the module resolves codes
 * (reference / supplier code / OEM / EAN) and adds products to the cart.
 *}
{if !empty($action_url) && !empty($token)}
  {$csRows = $rows|default:5}
  <form class="cs-quick-order cs-card" method="post" action="{$action_url}" data-ps-component="cs-quick-order" aria-labelledby="cs-quick-order-title">
    <input type="hidden" name="token" value="{$token}">
    <h2 id="cs-quick-order-title" class="cs-card__title">{$title|default:{l s='Quick order by product code' d='Shop.Theme.Cshop'}}</h2>
    <p class="cs-card__text">{l s='Enter a product code, supplier code or OEM code and the quantity.' d='Shop.Theme.Cshop'}</p>

    <div class="cs-table-wrapper">
      <table class="cs-table cs-quick-order__table">
        <thead>
          <tr>
            <th scope="col">{l s='Product code' d='Shop.Theme.Cshop'}</th>
            <th scope="col" class="cs-table__num">{l s='Quantity' d='Shop.Theme.Catalog'}</th>
            <th scope="col"><span class="visually-hidden">{l s='Actions' d='Shop.Theme.Cshop'}</span></th>
          </tr>
        </thead>
        <tbody data-ps-target="cs-quick-order-rows">
          {for $csIndex=0 to $csRows - 1}
            <tr data-ps-ref="cs-quick-order-row">
              <td>
                <label class="visually-hidden" for="cs-qo-code-{$csIndex}">{l s='Product code, row %row%' sprintf=['%row%' => $csIndex + 1] d='Shop.Theme.Cshop'}</label>
                <input class="form-control form-control-sm cs-code" id="cs-qo-code-{$csIndex}" name="items[{$csIndex}][code]" type="text" autocomplete="off" spellcheck="false">
              </td>
              <td class="cs-table__num">
                <label class="visually-hidden" for="cs-qo-qty-{$csIndex}">{l s='Quantity, row %row%' sprintf=['%row%' => $csIndex + 1] d='Shop.Theme.Cshop'}</label>
                <input class="form-control form-control-sm cs-quick-order__qty" id="cs-qo-qty-{$csIndex}" name="items[{$csIndex}][qty]" type="number" min="1" step="1" inputmode="numeric" value="1">
              </td>
              <td>
                <button type="button" class="btn btn-ghost btn-sm" data-ps-action="cs-quick-order-remove-row" aria-label="{l s='Remove row %row%' sprintf=['%row%' => $csIndex + 1] d='Shop.Theme.Cshop'}">
                  <i class="material-icons" aria-hidden="true">&#xE872;</i>
                </button>
              </td>
            </tr>
          {/for}
        </tbody>
      </table>
    </div>

    <template data-ps-template="cs-quick-order-row">
      <tr data-ps-ref="cs-quick-order-row">
        <td>
          <label class="visually-hidden" for="cs-qo-code-__INDEX__">{l s='Product code, row %row%' sprintf=['%row%' => '__ROW__'] d='Shop.Theme.Cshop'}</label>
          <input class="form-control form-control-sm cs-code" id="cs-qo-code-__INDEX__" name="items[__INDEX__][code]" type="text" autocomplete="off" spellcheck="false">
        </td>
        <td class="cs-table__num">
          <label class="visually-hidden" for="cs-qo-qty-__INDEX__">{l s='Quantity, row %row%' sprintf=['%row%' => '__ROW__'] d='Shop.Theme.Cshop'}</label>
          <input class="form-control form-control-sm cs-quick-order__qty" id="cs-qo-qty-__INDEX__" name="items[__INDEX__][qty]" type="number" min="1" step="1" inputmode="numeric" value="1">
        </td>
        <td>
          <button type="button" class="btn btn-ghost btn-sm" data-ps-action="cs-quick-order-remove-row" aria-label="{l s='Remove row %row%' sprintf=['%row%' => '__ROW__'] d='Shop.Theme.Cshop'}">
            <i class="material-icons" aria-hidden="true">&#xE872;</i>
          </button>
        </td>
      </tr>
    </template>

    <details class="cs-quick-order__paste">
      <summary>{l s='Paste a list of codes' d='Shop.Theme.Cshop'}</summary>
      <label class="form-label" for="cs-qo-paste">{l s='One product per line: code and quantity separated by space, tab or semicolon.' d='Shop.Theme.Cshop'}</label>
      <textarea class="form-control cs-code" id="cs-qo-paste" rows="4" data-ps-ref="cs-quick-order-paste"></textarea>
      <button type="button" class="btn btn-outline-primary btn-sm" data-ps-action="cs-quick-order-apply-paste">{l s='Fill the rows' d='Shop.Theme.Cshop'}</button>
    </details>

    <div class="cs-quick-order__actions">
      <button type="button" class="btn btn-ghost" data-ps-action="cs-quick-order-add-row">
        <i class="material-icons" aria-hidden="true">&#xE145;</i>{l s='Add row' d='Shop.Theme.Cshop'}
      </button>
      <button type="submit" class="btn btn-accent">{l s='Add to cart' d='Shop.Theme.Actions'}</button>
    </div>
  </form>
{/if}
