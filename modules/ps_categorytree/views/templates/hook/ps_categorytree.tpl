{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}

{$componentName = 'category-tree'}

{* C-Shop: only the branch of the current category is rendered (with 500+
   categories the full tree was ~160KB of HTML on every listing page).
   Other nodes are plain links; the current path is open. *}
{function name="categories" nodes=[] depth=0}
  {strip}
    {if $nodes|count}
      <ul class="{$componentName}__list" data-depth="{$depth|escape:'htmlall':'UTF-8'}">
        {foreach from=$nodes item=node name="categories"}
          {$csOpen = !empty($node.in_path) && !empty($node.children)}
          <li class="{$componentName}__item{if $csOpen} accordion-item{/if}{if !empty($node.in_path)} {$componentName}__item--in-path{/if}">
            <div class="{$componentName}__item-header nosplit{if $csOpen} split parent{/if}">
              <a class="{$componentName}__item-link" href="{$node.link|escape:'htmlall':'UTF-8'}"{if !empty($node.in_path) && empty($node.children)} aria-current="page"{/if}>
                {$node.name|escape:'htmlall':'UTF-8'}
              </a>

              {if $csOpen}
                <button
                  class="accordion-button"
                  type="button"
                  data-bs-toggle="collapse"
                  data-bs-target="#category-tree-{$node.id|escape:'htmlall':'UTF-8'}"
                  aria-expanded="true"
                  aria-controls="category-tree-{$node.id|escape:'htmlall':'UTF-8'}"
                  aria-label="{l s='Subcategories for %s' sprintf=[$node.name] d='Shop.Theme.Catalog'}"
                >
                </button>
              {/if}
            </div>

            {if $csOpen}
              <div class="accordion-collapse collapse show" id="category-tree-{$node.id|escape:'htmlall':'UTF-8'}">
                <div class="accordion-body">
                  {categories nodes=$node.children depth=$depth+1}
                </div>
              </div>
            {/if}
          </li>
        {/foreach}
      </ul>
    {/if}
  {/strip}
{/function}

{if !empty($categories.children)}
  {* C-Shop: collapsible block (closed by default), same mechanism as the
     brands block below it: the filters stay at the top of the column *}
  <div class="ps-categorytree {$componentName} left-block cs-collapsible">
    <h2 class="left-block__title h3">
      <button
        class="cs-collapsible__toggle collapsed"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#cs-left-categories"
        aria-expanded="false"
        aria-controls="cs-left-categories"
      >
        {l s='Categories' d='Shop.Theme.Catalog'}
      </button>
    </h2>

    <div id="cs-left-categories" class="collapse cs-collapsible__body">
      <div class="accordion accordion-flush accordion--category">
        <nav aria-label="{l s='Categories' d='Shop.Theme.Catalog'}">
          <div class="{$componentName}__child">
            {categories nodes=$categories.children}
          </div>
        </nav>
      </div>
    </div>
  </div>
{/if}
