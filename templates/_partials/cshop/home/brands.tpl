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

          {* Logo above, name below, like the Brands page. The widget only gives
             id/name/link, so the logo is the manufacturer image by id; a brand
             without a logo keeps an initial badge (the img removes itself). *}
          <ul class="cs-brand-grid">
            {foreach from=$brands item=brand name=cshopBrands}
              {if $smarty.foreach.cshopBrands.iteration <= 12}
                <li class="cs-brand-grid__item">
                  <a class="cs-brand-grid__link" href="{$brand.link}">
                    <span class="cs-brand-grid__logo" data-initial="{$brand.name|truncate:1:''|upper}">
                      <img
                        src="{$urls.img_manu_url}{$brand.id}-small_default.jpg"
                        alt=""
                        width="98"
                        height="98"
                        loading="lazy"
                        onerror="this.remove()"
                      >
                    </span>
                    <span class="cs-brand-grid__name">{$brand.name}</span>
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
