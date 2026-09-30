#!/usr/bin/env bash
# C-Shop — package the theme as a ZIP installable from
# Back Office > Design > Theme & Logo > Add new theme.
# Run `npm ci && npm run build` first: PrestaShop refuses a theme without
# assets/css/theme.css and assets/js/theme.js.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="$(sed -n 's/^name: *//p' "$ROOT/config/theme.yml" | head -1)"
VERSION="$(sed -n 's/^version: *//p' "$ROOT/config/theme.yml" | head -1)"
DIST="$ROOT/dist"
STAGE="$DIST/stage"
ZIP="$DIST/${NAME}-${VERSION}.zip"

for required in assets/css/theme.css assets/js/theme.js config/theme.yml preview.png; do
  if [[ ! -f "$ROOT/$required" ]]; then
    echo "Missing $required — run 'npm ci && npm run build' first." >&2
    exit 1
  fi
done

rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE"

# Runtime files only: no sources, node_modules, tooling or source maps.
for item in assets config modules plugins templates preview.png LICENSE.md; do
  cp -R "$ROOT/$item" "$STAGE/"
done
cp "$ROOT/docs/CSHOP.md" "$STAGE/README.md"
find "$STAGE" -name '*.map' -delete
find "$STAGE" -name '.DS_Store' -delete

(cd "$STAGE" && zip -qr -X "$ZIP" .)
rm -rf "$STAGE"

echo "Theme package: $ZIP ($(du -h "$ZIP" | cut -f1))"
