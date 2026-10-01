{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}
{extends file=$layout}

{block name='breadcrumb'}{/block}

{block name='content_columns'}
  {block name='left_column'}{/block}

  {block name='content_wrapper'}
    <div id="center-column" class="center-column page">
      {hook h="displayContentWrapperTop"}

      {block name='content'}
        {block name='page_content_container'}
          <div id="content" class="page-content page-content--home">
            {block name='page_content_top'}{/block}

            {block name='page_content'}
              {* C-Shop homepage: catalogue first — offers and best sellers right after the categories *}
              {block name='cshop_home_hero'}
                {include file='_partials/cshop/home/hero.tpl'}
              {/block}

              {block name='cshop_home_categories'}
                {include file='_partials/cshop/home/categories.tpl'}
              {/block}

              {block name='cshop_home_promotions'}
                {widget name='ps_specials'}
              {/block}

              {block name='cshop_home_bestsellers'}
                {widget name='ps_bestsellers'}
              {/block}

              {block name='cshop_home_available'}
                {widget name='ps_featuredproducts'}
              {/block}

              {block name='cshop_home_toner'}
                {include file='_partials/cshop/home/toner.tpl'}
              {/block}

              {block name='cshop_home_brands'}
                {include file='_partials/cshop/home/brands.tpl'}
              {/block}

              {block name='cshop_home_business'}
                {include file='_partials/cshop/home/business.tpl'}
              {/block}

              {block name='hook_home'}
                {* Merchant content: ps_customtext, ps_banner and any module on displayHome *}
                {if !empty($HOOK_HOME)}
                  <div class="container">
                    <div class="cs-home-hook">
                      {$HOOK_HOME nofilter}
                    </div>
                  </div>
                {/if}
              {/block}

              {block name='cshop_home_reorder'}
                {include file='_partials/cshop/home/reorder.tpl'}
              {/block}

              {block name='cshop_home_support'}
                {include file='_partials/cshop/home/support.tpl'}
              {/block}
            {/block}
          </div>
        {/block}
      {/block}

      {hook h="displayContentWrapperBottom"}
    </div>
  {/block}

  {block name='right_column'}{/block}
{/block}
