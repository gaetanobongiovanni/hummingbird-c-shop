{**
 * C-Shop homepage — main brands (ps_brandlist widget variables).
 *}
{widget_block name='ps_brandlist'}
  {if !empty($brands)}
    <section class="cs-section cs-section--tight" aria-labelledby="cs-home-brands-title">
      <div class="container">
        <div class="cs-section__header">
          <h2 id="cs-home-brands-title" class="cs-section__title">{l s='Main brands' d='Shop.Theme.Cshop'}</h2>
          <a class="cs-section__link" href="{$page_link}">{l s='All brands' d='Shop.Theme.Cshop'}</a>
        </div>

        <ul class="cs-brand-strip">
          {foreach from=$brands item=brand name=cshopBrands}
            {if $smarty.foreach.cshopBrands.iteration <= 18}
              <li class="cs-brand-strip__item">
                <a class="cs-brand-strip__link" href="{$brand.link}">
                  {if $brand.image == $brand.id_manufacturer}
                    <img class="cs-brand-strip__logo" src="{$link->getManufacturerImageLink($brand.id_manufacturer, 'small_default')}" alt="{$brand.name}" width="98" height="98" loading="lazy" decoding="async">
                  {else}
                    <span class="cs-brand-strip__name">{$brand.name}</span>
                  {/if}
                </a>
              </li>
            {/if}
          {/foreach}
        </ul>
      </div>
    </section>
  {/if}
{/widget_block}
