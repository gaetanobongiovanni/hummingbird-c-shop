{**
 * For the full copyright and license information, please view the
 * LICENSE.md file that was distributed with this source code.
 *}

{* C-Shop: always-visible, full-width catalogue search (desktop + mobile).
   PrestaShop search indexes name, reference, supplier reference, EAN/UPC/MPN
   and brand: tune weights in Back Office > Shop Parameters > Search. *}
<div id="ps_searchbar" class="ps-searchbar cs-search js-search-widget" data-search-controller-url="{$search_controller_url}">
  <form class="ps-searchbar__form cs-search__form" method="get" action="{$search_controller_url}" role="search" aria-label="{l s='Search the catalog' d='Shop.Theme.Cshop'}">
    <input type="hidden" name="controller" value="search">
    <i class="material-icons ps-searchbar__magnifier cs-search__icon js-search-icon" aria-hidden="true">&#xE8B6;</i>
    <label for="ps_searchbar_input" class="visually-hidden">{l s='Search by product name, product code, supplier code, OEM code or brand' d='Shop.Theme.Cshop'}</label>
    <input
      class="js-search-input form-control ps-searchbar__input cs-search__input"
      type="search"
      name="s"
      value="{$search_string}"
      placeholder="{l s='Product, code, OEM code or brand…' d='Shop.Theme.Cshop'}"
      id="ps_searchbar_input"
      autocomplete="off"
      enterkeyhint="search"
      role="combobox"
      aria-haspopup="listbox"
      aria-autocomplete="list"
      aria-controls="ps_searchbar_results"
      aria-expanded="false"
      aria-describedby="ps_searchbar_hint"
    >
    <button type="button" class="ps-searchbar__clear cs-search__clear js-search-clear btn outline outline--rounded d-none" aria-label="{l s='Clear search' d='Shop.Theme.Catalog'}">
      <i class="material-icons" aria-hidden="true">&#xE14C;</i>
    </button>
    <button type="submit" class="btn btn-primary cs-search__submit">
      <i class="material-icons d-md-none" aria-hidden="true">&#xE8B6;</i>
      <span class="cs-search__submit-label">{l s='Search' d='Shop.Theme.Catalog'}</span>
    </button>
  </form>
  <p id="ps_searchbar_hint" class="visually-hidden">{l s='Search by product name, product code, supplier code, OEM code or brand' d='Shop.Theme.Cshop'}</p>

  <div
    class="ps-searchbar__dropdown cs-search__dropdown js-search-dropdown d-none"
    id="ps_searchbar_dropdown"
    aria-label="{l s='Search results' d='Shop.Theme.Catalog'}"
    tabindex="-1"
  >
    <div class="ps-searchbar__results js-search-results" id="ps_searchbar_results" role="listbox" tabindex="-1"></div>
  </div>
</div>

<template id="ps_searchbar_result" class="js-search-template">
  <a data-ps-ref="searchbar-result-link" class="ps-searchbar__result-link cs-search__result" id="" href="" role="option">
    <img src="" alt="" class="ps-searchbar__result-image" width="48" height="48" loading="lazy">
    <span class="cs-search__result-body">
      <p class="ps-searchbar__result-name"></p>
      <span class="cs-search__result-meta" data-ps-ref="searchbar-result-meta"></span>
    </span>
  </a>
</template>
