{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}

{$headerBanner = 'header-banner'}
{$headerTop = 'header-top'}
{$headerBottom = 'header-bottom'}
{$headerNavFullWidth = 'header-nav-full-width'}

{capture name="header_banner"}{hook h='displayBanner'}{/capture}
{block name='header_banner'}
  {if !empty($smarty.capture.header_banner)}
    <div class="{$headerBanner}">
      {$smarty.capture.header_banner nofilter}
    </div>
  {/if}
{/block}

{capture name="header_nav_1"}{hook h='displayNav1'}{/capture}
{capture name="header_nav_2"}{hook h='displayNav2'}{/capture}
{block name='header_nav'}
  {* C-Shop: information bar *}
  {include file='_partials/cshop/header-info-bar.tpl'
    header_nav_1=$smarty.capture.header_nav_1
    header_nav_2=$smarty.capture.header_nav_2
  }
{/block}

{block name='header_bottom'}
  {* C-Shop: logo, search, account actions and mega-menu *}
  {include file='_partials/cshop/header-main.tpl'}

  {capture name="nav_full_width"}{hook h='displayNavFullWidth'}{/capture}
  {if !empty($smarty.capture.nav_full_width)}
    <div class="{$headerNavFullWidth}">
      {$smarty.capture.nav_full_width nofilter}
    </div>
  {/if}
{/block}
