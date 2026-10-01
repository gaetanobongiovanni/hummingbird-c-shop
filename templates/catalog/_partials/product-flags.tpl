{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{* C-Shop: the "On sale!" flag (product option set by the supplier feed) is
   shown only when the product really has a price reduction. Without one the
   badge promised a discount the customer could not see, and the product did
   not appear on the Price drops page (which lists real reductions only). *}
{if !empty($product.flags)}
  {block name='product_flags'}
    <ul class="product-flags js-product-flags">
      {foreach from=$product.flags item=flag}
        {if $flag.type == 'on-sale' && empty($product.has_discount)}{continue}{/if}
        <li class="badge {$flag.type}">{$flag.label nofilter}</li>
      {/foreach}
    </ul>
  {/block}
{/if}
