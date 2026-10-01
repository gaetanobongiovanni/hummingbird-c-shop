#!/usr/bin/env python3
"""Builds the it-IT XLF catalogues of the cshopb2b module.

Extracts every wording of the Modules.Cshopb2b.* domains from the module PHP
and Smarty files and writes extras/cshopb2b/translations/it-IT/*.xlf.
Fails if a wording has no Italian translation in IT below.
"""
import hashlib
import pathlib
import re
import sys
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'extras' / 'cshopb2b'

IT = {
    # Shop (registration form, my account)
    'I am registering as': 'Ti registri come',
    'Private customer': 'Privato',
    'Company (own use)': 'Azienda (acquisti per uso interno)',
    'Reseller': 'Rivenditore',
    'Public body': 'Ente pubblico',
    'Legal form': 'Forma giuridica',
    'Sole trader': 'Ditta individuale',
    'Company (srl, spa, snc, sas…)': 'Società (srl, spa, snc, sas…)',
    'Company name / name of the body': 'Ragione sociale / denominazione ente',
    'VAT number': 'Partita IVA',
    'Tax code': 'Codice fiscale',
    "Sole trader: the owner's personal tax code. Company or public body: the 11-digit tax code.":
        "Ditta individuale: il codice fiscale personale del titolare. Società o ente: il codice fiscale di 11 cifre.",
    'SDI recipient code': 'Codice destinatario SDI',
    '7 characters, for electronic invoices. Not available? Enter your PEC address.':
        '7 caratteri, per la fattura elettronica. Non lo hai? Inserisci l\'indirizzo PEC.',
    'Office unique code (IPA)': 'Codice univoco ufficio (IPA)',
    'PEC address': 'Indirizzo PEC',
    'Chamber of commerce extract (visura camerale)': 'Visura camerale',
    'PDF, JPG or PNG, max 5 MB, issued in the last 6 months. Reseller prices are activated after we check it.':
        'PDF, JPG o PNG, max 5 MB, rilasciata negli ultimi 6 mesi. I prezzi rivenditore si attivano dopo la nostra verifica.',
    'Choose how you are registering.': 'Scegli come ti stai registrando.',
    'The VAT number is not valid (11 digits).': 'La partita IVA non è valida (11 cifre).',
    "For a sole trader enter the owner's personal tax code (16 characters).":
        'Per la ditta individuale inserisci il codice fiscale personale del titolare (16 caratteri).',
    'Enter the 11-digit tax code.': 'Inserisci il codice fiscale di 11 cifre.',
    'The SDI recipient code has 7 characters.': 'Il codice destinatario SDI ha 7 caratteri.',
    'Enter the SDI recipient code or a PEC address for electronic invoices.':
        'Inserisci il codice destinatario SDI oppure un indirizzo PEC per la fattura elettronica.',
    'The office unique code has 6 characters.': 'Il codice univoco ufficio ha 6 caratteri.',
    'The PEC address is not valid.': "L'indirizzo PEC non è valido.",
    'Resellers must upload the chamber of commerce extract.': 'Per registrarti come rivenditore carica la visura camerale.',
    'The file is too large (max 5 MB).': 'Il file è troppo grande (max 5 MB).',
    'Upload a PDF, JPG or PNG file.': 'Carica un file PDF, JPG o PNG.',
    'The file could not be uploaded, please try again.': 'Non è stato possibile caricare il file, riprova.',
    'Required field': 'Campo obbligatorio',
    'Reseller account: reseller prices active.': 'Account rivenditore: prezzi rivenditore attivi.',
    'Reseller request under review: we will email you as soon as reseller prices are active. Meanwhile you can order at list price.':
        'Richiesta rivenditore in verifica: ti scriviamo appena i prezzi rivenditore sono attivi. Nel frattempo puoi ordinare a prezzo di listino.',
    'Business account.': 'Account aziendale.',
    'Public body account.': 'Account ente pubblico.',
    # Admin
    'C-Shop B2B registration': 'C-Shop registrazione B2B',
    'Customer type, Italian e-invoicing data and reseller approval with visura upload.':
        'Tipo cliente, dati per la fattura elettronica e approvazione rivenditori con visura camerale.',
    'Invalid email address.': 'Indirizzo email non valido.',
    'Settings updated.': 'Impostazioni aggiornate.',
    'Customer groups created by the module: %groups%. Set discounts and price display in Customers > Groups. Pending reseller requests: Customers > B2B requests.':
        'Gruppi clienti creati dal modulo: %groups%. Sconti e visualizzazione prezzi in Clienti > Gruppi. Richieste rivenditore in attesa: Clienti > Richieste B2B.',
    'Notify new reseller requests to': 'Avvisa le nuove richieste rivenditore a',
    'Leave empty to disable the email.': "Lascia vuoto per non inviare l'email.",
    'We received your reseller request': 'Abbiamo ricevuto la tua richiesta rivenditore',
    'New reseller to approve: %company%': 'Nuovo rivenditore da approvare: %company%',
    'Request not found.': 'Richiesta non trovata.',
    'Your reseller account is active': 'Il tuo account rivenditore è attivo',
    'Reseller approved: reseller prices are now active for %company%.': 'Rivenditore approvato: prezzi rivenditore attivi per %company%.',
    'About your reseller request': 'La tua richiesta rivenditore',
    'Request rejected: the customer stays in the Companies group.': 'Richiesta rifiutata: il cliente resta nel gruppo Aziende.',
    'The file is not available.': 'Il file non è disponibile.',
    'Resellers to approve': 'Rivenditori da approvare',
    'Approved resellers': 'Rivenditori approvati',
    'Rejected': 'Rifiutati',
    'All business customers': 'Tutti i clienti aziendali',
    'Company': 'Azienda',
    'To approve': 'Da approvare',
    'Approved': 'Approvato',
    'Business customers': 'Clienti aziendali',
    'No customers in this list.': 'Nessun cliente in questo elenco.',
    'Date': 'Data',
    'Company name': 'Ragione sociale',
    'Type': 'Tipo',
    'Contact': 'Referente',
    'Status': 'Stato',
    'Open': 'Apri',
    'SDI code': 'Codice SDI',
    'IPA code': 'Codice IPA',
    'Open customer page': 'Apri la scheda cliente',
    'Registered on': 'Registrato il',
    'Note': 'Nota',
    'Chamber of commerce extract': 'Visura camerale',
    'No file uploaded: ask the customer to send it before approving.':
        "Nessun file caricato: chiedi al cliente di inviarlo prima di approvare.",
    'Note (sent to the customer if you reject)': 'Nota (inviata al cliente se rifiuti)',
    'Approve: activate reseller prices': 'Approva: attiva i prezzi rivenditore',
    'Reject': 'Rifiuta',
    'Back to list': "Torna all'elenco",
    'Business data': 'Dati aziendali',
    'Reseller to approve': 'Rivenditore da approvare',
    'Approved reseller': 'Rivenditore approvato',
    'Reseller rejected': 'Rivenditore rifiutato',
    'Check the visura and approve': 'Controlla la visura e approva',
    'Open B2B details': 'Apri i dati B2B',
}

