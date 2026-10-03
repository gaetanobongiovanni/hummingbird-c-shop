#!/usr/bin/env bash
# C-Shop — build the theme release package, with SHA-256.
#
#   scripts/build-release.sh [VERSION]
#
# VERSION (e.g. 1.6.12, usually the git tag without "v") must match
# config/theme.yml: a tag that does not match the theme version fails the build.
# Output in dist/: cshop-<v>.zip and cshop-<v>.zip.sha256.
# The C-Shop modules live in their own repos (C-Teck-B2B, C-Teck-COD,
# C-Teck-Cookie, C-Teck-Offers), each with its own release.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

THEME_VERSION="$(sed -n 's/^version: *//p' config/theme.yml | head -1)"
VERSION="${1:-$THEME_VERSION}"
if [[ "$VERSION" != "$THEME_VERSION" ]]; then
  echo "::error::Tag version $VERSION does not match config/theme.yml version $THEME_VERSION" >&2
  exit 1
fi

rm -rf dist
mkdir -p dist

echo "== Lint and tests"
npm run lint
npx jest --silent

echo "== Theme"
python3 scripts/build-translations.py
python3 scripts/build-opc-translations.py
npm run build
bash scripts/build-theme-zip.sh

echo "== Checksums"
(
  cd dist
  for zip in *.zip; do
    sha256sum "$zip" > "$zip.sha256"
  done
  ls -l
)
