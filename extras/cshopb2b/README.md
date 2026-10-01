# cshopb2b — C-Shop B2B registration (PrestaShop 9)

Registration with customer type and Italian e-invoicing data, reseller approval
with chamber of commerce extract (visura camerale).

| Type | Fields | Group after registration |
|------|--------|--------------------------|
| Privato | — | Cliente (unchanged) |
| Azienda (own use) | legal form, company name, VAT, tax code, SDI or PEC | Aziende |
| Rivenditore | as Azienda + visura (PDF/JPG/PNG, 5 MB) | Rivenditori in verifica → Rivenditori after approval |
| Ente pubblico | name, tax code (11 digits), IPA code, VAT/PEC optional | Enti pubblici |

- Sole trader: tax code = owner's personal code (16 chars, check char verified);
  company / public body: 11-digit code. VAT numbers are checksum-validated.
- The groups are created at install with the access (categories, carriers,
  modules) of the standard Customer group. Discounts and tax-excluded display
  are set by the shop in Customers > Groups (price lists come later).
- Resellers can order at list price while pending. Customers > B2B requests:
  open the request, view the visura, Approve (group Rivenditori + email) or
  Reject (group Aziende + email with the note).
- Visure are stored in `download/cshopb2b/` (PrestaShop's private folder, plus
  its own deny rule) with random names; only the back office can download them.
- Notification email (with the visura attached): module configuration,
  default buyer@c-commerce.it.
- Fields appear on the registration page only (not in the checkout guest form).

Server: `upload_max_filesize` ≥ 6M and `post_max_size` ≥ 8M (PHP defaults of
2M/8M reject most scanned visure).

Build: `npm run zip:b2b` → `dist/cshopb2b-<version>.zip` (runs the validator
tests and the it-IT translations). Theme side: `templates/customer/_partials/customer-form.tpl`,
`src/js/cshop/b2b-registration.ts`, `src/scss/cshop/b2b/_b2b.scss`.
