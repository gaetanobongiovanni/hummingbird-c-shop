#!/usr/bin/env bash
# Packages the cshopcod module (extras/cshopcod) as dist/cshopcod-<version>.zip
# for Back Office > Modules > Upload a module. Tests are left out.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(sed -n "s/.*\$this->version = '\([^']*\)'.*/\1/p" "$ROOT/extras/cshopcod/cshopcod.php")"
php "$ROOT/extras/cshopcod/tests/FeeTest.php"
python3 "$ROOT/scripts/build-cod-translations.py"
mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/cshopcod-$VERSION.zip"
rm -f "$OUT"
(cd "$ROOT/extras" && zip -qr "$OUT" cshopcod -x 'cshopcod/tests/*')
echo "Module package: $OUT"
