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

          {* Logo above, name below, like the Brands page.
             - Logo: the image ps_brandlist provides, else img/m/<id>-small_default.jpg
               (the id key is id_manufacturer: the old template used `id`, which is
               empty here, so every logo 404ed). A brand without a logo keeps an
               initial badge (the img removes itself on error).
             - Random: the 12 tiles below are the no-JS fallback; the full list is
               in the JSON next to them and src/js/cshop/brand-shuffle.ts draws 12
               random brands on every visit (works with page caches too). *}
          {$csBrandsJson = []}
          {foreach from=$brands item=brand}
            {$csBrandId = $brand.id_manufacturer|default:$brand.id|default:0}
            {if !empty($brand.image) && is_string($brand.image)}
              {$csBrandLogo = $brand.image}
            {else}
              {$csBrandLogo = "`$urls.base_url`img/m/`$csBrandId`-small_default.jpg"}
            {/if}
            {$csBrandsJson[] = ['n' => $brand.name, 'u' => $brand.link, 'i' => $csBrandLogo]}
          {/foreach}

          <div data-ps-component="cs-brand-shuffle" data-ps-count="12">
            <ul class="cs-brand-grid" data-ps-ref="cs-brand-grid">
              {foreach from=$csBrandsJson item=csBrand name=cshopBrands}
                {if $smarty.foreach.cshopBrands.iteration <= 12}
                  <li class="cs-brand-grid__item">
                    <a class="cs-brand-grid__link" href="{$csBrand.u}">
                      <span class="cs-brand-grid__logo" data-initial="{$csBrand.n|truncate:1:''|upper}">
                        <img src="{$csBrand.i}" alt="" width="98" height="98" loading="lazy" onerror="this.remove()">
                      </span>
                      <span class="cs-brand-grid__name">{$csBrand.n}</span>
                    </a>
                  </li>
                {/if}
              {/foreach}
            </ul>
            <script type="application/json" data-ps-ref="cs-brand-data">{$csBrandsJson|@json_encode nofilter}</script>
          </div>
        </div>
      </div>
    </section>
  {/if}
{/widget_block}
