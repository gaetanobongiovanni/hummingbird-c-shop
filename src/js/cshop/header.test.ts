/**
 * C-Shop — header tests.
 */
import {initWishlistLink} from './header';

describe('initWishlistLink', () => {
  beforeEach(() => {
    document.body.innerHTML = '<div data-ps-component="cs-wishlist-link" hidden><a href="#">Wishlist</a></div>';
  });

  const link = (): HTMLElement => document.querySelector<HTMLElement>('[data-ps-component="cs-wishlist-link"]') as HTMLElement;

  it('stays hidden when blockwishlist is not active', () => {
    initWishlistLink({} as Window);

    expect(link().hidden).toBe(true);
  });

  it('is revealed when blockwishlist exposes its controller URL', () => {
    initWishlistLink({blockwishlistController: '/module/blockwishlist/action'} as Window & {blockwishlistController: string});

    expect(link().hidden).toBe(false);
  });
});
