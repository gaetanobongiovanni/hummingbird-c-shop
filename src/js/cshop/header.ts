/**
 * C-Shop — header behaviours.
 */
import cshopSelectors from './selectors';

type WishlistWindow = Window & {blockwishlistController?: string};

/**
 * The wishlist entry is rendered hidden and revealed only when the
 * blockwishlist module is active (it exposes `blockwishlistController`),
 * so the header never shows a link to a disabled module.
 */
export const initWishlistLink = (win: WishlistWindow = window): void => {
  const link = document.querySelector<HTMLElement>(cshopSelectors.wishlistLink);

  if (link && typeof win.blockwishlistController === 'string') {
    link.hidden = false;
  }
};

export default initWishlistLink;
