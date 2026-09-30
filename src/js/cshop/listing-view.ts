/**
 * C-Shop — grid / list view switch for product listings.
 * The chosen view is stored per browser (localStorage, optional) and applied
 * to the persistent `#products` section, so it survives faceted-search Ajax
 * refreshes that re-render the toolbar.
 */
import EVENTS from '@constants/events-map';
import cshopSelectors from './selectors';

export type ListingView = 'grid' | 'list';

export const STORAGE_KEY = 'cshop.listingView';

const isListingView = (value: unknown): value is ListingView => value === 'grid' || value === 'list';

export const readStoredView = (storage: Pick<Storage, 'getItem'> | null): ListingView => {
  try {
    const value = storage?.getItem(STORAGE_KEY);

    return isListingView(value) ? value : 'grid';
  } catch {
    return 'grid';
  }
};

const storeView = (storage: Pick<Storage, 'setItem'> | null, view: ListingView): void => {
  try {
    storage?.setItem(STORAGE_KEY, view);
  } catch {
    // Storage may be unavailable (private mode): the view simply is not remembered.
  }
};

const getStorage = (): Storage | null => {
  try {
    return window.localStorage;
  } catch {
    return null;
  }
};

/** Reflects the view on the listing container and on the toggle buttons. */
export const applyView = (container: HTMLElement, view: ListingView): void => {
  container.setAttribute('data-ps-state', view);

  container.querySelectorAll<HTMLElement>(cshopSelectors.listingView.switcher).forEach((switcher) => {
    switcher.hidden = false;
  });

  container.querySelectorAll<HTMLButtonElement>(cshopSelectors.listingView.toggle).forEach((button) => {
    button.setAttribute('aria-pressed', String(button.dataset.psView === view));
  });
};

const initListingView = (): void => {
  const container = document.querySelector<HTMLElement>(cshopSelectors.listingView.container);

  if (!container) {
    return;
  }

  const storage = getStorage();
  applyView(container, readStoredView(storage));

  // Event delegation: toolbar buttons are replaced by Ajax refreshes.
  container.addEventListener('click', (event: Event) => {
    const target = event.target as HTMLElement | null;
    const button = target?.closest<HTMLButtonElement>(cshopSelectors.listingView.toggle);
    const view = button?.dataset.psView;

    if (button && isListingView(view)) {
      applyView(container, view);
      storeView(storage, view);
    }
  });

  // Re-sync the freshly rendered toolbar after faceted-search updates
  // (listener registered after Hummingbird's own DOM update handler).
  const {prestashop} = window;

  prestashop?.on(EVENTS.updateProductList, () => {
    applyView(container, readStoredView(storage));
  });
};

export default initListingView;
