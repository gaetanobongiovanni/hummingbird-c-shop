/**
 * C-Shop — centralised `data-ps-*` selectors.
 * JS never targets CSS classes (see CONTEXT.md §5).
 */
const cshopSelectors = {
  wishlistLink: '[data-ps-component="cs-wishlist-link"]',
  brandShuffle: {
    container: '[data-ps-component="cs-brand-shuffle"]',
    grid: '[data-ps-ref="cs-brand-grid"]',
    data: 'script[data-ps-ref="cs-brand-data"]',
  },
  listingView: {
    container: '[data-ps-component="cs-listing"]',
    toggle: '[data-ps-action="cs-listing-view"]',
    switcher: '[data-ps-ref="cs-view-switch"]',
  },
  qtyRules: {
    input: 'input[data-ps-component="cs-qty"]',
    message: '[data-ps-ref="cs-qty-message"]',
  },
  quickOrder: {
    form: '[data-ps-component="cs-quick-order"]',
    rows: '[data-ps-target="cs-quick-order-rows"]',
    row: '[data-ps-ref="cs-quick-order-row"]',
    template: 'template[data-ps-template="cs-quick-order-row"]',
    addRow: '[data-ps-action="cs-quick-order-add-row"]',
    removeRow: '[data-ps-action="cs-quick-order-remove-row"]',
    paste: '[data-ps-ref="cs-quick-order-paste"]',
    applyPaste: '[data-ps-action="cs-quick-order-apply-paste"]',
  },
} as const;

export default cshopSelectors;
