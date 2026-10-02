# C-Shop theme for PrestaShop 9.2

Catalogue-first theme for **C-Shop** (office, school and business supplies,
≈20,000 products imported from EDI), serving both private customers and
businesses. It is a fork of **Hummingbird 2.1.2** (`PrestaShop/hummingbird`,
tag `v2.1.2`, the theme bundled with PrestaShop 9.2.0), kept close to upstream
so it can be updated with `git merge`.

| | |
|---|---|
| Theme name (folder) | `cshop` |
| PrestaShop | 9.2.x (`compatibility: 9.2.0 → ~9.2.0`) |
| Base | Hummingbird 2.1.2 — Bootstrap 5.3, SCSS + `@layer`, TypeScript, no jQuery |
| Branch | `c-shop-9.2` |

## Build and package

```bash
nvm use            # Node 24 (see .nvmrc); Node 22 also builds
npm ci
npm run build      # production CSS/JS in assets/
npm test           # Jest
npm run lint && npm run stylelint && npm run prettier
npm run zip        # dist/cshop-<version>.zip, installable from Back Office
# or: npm run build:zip
```

The ZIP contains only runtime files (`assets`, `config`, `modules`, `plugins`,
`templates`, `translations`, `preview.png`), without sources or source maps.
PrestaShop refuses a theme without `assets/css/theme.css` and
`assets/js/theme.js`, so always build before packaging. Install it from
**Design › Theme & Logo › Add new theme**, then **Use this theme**. On an
already configured shop, choose to keep the current module positions only if
you know them; otherwise let the theme apply its hooks (see `config/theme.yml`).

No core file and no module file is modified: everything is done through theme
templates, theme module-template overrides (`modules/`), hooks and widgets.
Production caching (Smarty cache, CCC) can stay enabled.

## Updating the theme on the live shop

The Back Office upload refuses a theme folder that already exists, so a ZIP
can only be used for the first install. Afterwards update in place over SSH:

```bash
CSHOP_SSH=user@host CSHOP_ROOT=/path/to/prestashop npm run deploy
# preview without copying: CSHOP_DRY_RUN=1 … npm run deploy
```

