{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{* C-Shop: the shop's own copyright line instead of the PrestaShop credit.
   Company name and VAT number come from Shop parameters › Contact
   (shop name / registration number), so nothing is hard-coded. *}
{block name='copyright'}
  <div class="copyright cs-copyright">
    {block name='copyright_link'}
      <p class="cs-copyright__text">
        &copy; {'Y'|date} {$shop.name}
        {if !empty($shop.registration_number)}
          <span class="cs-copyright__sep" aria-hidden="true">·</span>
          {l s='VAT number %vat%' sprintf=['%vat%' => $shop.registration_number] d='Shop.Theme.Cshop'}
        {/if}
        <span class="cs-copyright__sep" aria-hidden="true">·</span>
        {l s='All rights reserved' d='Shop.Theme.Cshop'}
      </p>
    {/block}
  </div>
{/block}
