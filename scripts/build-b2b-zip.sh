#!/usr/bin/env bash
# Packages the cshopb2b module (extras/cshopb2b) as dist/cshopb2b-<version>.zip
# for Back Office > Modules > Upload a module. Tests are left out.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(sed -n "s/.*\$this->version = '\([^']*\)'.*/\1/p" "$ROOT/extras/cshopb2b/cshopb2b.php")"
php "$ROOT/extras/cshopb2b/tests/ValidatorTest.php"
python3 "$ROOT/scripts/build-b2b-translations.py"
mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/cshopb2b-$VERSION.zip"
rm -f "$OUT"
(cd "$ROOT/extras" && zip -qr "$OUT" cshopb2b -x 'cshopb2b/tests/*')
echo "Module package: $OUT"
