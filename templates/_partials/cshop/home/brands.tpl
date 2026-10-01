{**
 * C-Shop homepage — main brands (ps_brandlist widget variables).
 *}
{widget_block name='ps_brandlist'}
  {if !empty($brands)}
    <section class="cs-section cs-section--tight" aria-labelledby="cs-home-brands-title">
      <div class="container">
        <div class="cs-panel">
          <div class="cs-section__header">
            <h2 id="cs-home-brands-title" class="cs-section__title">{l s='Main brands' d='Shop.Theme.Cshop'}</h2>
            <a class="cs-section__link" href="{$page_link}">{l s='All brands' d='Shop.Theme.Cshop'}</a>
          </div>

          <ul class="cs-brand-strip">
            {foreach from=$brands item=brand name=cshopBrands}
              {if $smarty.foreach.cshopBrands.iteration <= 12}
                <li class="cs-brand-strip__item">
                  {* Names only: logos imported from the supplier feed are inconsistent (empty or placeholder images) *}
                  <a class="cs-brand-strip__link" href="{$brand.link}">
                    <span class="cs-brand-strip__name">{$brand.name}</span>
                  </a>
                </li>
              {/if}
            {/foreach}
          </ul>
        </div>
      </div>
    </section>
  {/if}
{/widget_block}
