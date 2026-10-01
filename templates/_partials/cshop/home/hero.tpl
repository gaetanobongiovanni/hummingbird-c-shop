{**
 * C-Shop homepage — compact hero.
 * Only real shop URLs; copy is translatable (Shop.Theme.Cshop domain in BO).
 *}
<section class="cs-hero" aria-labelledby="cs-hero-title">
  <div class="container cs-hero__inner">
    <div class="cs-hero__text">
      <h2 id="cs-hero-title" class="cs-hero__title">{l s='Office, school and business supplies' d='Shop.Theme.Cshop'}</h2>
      <p class="cs-hero__lead">{l s='Search the catalogue by product name, product code, supplier code, OEM code or brand.' d='Shop.Theme.Cshop'}</p>

      <ul class="cs-hero__links">
        <li><a class="cs-hero__link" href="{$urls.pages.new_products}">{l s='New products' d='Shop.Theme.Cshop'}</a></li>
        <li><a class="cs-hero__link" href="{$link->getPageLink('best-sales')}">{l s='Best sellers' d='Shop.Theme.Catalog'}</a></li>
        <li><a class="cs-hero__link" href="{$urls.pages.prices_drop}">{l s='Price drops' d='Shop.Theme.Cshop'}</a></li>
        <li><a class="cs-hero__link" href="{$urls.pages.manufacturer}">{l s='Brands' d='Shop.Theme.Catalog'}</a></li>
      </ul>
    </div>

    <div class="cs-hero__account cs-card">
      {if $customer.is_logged}
        <p class="cs-card__title">{l s='Welcome back, %name%' sprintf=['%name%' => $customer.firstname] d='Shop.Theme.Cshop'}</p>
        <p class="cs-card__text">{l s='Reorder in a few clicks from your previous orders.' d='Shop.Theme.Cshop'}</p>
        <div class="cs-hero__actions">
          {if !$configuration.is_catalog}
            <a class="btn btn-primary" href="{$urls.pages.history}">{l s='My orders' d='Shop.Theme.Cshop'}</a>
          {/if}
          <a class="btn btn-outline-primary" href="{$urls.pages.my_account}">{l s='Your account' d='Shop.Theme.Customeraccount'}</a>
        </div>
      {else}
        <p class="cs-card__title">{l s='Private customers and businesses' d='Shop.Theme.Cshop'}</p>
        <p class="cs-card__text">{l s='Sign in to reorder from your order history and track your deliveries.' d='Shop.Theme.Cshop'}</p>
        <div class="cs-hero__actions">
          <a class="btn btn-primary" href="{$urls.pages.authentication}" rel="nofollow">{l s='Sign in' d='Shop.Theme.Actions'}</a>
          <a class="btn btn-outline-primary" href="{$urls.pages.register}" rel="nofollow">{l s='Create an account' d='Shop.Theme.Customeraccount'}</a>
        </div>
      {/if}
    </div>
  </div>
</section>
