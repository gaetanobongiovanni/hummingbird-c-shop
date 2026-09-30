/**
 * C-Shop — entry point for theme-specific behaviours.
 * Called from src/js/theme.ts after the Hummingbird initialisers.
 */
import initWishlistLink from './header';
import initListingView from './listing-view';
import initQtyRules from './qty-rules';
import initQuickOrder from './quick-order';

const initCshop = (): void => {
  initWishlistLink();
  initListingView();
  initQtyRules();
  initQuickOrder();
};

export default initCshop;