`scripts/deploy-theme.sh` builds, rsyncs the runtime folders into
`themes/cshop` (keeping the shop's `assets/cache`), then clears PrestaShop's
cache. Module positions and settings are untouched. Changes to hook
assignments in `config/theme.yml` still need a theme reinstall (or the
positions set by hand in Design › Positions).

## Where the C-Shop code lives

Upstream files are touched only where there is no other way, always inside
existing `{block}`s and marked with a `C-Shop` comment. New code is isolated:

| Area | Path |
|---|---|
| Design tokens (colours, spacing, radii, shadows, type) | `src/scss/abstract/variables/_cshop.scss` |
| Bootstrap mapping of the tokens | `src/scss/bootstrap/overrides/variables/_variables.scss` (+ `components/`) |
| C-Shop styles (own CSS layer `cshop`, loaded last) | `src/scss/cshop/` (`base`, `components`, `layout`, `pages`, `b2b`) |
| C-Shop scripts (`data-ps-*` selectors, typed, tested) | `src/js/cshop/` |
| Header partials | `templates/_partials/cshop/` |
| Homepage sections | `templates/_partials/cshop/home/` |
| Product data contract and product partials | `templates/catalog/_partials/cshop/` |
| B2B UI components | `templates/components/cshop/b2b/` |
| Packaging | `scripts/build-theme-zip.sh` |

## Design system

- **Primary**: petrol blue `#0b4f6c` (8.4:1 on white). **Accent** (CTA,
  promotions): `#c2410c` (5.2:1). Status colours for stock all ≥ 4.5:1.
- Tokens are SCSS variables (`$cs-*`) and CSS custom properties (`--cs-*`).
- Components: buttons (`btn-primary`, `btn-accent`, `btn-ghost`, loading state
  via `data-ps-state="loading"`), stock badge (`cs-stock--in_stock|available|
  last_remaining_items|unavailable|discontinued`), tags, cards, forms and
  quantity rules, tables (`cs-table`), skeleton / empty / error states, codes
  list (`cs-codes`). Focus is always visible; motion respects
  `prefers-reduced-motion`.

## 1.6.4

Footer "Store information": VAT number (Shop parameters › Contact › Stores,
registration number) under the address.

## 1.6.3

Homepage: gap above the module hook panel (custom text), it touched the
"For companies" panel.

## 1.6.1

Collaborative commerce illustration: the centre is the C-Commerce mark
(the Harabara "C" rotated -47°, fitted on the c-commerce.it favicon at 98%,
plus its dark bar) instead of a generic C.

## 1.6.0 — "Chi siamo" and "Il commercio collaborativo"

Styles for two Back Office contents kept in `docs/content/`: the CMS page
"Chi siamo" (`.cs-about`, full sheet width) and the homepage custom text
(`.cs-collab`, illustration `src/img/cshop/commercio-collaborativo.svg`,
C-Commerce logo from c-commerce.it). Paste the HTML in Design > Pages and
Modules > Custom text block (source code view).

## 1.5.3

Mega menu: a category without sub-categories gets its own tab that shows 8
of its products (`src/js/cshop/menu-products.ts`: the category URL asked as
JSON with `resultsPerPage=8`, loaded once when the tab opens) and a "See all
N products" link. Bigger thumbnails: menu left 48px, sub-category tiles
112px, mobile 48px, homepage tiles 120px.

## 1.5.2

Product price block: "Tax included" right under the price, then the "+ VAT"
price; the core "%price% tax excluded" line (shown in B2B mode, a duplicate)
is removed (`product-prices.tpl`, block `product_without_taxes` emptied).

## 1.5.1

Category thumbnails (Catalog > Categories > Thumbnail, file
`img/c/<id>_thumb-category_default.jpg`): in the mega menu (left column
32px, sub-categories as photo tiles), in the mobile drawer and on the
homepage "Shop by category" tiles. The icon stays as fallback: the img
removes itself when a category has no thumbnail.

## 1.5.0 — B2B registration

Works with the `cshopb2b` module (`extras/cshopb2b`, see its README):
`customer-form.tpl` renders the module fields first (type cards + business
details panel, multipart for the visura upload), `form-fields.tpl` hides the
"Optional" hint on them, `src/js/cshop/b2b-registration.ts` shows/requires
fields per customer type, styles in `cshop/b2b/_b2b.scss`.

## 1.4.7

Homepage brands: logos fixed (ps_brandlist gives `id_manufacturer`, not `id`:
every logo URL was wrong) and 12 random brands on every visit
(`src/js/cshop/brand-shuffle.ts`, full list as JSON in the template, first
12 rendered as no-JS fallback; works behind page caches).

## 1.4.6

Left column: "Categories" (`ps_categorytree.tpl`) and a new "Brands" block
(`_partials/cshop/left-brands.tpl`, included by the layouts on catalogue
pages) are collapsible, closed by default (`.cs-collapsible`). Homepage
brands: logo above, name below (`.cs-brand-grid`), initial badge when the
brand has no logo.

## 1.4.5

Filters (ps_facetedsearch): first in the left column (they were under the
full category tree), first 4 groups open (`facets.tpl`), long value lists
scroll inside a 15rem box. Back Office: template "Combinazione" on all
categories, all attribute groups, no value limit (the theme has no "show
more", a limit hid values), default template for new categories.

## 1.4.4

Quick view: one button per device. Mouse: "Preview" bar on hover only; touch:
the eye icon only (the C-Shop `.btn` display rule kept the eye visible on
desktop too).

## 1.4.3

Icon arrows showed as "îŒ“" on the live shop: the minifier wrote Material
Icons glyphs as raw UTF-8 and CCC serves the combined CSS without a charset
(read as Windows-1252). `webpack/css-ascii-plugin.js` re-escapes every
non-ASCII character after minification, so the built CSS is pure ASCII.

## 1.4.2

Main menu: "Home" always first (desktop bar and mobile drawer, in
`modules/ps_mainmenu/ps_mainmenu.tpl`), items centred, label and chevron are
one item with one hover background and one "current" underline.

## 1.4.1

Search field: the clear button (×) sat over the magnifier on desktop. The
minifier moved `right: auto` after `inset-inline-end`; now one `right` value.

## Quality pass 1.4.0 (October 2026)

Full visual audit (18 pages × 5 widths, headless Chromium + DOM checks for
overflow, overlaps, clipped labels, tap targets, alignment, English strings).

- Homepage: every block is a panel *inside* `.container` (toner, support,
  reorder, brands, business, product shelves, `displayHome`): below 1400px
  they used to run edge to edge. Templates: `components/module-products.tpl`
  (container outside `.module-products`), `index.tpl`, `_partials/cshop/home/*`.
- Header: no empty strip under the department bar; hero art only from xxl
  (it touched the title); mobile hero pill on one line; hero links 44px tall.
- Product cards: stepper and button on one row, wrapping below on narrow
  cards; upstream `width: 100%` drew the button over the stepper. The label
  shows only when it fits (container query on the form).
- Listings: current page number visible (was dark on petrol), 44px page
  links; compact subcategory tiles (md+); sort menu cannot widen the page.
- Cart: title above both columns (`checkout/cart.tpl`), cross-selling shelf
  limited to 4 products, no double container gutter, bigger "Remove" target.
- Checkout: step buttons orange like the cart CTA. Contact: no nested panel,
  shop info on a panel.

## "Mercato" on every page 1.3.0

`src/scss/cshop/_mercato-pages.scss`: grey page and white rounded panels on
listings (header, toolbar, sidebar blocks), product page (main panel, details,
reviews), cart and checkout (content + one sidebar panel), account,
authentication, CMS/contact/sitemap/404; product cards white on grey; header
icons forced white on the petrol band.

## "Mercato" look 1.2.0 (October 2026)

Proposal A chosen by the shop owner: dense and commercial. Styles in
`src/scss/cshop/_mercato.scss` (after `_refresh.scss`).

- Information bar: e-invoicing, secure payments and the phone from
  `ps_contactinfo` (no reassurance placeholders in the top bar any more).
- Petrol header, logo on a white badge, large white search with orange button,
  darker department bar.
- Homepage on a light grey page: banner hero with CTA to price drops, sign-in
  card and toner shortcut; round department icons (picked from the menu label,
  category image wins); product shelves on white panels, 6 columns, one large
  add-to-cart button; brand names instead of the feed's inconsistent logos.

## Refresh 1.1.0 (October 2026)

Same palette, more modern finish. All in `src/scss/cshop/_refresh.scss`
(last file of the `cshop` layer) plus a few token changes:

- Tokens: radii 6/10/16px, two-layer soft shadows, container 1400px with
  real side gutters (`--cs-gutter`: 16 / 24 / 40px).
- Petrol gradient hero with white copy; account card floating on it.
- Product cards: rounded, grey photo frame, 2-line titles of equal height,
  larger price, lift on hover; pill flags.
- Product page: elevated buy box, bigger price, one-row thumbnails.
- Dark petrol footer; copyright uses the shop name and the registration
  number from Shop parameters › Contact instead of the PrestaShop credit.

CSS bugs fixed:

| Bug | Cause / fix |
|---|---|
| Homepage scrolled sideways on phones (455px page in a 375px viewport) | hero grid column without `minmax(0, 1fr)` grew to the chip row |
| Product names on 3-4 lines, prices not aligned | `display: box` (invalid) disabled the line clamp → `-webkit-box` |
| Chips, badges and filter pills had square corners | `--cs-radius-pill` used 6 times but never defined |
| "+" of the quantity stepper on a second line | Bootstrap `input-group` wraps by default → `nowrap` |
| List view on phones: add-to-cart button cut off by the card | icon-only button below 768px |
| Breadcrumb cut off at the edge on phones | one swipeable line with fade |
| 5th product thumbnail alone on a second row | thumbnails in one scrollable row |
| Text touching the window edge on laptops | container gutters |

## Product data contract

`templates/catalog/_partials/cshop/product-data.tpl` builds `$cs` from native
fields and an optional `cshop` array added by a module. Nothing is invented:
missing values are simply not shown.

| UI | Native field | Module override (`$product.cshop.*`) |
|---|---|---|
| Product code | `reference` | — |
| Supplier code | `supplier_reference` | `supplier_code` |
| OEM code | `mpn` (Manufacturer Part Number) | `oem_code` |
| EAN | `ean13` | — |
| Brand | `manufacturer_name` | — |
| Minimum order | `minimal_quantity` / `quantity_required` | `min_quantity` (if greater) |
| Order multiples (qty step) | — (not in core) | `order_multiple` |
| Pack size | — (unit price via `unity` / `unit_price_full`) | `pack_quantity`, `pack_label` |
| Delivery | `delivery_information`, availability | `lead_time` |
| Documents | product attachments | `documents[] {name,url,size}` |
| Technical data | `grouped_features` | — |
| Compatible products | accessories | — |
| Related products | `ps_categoryproducts`, `ps_crossselling` | — |

A module adds the data without touching the theme:

```php
public function hookActionPresentProduct(array $params): void
{
    $params['presentedProduct']->appendArray(['cshop' => $this->getEdiData($params['presentedProduct'])]);
}
// same for actionPresentProductListing and actionPresentCartProduct
```

**Multiples are UI guidance only** (input `step`, spin buttons, snapping on
blur). Server-side enforcement must be implemented by the same module (for
example on `actionCartUpdateQuantityBefore`).

## Optional hooks for C-Shop modules

| Hook | Where | Suggested component |
|---|---|---|
| `displayCshopQuickOrder` | Homepage, quick-reorder section | `components/cshop/b2b/quick-order.tpl` |
| `displayCshopQuoteRequest` (`product`) | Product buy box | `components/cshop/b2b/quote-request.tpl` |

A module creates these hooks with `registerHook()`. Without a module they
render nothing. Other B2B components (`reorder-list`, `product-lists`,
`price-list`) are included by the modules in their own front controllers.

## Compatibility hooks for existing modules

Some modules written for the Classic theme target Classic ids. The product
page keeps them so they work without changes:

| Selector | Element |
|---|---|
| `#product-description-short-{id_product}` | short description (`.product__description-short`) |
| `#description .product-description` | long description body |

Used, for example, by the C-Teck Desktoo EDI module (`variant-descriptions.js`)
to swap short/long description when the combination changes.

## Back Office configuration checklist

1. **Main menu** (`ps_mainmenu`): the 8 main categories (Cancelleria e
   scrittura, Carta e spedizione, Archivio e organizzazione, Toner e
   cartucce, Disegno e didattica, Arredamento ufficio, Informatica e macchine
   per ufficio, Igiene, catering e sicurezza). The same tree feeds the
   homepage category tiles; the toner finder links to the item whose label
   contains "toner".
2. **Search** (Shop parameters › Search): keep reference, supplier reference,
   EAN/UPC/MPN and brand weights > 0 and rebuild the index after EDI imports.
3. **Faceted search**: brand, price, availability, and features/attributes for
   format, colour, dimensions, material and compatibility. Sort options come
   from core and faceted search.
4. **Reassurance** (`blockreassurance`): assistance, delivery and commercial
   conditions shown in the information bar and in the homepage.
5. **Contact information** (`ps_contactinfo`): phone / e-mail for assistance.
6. **Featured products**: products in the configured category; the homepage
   "Available products" section lists only those in stock.
7. **Products per page**: 36 (set by the theme; adjust in Product settings).
8. Translations (rebuild with `python3 scripts/build-translations.py`): every string added by C-Shop uses the `Shop.Theme.Cshop`
   domain; the Italian catalogue ships in
   `translations/it-IT/ShopThemeCshop.it-IT.xlf` and can be overridden in
   International › Translations. Core strings come from the PrestaShop
   Italian language pack.

## How it was verified

On a local PrestaShop **9.2.0** (source tag, demo data, PHP 8.4, MariaDB,
Smarty cache and CCC enabled, `_PS_MODE_DEV_` on):

- ZIP installed through PrestaShop's `ThemeManager::install()` (the code path
  of the Back Office upload) and enabled.
- Home, category, search, brand, product (simple, combinations), cart,
  checkout, account and history pages: no PHP warning / Smarty error.
- Headless Chromium at 1440 / 820 / 390 px: no console errors; grid/list
  switch (persists after reload and faceted refresh), autocomplete with codes,
  combination change keeps codes, add to cart, mobile menu and filter drawer,
  keyboard skip link.
- Data contract checked with a throw-away module feeding `cshop` data:
  supplier/OEM codes, pack, minimum, multiples (spin 5 → 10 → 15, 7 → 10 on
  blur, cart +5), lead time, PDF documents, quote request.

## Updating from upstream Hummingbird

```bash
git remote add upstream https://github.com/PrestaShop/hummingbird.git  # once
git fetch upstream --tags
git merge v2.1.x   # next patch tag compatible with PS 9.2
```

Conflicts are limited to the upstream templates listed in the change log of
this branch (header, index, listing top, miniature, product page partials,
cart lines, module-products component, a few module overrides) and to
`config/theme.yml`, `useQuantityInput.ts` (step support) and the search bar.

## Technical decisions

- **Fork, not child theme**: the design system changes Bootstrap variables at
  compile time, which a child theme cannot do; isolation in `cshop` folders and
  a dedicated CSS layer keeps merges manageable.
- **Widgets instead of hooks for fixed layout** (header, homepage): search,
  menu, account and cart are always where the catalogue design expects them.
  `theme.yml` unhooks the same modules from their old positions to avoid
  duplicates.
- **Codes inside refreshed blocks** on the product page so they follow the
  selected combination after the core Ajax refresh.
- **No jQuery**, only `data-ps-*` selectors, event delegation for Ajax-updated
  listings. View mode (grid/list) is stored in `localStorage` when available.
