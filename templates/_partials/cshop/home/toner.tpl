{**
 * C-Shop homepage — toner & cartridges finder.
 * Submits to the native search controller (indexes references, OEM/MPN codes,
 * brand and name): search by printer model or original cartridge code.
 * The category link is taken from the main menu tree when a top-level item's
 * label contains "toner" (no hard-coded category ID).
 *}
<section class="cs-section cs-section--alt" aria-labelledby="cs-home-toner-title">
  <div class="container">
    <div class="cs-toner cs-panel">
      <div class="cs-toner__intro">
        <h2 id="cs-home-toner-title" class="cs-section__title">{l s='Toner and cartridges' d='Shop.Theme.Cshop'}</h2>
        <p class="cs-section__subtitle">{l s='Enter your printer model or the original cartridge code (OEM) to find compatible products.' d='Shop.Theme.Cshop'}</p>
      </div>

      <form class="cs-toner__form" method="get" action="{$urls.pages.search}" role="search" aria-labelledby="cs-home-toner-title">
        <input type="hidden" name="controller" value="search">
        <label class="form-label" for="cs-toner-query">{l s='Printer model or cartridge code' d='Shop.Theme.Cshop'}</label>
        <div class="cs-toner__field">
          <input class="form-control form-control-lg" type="search" id="cs-toner-query" name="s" required minlength="2" autocomplete="off" enterkeyhint="search">
          <button class="btn btn-accent btn-lg" type="submit">{l s='Find cartridges' d='Shop.Theme.Cshop'}</button>
        </div>

        {widget_block name='ps_mainmenu'}
          {foreach from=$children item=node}
            {if $node.label|lower|strpos:'toner' !== false}
              <a class="cs-toner__category" href="{$node.url}">
                {l s='Browse all: %category%' sprintf=['%category%' => $node.label] d='Shop.Theme.Cshop'}
                <i class="material-icons rtl-flip" aria-hidden="true">&#xE315;</i>
              </a>
              {break}
            {/if}
          {/foreach}
        {/widget_block}
      </form>
    </div>
  </div>
</section>
