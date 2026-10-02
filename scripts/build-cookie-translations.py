#!/usr/bin/env python3
"""Builds the it-IT XLF catalogues of the cshopcookie module (same format as
build-b2b-translations.py). Fails if a wording has no Italian translation."""
import hashlib
import pathlib
import re
import sys
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'extras' / 'cshopcookie'

IT = {
    # Shop
    'Close and refuse optional cookies': 'Chiudi e rifiuta i cookie facoltativi',
    'We respect your privacy': 'Rispettiamo la tua privacy',
    'We use technical cookies to make the shop work. With your consent we would also use statistics cookies, to understand how the site is used, and marketing cookies, to show you relevant offers.':
        'Usiamo cookie tecnici per far funzionare il negozio. Con il tuo consenso useremmo anche cookie statistici, per capire come viene usato il sito, e cookie di marketing, per mostrarti offerte in linea con i tuoi interessi.',
    'You can change your choice at any time from "Cookie preferences" at the bottom of the page.':
        'Puoi cambiare scelta in qualsiasi momento da "Preferenze cookie" in fondo alla pagina.',
    'Read the cookie policy': 'Leggi la cookie policy',
    'Customise': 'Personalizza',
    'Refuse': 'Rifiuta',
    'Accept all': 'Accetta tutti',
    'Cookie preferences': 'Preferenze cookie',
    'Choose which optional cookies to allow. Technical cookies are needed for the shop and are always active.':
        'Scegli quali cookie facoltativi consentire. I cookie tecnici servono al negozio e sono sempre attivi.',
    'Necessary': 'Necessari',
    'Always active': 'Sempre attivi',
    'Cart, sign-in, security and payment. Without them the shop cannot work.':
        'Carrello, accesso, sicurezza e pagamento. Senza questi il negozio non può funzionare.',
    'Statistics': 'Statistiche',
    'They tell us, in aggregate form, which pages are visited and how the site is used, so we can improve it.':
        'Ci dicono, in forma aggregata, quali pagine vengono visitate e come viene usato il sito, per migliorarlo.',
    'Marketing': 'Marketing',
    'They let us and our partners show you offers in line with your interests, on this site and elsewhere.':
        'Permettono a noi e ai nostri partner di mostrarti offerte in linea con i tuoi interessi, su questo sito e altrove.',
    'Back': 'Indietro',
    'Save preferences': 'Salva preferenze',
    # Admin
    'C-Shop cookie consent': 'C-Shop consenso cookie',
    'Cookie banner and preferences with Google Consent Mode v2, following the Italian Garante guidelines.':
        'Banner e preferenze cookie con Google Consent Mode v2, secondo le linee guida del Garante privacy.',
    'Settings saved.': 'Impostazioni salvate.',
    'Consent renewed: every visitor will see the banner again.': 'Consenso rinnovato: tutti i visitatori rivedranno il banner.',
    'Cookie banner': 'Banner cookie',
    'Turn on only the categories the shop really uses. With both off the banner is hidden: technical cookies need no consent.':
        'Attiva solo le categorie che il negozio usa davvero. Con entrambe spente il banner non compare: i cookie tecnici non richiedono consenso.',
    'Statistics cookies (e.g. Google Analytics)': 'Cookie statistici (es. Google Analytics)',
    'Marketing cookies (e.g. Meta Pixel, Google Ads)': 'Cookie di marketing (es. Meta Pixel, Google Ads)',
    'Cookie policy page': 'Pagina della cookie policy',
    'Ask for consent again': 'Richiedi di nuovo il consenso',
    'Use it when you add a new service or change the cookie policy: the choices already given stop being valid (current version: %version%).':
        'Usalo quando aggiungi un nuovo servizio o cambi la cookie policy: le scelte già espresse non valgono più (versione attuale: %version%).',
    'Ask everybody again': 'Richiedi a tutti',
}

PHP = re.compile(r"trans\(\s*'((?:[^'\\]|\\.)*)'\s*,\s*\[(?:[^\[\]]|\[[^\[\]]*\])*\]\s*,\s*'Modules\.Cshopcookie\.(\w+)'", re.S)
TPL = re.compile(r"\{l s='((?:[^'\\]|\\.)*)'.*?d='Modules\.Cshopcookie\.(\w+)'")


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
        out = ROOT / 'translations' / 'it-IT' / f'ModulesCshopcookie{domain}.it-IT.xlf'
        units = ''.join(
            f'      <trans-unit id="{hashlib.md5(s.encode()).hexdigest()}">\n'
            f'        <source>{escape(s)}</source>\n        <target>{escape(IT[s])}</target>\n      </trans-unit>\n'
            for s in sorted(wordings)
        )
        out.write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">\n'
            '  <file original="modules/cshopcookie" source-language="en-US" target-language="it-IT" datatype="plaintext">\n'
            f'    <body>\n{units}    </body>\n  </file>\n</xliff>\n',
            encoding='utf-8',
        )
        print(f'{out.relative_to(ROOT.parent.parent)}: {len(wordings)} wordings')
    return 0


if __name__ == '__main__':
    sys.exit(main())
