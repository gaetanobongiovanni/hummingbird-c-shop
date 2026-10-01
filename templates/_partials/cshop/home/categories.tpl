{**
 * C-Shop homepage — department tiles with an icon (proposal A).
 * Data: ps_mainmenu widget variables (Back Office > Modules > Main menu).
 * Each tile shows the category thumbnail; the icon (picked from the label)
 * is the fallback when the category has no image. Nothing else is hard-coded.
 *}
{widget_block name='ps_mainmenu'}
  {if !empty($children)}
    {$cshopIcons = [ 'toner' => 'print', 'cartucce' => 'print', 'carta' => 'description', 'quadern' => 'menu_book', 'blocchi' => 'menu_book', 'scrittura' => 'edit', 'cancelleria' => 'content_cut', 'archivio' => 'folder', 'spedizione' => 'local_shipping', 'imballo' => 'inventory_2', 'informatica' => 'computer', 'macchine' => 'calculate', 'igiene' => 'cleaning_services', 'pulizia' => 'cleaning_services', 'arredamento' => 'chair', 'disegno' => 'palette', 'didattica' => 'school', 'comunicazione' => 'campaign', 'organizzazione' => 'inventory_2', 'servizi' => 'room_service', 'promotional' => 'redeem' ]}
    <section class="cs-section cs-section--tight cs-departments" aria-labelledby="cs-home-categories-title">
      <div class="container">
        <div class="cs-section__header">
          <h2 id="cs-home-categories-title" class="cs-section__title">{l s='Shop by category' d='Shop.Theme.Cshop'}</h2>
        </div>

        <ul class="cs-departments__list">
          {foreach from=$children item=node}
            {$cshopIcon = 'category'}
            {foreach from=$cshopIcons key=cshopKey item=cshopName}
              {if $node.label|lower|strpos:$cshopKey !== false}{$cshopIcon = $cshopName}{break}{/if}
            {/foreach}
            <li class="cs-departments__item">
              <a class="cs-departments__link" href="{$node.url}">
                <span class="cs-departments__icon" aria-hidden="true">
                  {* category thumbnail first (Catalog > Categories > Thumbnail), then the
                     menu thumbnail; the icon shows when neither image exists *}
                  {if $node.type == 'category'}
                    <img src="{$urls.base_url}img/c/{$node.page_identifier|replace:'category-':''}_thumb-category_default.jpg" alt="" width="96" height="96" loading="lazy" decoding="async" onerror="this.remove()">
                  {elseif !empty($node.image_urls)}
                    <img src="{$node.image_urls[0]}" alt="" width="96" height="96" loading="lazy" decoding="async" onerror="this.remove()">
                  {/if}
                  <span class="material-icons">{$cshopIcon}</span>
                </span>
                <span class="cs-departments__name">{$node.label}</span>
              </a>
            </li>
          {/foreach}
        </ul>
      </div>
    </section>
  {/if}
{/widget_block}
