#!/usr/bin/env bash
# Packages the cshopcookie module (extras/cshopcookie) as dist/cshopcookie-<version>.zip
# for Back Office > Modules > Upload a module. Tests are left out.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(sed -n "s/.*\$this->version = '\([^']*\)'.*/\1/p" "$ROOT/extras/cshopcookie/cshopcookie.php")"
npx jest extras/cshopcookie --silent
python3 "$ROOT/scripts/build-cookie-translations.py"
mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/cshopcookie-$VERSION.zip"
rm -f "$OUT"
(cd "$ROOT/extras" && zip -qr "$OUT" cshopcookie -x 'cshopcookie/tests/*')
echo "Module package: $OUT"
