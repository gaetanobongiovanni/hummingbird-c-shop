#!/usr/bin/env python3
"""Builds the it-IT XLF catalogues of the cshopoffers module (same format as
build-b2b-translations.py). Fails if a wording has no Italian translation."""
import hashlib
import pathlib
import re
import sys
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'extras' / 'cshopoffers'

IT = {
    'C-Shop offers: discounted combination': 'C-Shop offerte: variante scontata',
    'On the offers page, shows the discounted combination of each product instead of the default one.':
        'Nella pagina Offerte mostra la variante scontata di ogni prodotto invece di quella predefinita.',
}

PHP = re.compile(r"trans\(\s*'((?:[^'\\]|\\.)*)'\s*,\s*\[(?:[^\[\]]|\[[^\[\]]*\])*\]\s*,\s*'Modules\.Cshopoffers\.(\w+)'", re.S)
TPL = re.compile(r"\{l s='((?:[^'\\]|\\.)*)'.*?d='Modules\.Cshopoffers\.(\w+)'")


def main() -> int:
    domains = {'Shop': set(), 'Admin': set()}
    for path in ROOT.rglob('*.php'):
        if 'tests' not in path.parts:
            for m in PHP.finditer(path.read_text(encoding='utf-8')):
                domains[m.group(2)].add(m.group(1).replace("\\'", "'"))
    for path in ROOT.rglob('*.tpl'):
        for m in TPL.finditer(path.read_text(encoding='utf-8')):
            domains[m.group(2)].add(m.group(1).replace("\\'", "'"))
    missing = sorted(w for ws in domains.values() for w in ws if w not in IT)
    if missing:
        print('Missing Italian translations:', *missing, sep='\n  ')
        return 1
    for domain, wordings in domains.items():
        out = ROOT / 'translations' / 'it-IT' / f'ModulesCshopoffers{domain}.it-IT.xlf'
        units = ''.join(
            f'      <trans-unit id="{hashlib.md5(s.encode()).hexdigest()}">\n'
            f'        <source>{escape(s)}</source>\n        <target>{escape(IT[s])}</target>\n      </trans-unit>\n'
            for s in sorted(wordings)
        )
        out.write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">\n'
            '  <file original="modules/cshopoffers" source-language="en-US" target-language="it-IT" datatype="plaintext">\n'
            f'    <body>\n{units}    </body>\n  </file>\n</xliff>\n',
            encoding='utf-8',
        )
        print(f'{out.relative_to(ROOT.parent.parent)}: {len(wordings)} wordings')
    return 0


if __name__ == '__main__':
    sys.exit(main())
