/**
 * C-Shop — entry point for theme-specific behaviours.
 * Called from src/js/theme.ts after the Hummingbird initialisers.
 */
import initWishlistLink from './header';

const initCshop = (): void => {
  initWishlistLink();
};

export default initCshop;
