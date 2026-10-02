#!/usr/bin/env bash
# Packages the cshopoffers module (extras/cshopoffers) as dist/cshopoffers-<version>.zip
# for Back Office > Modules > Upload a module. Tests are left out.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(sed -n "s/.*\$this->version = '\([^']*\)'.*/\1/p" "$ROOT/extras/cshopoffers/cshopoffers.php")"
php "$ROOT/extras/cshopoffers/tests/PickerTest.php"
python3 "$ROOT/scripts/build-offers-translations.py" && rm -f "$ROOT/extras/cshopoffers/translations/it-IT/ModulesCshopoffersShop.it-IT.xlf"
mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/cshopoffers-$VERSION.zip"
rm -f "$OUT"
(cd "$ROOT/extras" && zip -qr "$OUT" cshopoffers -x 'cshopoffers/tests/*')
echo "Module package: $OUT"
