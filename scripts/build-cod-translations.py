#!/usr/bin/env python3
"""Builds the it-IT XLF catalogues of the cshopcod module (same format as
build-b2b-translations.py). Fails if a wording has no Italian translation."""
import hashlib
import pathlib
import re
import sys
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'extras' / 'cshopcod'

IT = {
    # Shop
    'Pay on delivery (+ %fee%)': 'Pagamento in contrassegno (+ %fee%)',
    'You pay the courier when the parcel is delivered.': 'Paghi direttamente al corriere alla consegna del pacco.',
    'Cash on delivery surcharge: %fee% (%fixed% + %percent% of the order total), added to the order as its own line.':
        "Supplemento contrassegno: %fee% (%fixed% + %percent% del totale dell'ordine), aggiunto all'ordine come voce separata.",
    'Total to pay on delivery: %total%': 'Totale da pagare alla consegna: %total%',
    'Your order is confirmed. You will pay %total% to the courier on delivery, cash on delivery surcharge included.':
        'Il tuo ordine è confermato. Alla consegna pagherai al corriere %total%, supplemento contrassegno incluso.',
    'Please have the exact amount ready: couriers may not carry change.':
        "Tieni pronto l'importo esatto: il corriere potrebbe non avere il resto.",
    'This payment method is not available.': 'Questo metodo di pagamento non è disponibile.',
    'Cash on delivery': 'Contrassegno',
    # Admin
    'C-Shop cash on delivery with surcharge': 'C-Shop contrassegno con supplemento',
    'Cash on delivery with a fixed + percentage surcharge added to the order as its own line.':
        "Contrassegno con supplemento fisso + percentuale, aggiunto all'ordine come voce separata.",
    'Enter valid amounts (0 or more).': 'Inserisci importi validi (0 o più).',
    'Settings saved.': 'Impostazioni salvate.',
    'Cash on delivery surcharge': 'Supplemento contrassegno',
    'Surcharge = fixed amount + percentage of the order total (shipping and VAT included). It is added to the order as the product "Spese contrassegno" (reference %ref%): its tax rule decides the VAT.':
        "Supplemento = importo fisso + percentuale del totale dell'ordine (spedizione e IVA incluse). Viene aggiunto all'ordine come prodotto \"Spese contrassegno\" (riferimento %ref%): la sua regola IVA decide l'imposta.",
    'Open the surcharge product': 'Apri il prodotto del supplemento',
    'Fixed amount (VAT incl.)': 'Importo fisso (IVA incl.)',
    'Percentage of the order total': "Percentuale del totale dell'ordine",
}

PHP = re.compile(r"trans\(\s*'((?:[^'\\]|\\.)*)'\s*,\s*\[(?:[^\[\]]|\[[^\[\]]*\])*\]\s*,\s*'Modules\.Cshopcod\.(\w+)'", re.S)
TPL = re.compile(r"\{l s='((?:[^'\\]|\\.)*)'.*?d='Modules\.Cshopcod\.(\w+)'")


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
        out = ROOT / 'translations' / 'it-IT' / f'ModulesCshopcod{domain}.it-IT.xlf'
        units = ''.join(
            f'      <trans-unit id="{hashlib.md5(s.encode()).hexdigest()}">\n'
            f'        <source>{escape(s)}</source>\n        <target>{escape(IT[s])}</target>\n      </trans-unit>\n'
            for s in sorted(wordings)
        )
        out.write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">\n'
            '  <file original="modules/cshopcod" source-language="en-US" target-language="it-IT" datatype="plaintext">\n'
            f'    <body>\n{units}    </body>\n  </file>\n</xliff>\n',
            encoding='utf-8',
        )
        print(f'{out.relative_to(ROOT.parent.parent)}: {len(wordings)} wordings')
    return 0


if __name__ == '__main__':
    sys.exit(main())
