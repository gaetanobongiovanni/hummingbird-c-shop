#!/usr/bin/env bash
# C-Shop — update the theme already installed on the shop, in place.
#
# The Back Office "Add new theme" upload refuses a theme whose folder already
# exists, so updating that way means deleting the theme every time. This script
# copies the built runtime files straight into themes/cshop on the server and
# clears PrestaShop's cache: hook positions, module settings and the active
# theme are untouched.
#
# Usage:
#   CSHOP_SSH=user@host CSHOP_ROOT=/var/www/c-shop.store scripts/deploy-theme.sh
# Optional:
#   CSHOP_PHP=php8.2          PHP binary on the server (default: php)
#   CSHOP_SKIP_BUILD=1        reuse the current assets/ build
#   CSHOP_DRY_RUN=1           show what would change, copy nothing
#
# Requirements: SSH key access to the server, rsync on both sides, write access
# to <CSHOP_ROOT>/themes/cshop for the SSH user (same user as PHP, or a group
# both share, so the shop can still write assets/cache).
#
# Note: hook positions in config/theme.yml are applied only when a theme is
# installed; template, style, script and translation changes go live at once.
set -euo pipefail

: "${CSHOP_SSH:?Set CSHOP_SSH, e.g. deploy@c-shop.store}"
: "${CSHOP_ROOT:?Set CSHOP_ROOT, the PrestaShop folder on the server}"
PHP_BIN="${CSHOP_PHP:-php}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(sed -n 's/^name: *//p' "$ROOT/config/theme.yml" | head -1)"
VERSION="$(sed -n 's/^version: *//p' "$ROOT/config/theme.yml" | head -1)"
REMOTE_THEME="${CSHOP_ROOT%/}/themes/${NAME}"

if [[ -z "${CSHOP_SKIP_BUILD:-}" ]]; then
  (cd "$ROOT" && npm run build && python3 scripts/build-translations.py)
fi

for required in assets/css/theme.css assets/js/theme.js config/theme.yml; do
  [[ -f "$ROOT/$required" ]] || { echo "Missing $required — build first." >&2; exit 1; }
done

ssh "$CSHOP_SSH" "test -d '$REMOTE_THEME'" \
  || { echo "No theme folder at $CSHOP_SSH:$REMOTE_THEME — install the ZIP once from the Back Office." >&2; exit 1; }

RSYNC_FLAGS=(-rlptz --delete --itemize-changes --exclude '*.map' --exclude '.DS_Store')
[[ -n "${CSHOP_DRY_RUN:-}" ]] && RSYNC_FLAGS+=(--dry-run)

echo "Deploying ${NAME} ${VERSION} to ${CSHOP_SSH}:${REMOTE_THEME}"
for item in assets config modules plugins templates translations; do
  extra=()
  # assets/cache is written by the shop (combined CSS/JS): never copy or delete it
  [[ "$item" == assets ]] && extra=(--exclude '/cache/')
  rsync "${RSYNC_FLAGS[@]}" ${extra[@]+"${extra[@]}"} "$ROOT/$item/" "$CSHOP_SSH:$REMOTE_THEME/$item/"
done
rsync "${RSYNC_FLAGS[@]}" "$ROOT/preview.png" "$CSHOP_SSH:$REMOTE_THEME/preview.png"

if [[ -n "${CSHOP_DRY_RUN:-}" ]]; then
  echo "Dry run: nothing copied, cache not cleared."
  exit 0
fi

# Combined CSS/JS (CCC), Smarty and Symfony caches, translations included
ssh "$CSHOP_SSH" "rm -rf '$REMOTE_THEME/assets/cache/'* \
  && cd '$CSHOP_ROOT' && $PHP_BIN bin/console cache:clear --env=prod --no-warmup >/dev/null \
  && echo 'Cache cleared.'"

echo "Done: ${NAME} ${VERSION} is live."
