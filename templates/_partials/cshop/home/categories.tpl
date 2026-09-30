{**
 * C-Shop homepage — quick access to main categories.
 * Data: ps_mainmenu widget variables (same tree as the mega-menu, configured in
 * Back Office > Modules > Main menu). Nothing is hard-coded.
 *}
{widget_block name='ps_mainmenu'}
  {if !empty($children)}
    <section class="cs-section cs-section--tight" aria-labelledby="cs-home-categories-title">
      <div class="container">
        <div class="cs-section__header">
          <h2 id="cs-home-categories-title" class="cs-section__title">{l s='Shop by category' d='Shop.Theme.Cshop'}</h2>
        </div>

        <ul class="cs-category-tiles">
          {foreach from=$children item=node}
            <li class="cs-category-tiles__item">
              <div class="cs-category-tile cs-card cs-card--interactive">
                {if !empty($node.image_urls)}
                  <img class="cs-category-tile__image" src="{$node.image_urls[0]}" alt="" width="48" height="48" loading="lazy" decoding="async">
                {/if}
                <a class="cs-category-tile__title stretched-link" href="{$node.url}">{$node.label}</a>
                {if $node.children|count}
                  <ul class="cs-category-tile__children">
                    {foreach from=$node.children item=child name=cshopChildren}
                      {if $smarty.foreach.cshopChildren.iteration <= 4}
                        <li><a class="cs-category-tile__child" href="{$child.url}">{$child.label}</a></li>
                      {/if}
                    {/foreach}
                  </ul>
                {/if}
              </div>
            </li>
          {/foreach}
        </ul>
      </div>
    </section>
  {/if}
{/widget_block}
