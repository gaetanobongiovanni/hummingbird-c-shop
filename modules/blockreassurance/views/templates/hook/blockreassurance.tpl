{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{* C-Shop: compact, accessible reassurance list (information bar, homepage support).
   Real links instead of the module's onclick handler. *}
{if $elements}
  <ul class="cs-reassurance">
    {foreach from=$elements item=element}
      <li class="cs-reassurance__item">
        {if $element['type_link'] !== $LINK_TYPE_NONE && !empty($element['link'])}
          <a class="cs-reassurance__link" href="{$element['link']|escape:'htmlall':'UTF-8'}">
        {else}
          <span class="cs-reassurance__link">
        {/if}
          {if $element.image}
            <img class="cs-reassurance__icon" src="{$element.image}" alt="" width="24" height="24" loading="lazy">
          {/if}
          <span class="cs-reassurance__text">
            <span class="cs-reassurance__title">{$element.title|escape:'htmlall':'UTF-8'}</span>
            {if !empty($element.description)}
              <span class="cs-reassurance__desc">{$element.description|strip_tags|escape:'htmlall':'UTF-8'}</span>
            {/if}
          </span>
        {if $element['type_link'] !== $LINK_TYPE_NONE && !empty($element['link'])}
          </a>
        {else}
          </span>
        {/if}
      </li>
    {/foreach}
  </ul>
{/if}
