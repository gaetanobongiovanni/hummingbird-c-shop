{**
 * C-Shop homepage — "Mercato" hero (proposal A, October 2026).
 * Left: banner with the shop promise and a call to action to the price drops.
 * Right: account card (sign in / welcome back) and toner finder shortcut.
 * Copy is translatable (Shop.Theme.Cshop); links are real shop URLs.
 *}
<section class="cs-hero cs-hero--market" aria-labelledby="cs-hero-title">
  <div class="container cs-hero__inner">
    <div class="cs-hero__banner">
      <span class="cs-hero__eyebrow">{l s='Office, school and business supplies' d='Shop.Theme.Cshop'}</span>
      <h2 id="cs-hero-title" class="cs-hero__title">{l s='Everything for your desk, from scissors to toner' d='Shop.Theme.Cshop'}</h2>
      <p class="cs-hero__lead">{l s='Search the catalogue by product name, product code, supplier code, OEM code or brand.' d='Shop.Theme.Cshop'}</p>
      <div class="cs-hero__cta">
        <a class="btn btn-light btn-lg cs-hero__cta-main" href="{$urls.pages.prices_drop}">{l s='See the offers' d='Shop.Theme.Cshop'}</a>
        <a class="cs-hero__cta-link" href="{$urls.pages.new_products}">{l s='New products' d='Shop.Theme.Cshop'}</a>
        <a class="cs-hero__cta-link" href="{$link->getPageLink('best-sales')}">{l s='Best sellers' d='Shop.Theme.Catalog'}</a>
      </div>
      <span class="cs-hero__art" aria-hidden="true">
        <span class="material-icons">edit</span>
        <span class="material-icons">content_cut</span>
        <span class="material-icons">print</span>
        <span class="material-icons">description</span>
      </span>
    </div>

    <div class="cs-hero__side">
      <div class="cs-hero__account">
        {if $customer.is_logged}
          <p class="cs-hero__side-title">{l s='Welcome back, %name%' sprintf=['%name%' => $customer.firstname] d='Shop.Theme.Cshop'}</p>
          <p class="cs-hero__side-text">{l s='Reorder in a few clicks from your previous orders.' d='Shop.Theme.Cshop'}</p>
          <div class="cs-hero__side-actions">
            {if !$configuration.is_catalog}
              <a class="btn btn-accent" href="{$urls.pages.history}">{l s='My orders' d='Shop.Theme.Cshop'}</a>
            {/if}
            <a class="cs-hero__side-link" href="{$urls.pages.my_account}">{l s='Your account' d='Shop.Theme.Customeraccount'}</a>
          </div>
        {else}
          <p class="cs-hero__side-title">{l s='Sign in for a better experience' d='Shop.Theme.Cshop'}</p>
          <p class="cs-hero__side-text">{l s='Reorder from your history, download invoices, save your addresses.' d='Shop.Theme.Cshop'}</p>
          <div class="cs-hero__side-actions">
            <a class="btn btn-accent" href="{$urls.pages.authentication}" rel="nofollow">{l s='Sign in' d='Shop.Theme.Actions'}</a>
            <a class="cs-hero__side-link" href="{$urls.pages.register}" rel="nofollow">{l s='New customer? Create an account' d='Shop.Theme.Cshop'}</a>
          </div>
        {/if}
      </div>

      <a class="cs-hero__toner" href="#cs-home-toner-title">
        <span class="cs-hero__toner-title">{l s='Looking for toner?' d='Shop.Theme.Cshop'}</span>
        <span class="cs-hero__toner-text">{l s='Type your printer model or the original code.' d='Shop.Theme.Cshop'}</span>
        <span class="cs-hero__toner-link">{l s='Find cartridges' d='Shop.Theme.Cshop'} &rarr;</span>
      </a>
    </div>
  </div>
</section>