PHP_PATTERNS = [
    re.compile(r"shopTrans\(\s*'((?:[^'\\]|\\.)*)'"),
    re.compile(r"\$this->t\(\s*'((?:[^'\\]|\\.)*)'"),
    re.compile(r"trans\(\s*'((?:[^'\\]|\\.)*)'\s*,\s*\[(?:[^\[\]]|\[[^\[\]]*\])*\]\s*,\s*'Modules\.Cshopb2b\.(\w+)'", re.S),
]
TPL = re.compile(r"\{l s='((?:[^'\\]|\\.)*)' d='Modules\.Cshopb2b\.(\w+)'")


def unescape(s: str) -> str:
    return s.replace("\\'", "'")


def collect() -> dict:
    domains = {'Shop': set(), 'Admin': set()}
    for path in ROOT.rglob('*.php'):
        if 'tests' in path.parts:
            continue
        text = path.read_text(encoding='utf-8')
        for m in PHP_PATTERNS[0].finditer(text):
            domains['Shop'].add(unescape(m.group(1)))
        for m in PHP_PATTERNS[1].finditer(text):
            domains['Admin'].add(unescape(m.group(1)))
        for m in re.finditer(r"customerSubject\(\$customer,\s*'((?:[^'\\]|\\.)*)'", text):
            domains['Admin'].add(unescape(m.group(1)))
        for m in PHP_PATTERNS[2].finditer(text):
            domains[m.group(2)].add(unescape(m.group(1)))
    for path in ROOT.rglob('*.tpl'):
        for m in TPL.finditer(path.read_text(encoding='utf-8')):
            domains[m.group(2)].add(unescape(m.group(1)))
    return domains


def write(domain: str, wordings: set) -> None:
    out = ROOT / 'translations' / 'it-IT' / f'ModulesCshopb2b{domain}.it-IT.xlf'
    units = []
    for source in sorted(wordings):
        units.append(
            f'      <trans-unit id="{hashlib.md5(source.encode()).hexdigest()}">\n'
            f'        <source>{escape(source)}</source>\n'
            f'        <target>{escape(IT[source])}</target>\n'
            f'      </trans-unit>'
        )
    out.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">\n'
        f'  <file original="modules/cshopb2b" source-language="en-US" target-language="it-IT" datatype="plaintext">\n'
        '    <body>\n' + '\n'.join(units) + '\n    </body>\n  </file>\n</xliff>\n',
        encoding='utf-8',
    )
    print(f'{out.relative_to(ROOT.parent.parent)}: {len(wordings)} wordings')


def main() -> int:
    domains = collect()
    missing = sorted(w for ws in domains.values() for w in ws if w not in IT)
    if missing:
        print('Missing Italian translations:', *missing, sep='\n  ')
        return 1
    for domain, wordings in domains.items():
        write(domain, wordings)
    return 0


if __name__ == '__main__':
    sys.exit(main())
