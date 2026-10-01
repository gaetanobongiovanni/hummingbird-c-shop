/**
 * C-Shop — entry point for theme-specific behaviours.
 * Called from src/js/theme.ts after the Hummingbird initialisers.
 */
import initB2bRegistration from './b2b-registration';
import initBrandShuffle from './brand-shuffle';
import initWishlistLink from './header';
import initListingView from './listing-view';
import initMenuProducts from './menu-products';
import initQtyRules from './qty-rules';
import initQuickOrder from './quick-order';
import initQuoteRequest from './quote-request';
import initStickyBuy from './sticky-buy';

const initCshop = (): void => {
  initB2bRegistration();
  initBrandShuffle();
  initWishlistLink();
  initListingView();
  initMenuProducts();
  initQtyRules();
  initQuickOrder();
  initQuoteRequest();
  initStickyBuy();
};

export default initCshop;
