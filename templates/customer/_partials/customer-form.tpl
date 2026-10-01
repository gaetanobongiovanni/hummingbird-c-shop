{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{block name='customer_form'}
  {block name='customer_form_errors'}
    {include file='_partials/form-errors.tpl' errors=$errors['']}
  {/block}

{* C-Shop: the cshopb2b module adds the customer type and business fields
   (names cs_*). They are shown first, as their own block; which ones are
   visible/required depends on the chosen type (data-ps-b2b-* attributes,
   src/js/cshop/b2b-registration.ts). multipart: resellers upload a file. *}
{$csB2bFields = []}
{foreach from=$formFields item="field"}
  {if isset($field.attr['data-ps-b2b-show'])}{$csB2bFields[] = $field}{/if}
{/foreach}

<form
  action="{block name='customer_form_actionurl'}{$action}{/block}"
  class="js-customer-form"
  id="customer-form"
  method="post"
  {if $csB2bFields}enctype="multipart/form-data"{/if}
  data-ps-action="form-validation"
  aria-label="{l s='Your personal information' d='Shop.Theme.Customeraccount'}"
>
  {if $csB2bFields}
    <section class="cs-b2b" data-ps-component="cs-b2b-registration">
      {foreach from=$csB2bFields item="field"}
        {if $field.name === 'cs_customer_type'}
          <div class="cs-b2b__type" data-ps-ref="cs-b2b-field" data-ps-b2b-show="always" data-ps-b2b-required="always">
            {form_field field=$field}
          </div>
          <fieldset class="cs-b2b__business" data-ps-ref="cs-b2b-business">
            <legend class="cs-b2b__legend">{l s='Business details' d='Shop.Theme.Cshop'}</legend>
        {else}
          <div
            class="cs-b2b__field cs-b2b__field--{$field.name}"
            data-ps-ref="cs-b2b-field"
            data-ps-b2b-show="{$field.attr['data-ps-b2b-show']|default:''}"
            data-ps-b2b-required="{$field.attr['data-ps-b2b-required']|default:''}"
          >
            {form_field field=$field}
          </div>
        {/if}
      {/foreach}
          </fieldset>
    </section>
  {/if}

  <section>
    {block "form_fields"}
      {foreach from=$formFields item="field"}
        {if isset($field.attr['data-ps-b2b-show'])}{continue}{/if}
        {block "form_field"}
          {if $field.name === "new_password" && $page.page_name == "identity"}
            <div data-ps-ref="password-field">
              {form_field field=$field}
            </div>
          {elseif $field.type === "password" && $page.page_name != "identity"}
            <div data-ps-ref="password-field">
              {form_field field=$field}
            </div>
          {else}
            {form_field field=$field}
          {/if}
        {/block}
      {/foreach}
      {$hook_create_account_form nofilter}
    {/block}
  </section>

  {block name='customer_form_footer'}
    <input type="hidden" name="submitCreate" value="1">

    <footer class="buttons-wrapper buttons-wrapper--end">
      {block "form_buttons"}
        <button class="btn btn-primary form-control-submit" data-link-action="save-customer" type="submit" data-ps-action="form-validation-submit">
        {if isset($mode) && $mode === "register"}
          {l s='Create account' d='Shop.Theme.Actions'}
        {else}
          {l s='Save' d='Shop.Theme.Actions'}
        {/if}
        </button>
      {/block}
    </footer>
  {/block}
</form>
{/block}
