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
8. Translations: every string added by C-Shop uses the `Shop.Theme.Cshop`
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
