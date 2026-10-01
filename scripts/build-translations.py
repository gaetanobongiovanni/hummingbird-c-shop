#!/usr/bin/env python3
"""C-Shop — rebuild translations/it-IT/*.xlf from the strings used in templates.

Usage: python3 scripts/build-translations.py
Fails if a Shop.Theme.Cshop string has no Italian translation in IT below.
"""
import hashlib, html, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IT = {
    "Electronic invoice for businesses and public bodies": "Fattura elettronica per aziende ed enti",
    "Secure payments": "Pagamenti sicuri",
    "Everything for your desk, from scissors to toner": "Tutto per la scrivania, dalle forbici al toner",
    "See the offers": "Scopri le offerte",
    "Sign in for a better experience": "Accedi per un'esperienza migliore",
    "Reorder from your history, download invoices, save your addresses.": "Riordina dallo storico, scarica le fatture, salva gli indirizzi.",
    "New customer? Create an account": "Nuovo cliente? Registrati",
    "Looking for toner?": "Cerchi un toner?",
    "Type your printer model or the original code.": "Scrivi il modello della stampante o il codice originale.",
    "%count% products": "%count% prodotti",
    "%label% of %qty% pcs": "%label% da %qty% pz",
    "%price% + VAT": "%price% + IVA",
    "%price% incl. VAT": "%price% IVA incl.",
    "Actions": "Azioni",
    "Add all to cart": "Aggiungi tutto al carrello",
    "Add row": "Aggiungi riga",
    "All brands": "Tutte le marche",
    "All rights reserved": "Tutti i diritti riservati",
    "All promotions": "Tutte le promozioni",
    "Assistance": "Assistenza",
    "Availability:": "Disponibilità:",
    "Available on order": "Disponibile su ordinazione",
    "Available products": "Prodotti disponibili",
    "Browse all: %category%": "Vedi tutto: %category%",
    "Code": "Codice",
    "Company account": "Account aziendale",
    "Compatible products and accessories": "Prodotti compatibili e accessori",
    "Delivery time: %lead_time%": "Tempi di consegna: %lead_time%",
    "Discontinued": "Fuori produzione",
    "Document": "Documento",
    "Documents and data sheets": "Documenti e schede tecniche",
    "EAN": "EAN",
    "Enter a product code, supplier code or OEM code and the quantity.": "Inserisci codice articolo, codice fornitore o codice OEM e la quantità.",
    "Enter your printer model or the original cartridge code (OEM) to find compatible products.": "Inserisci il modello della stampante o il codice originale della cartuccia (OEM) per trovare i prodotti compatibili.",
    "Fill the rows": "Compila le righe",
    "Find cartridges": "Trova cartucce",
    "For businesses and public bodies": "Per aziende ed enti pubblici",
    "Grid view": "Vista a griglia",
    "In stock": "Disponibile",
    "Last items in stock": "Ultimi pezzi disponibili",
    "List price": "Prezzo di listino",
    "List view": "Vista a elenco",
    "Main brands": "Marche principali",
    "Min.": "Min.",
    "Min. order: %qty%": "Ordine minimo: %qty%",
    "Multiples of %qty%": "Multipli di %qty%",
    "My orders": "I miei ordini",
    "My product lists": "Le mie liste prodotti",
    "My wishlists": "Le mie liste dei desideri",
    "Name, code or OEM…": "Nome, codice o OEM…",
    "Need help choosing?": "Serve aiuto?",
    "New list": "Nuova lista",
    "New products": "Nuovi prodotti",
    "Notes": "Note",
    "OEM code": "Codice OEM",
    "Office, school and business supplies": "Forniture per ufficio, scuola e azienda",
    "One product per line: code and quantity separated by space, tab or semicolon.": "Un prodotto per riga: codice e quantità separati da spazio, tabulazione o punto e virgola.",
    "Open PDF": "Apri PDF",
    "Open a previous order and add all its products to the cart again.": "Apri un ordine precedente e aggiungi di nuovo tutti i prodotti al carrello.",
    "Order history and reorder": "Storico ordini e riordino",
    "Out of stock": "Non disponibile",
    "Pack": "Confezione",
    "Pack of %qty% pcs": "Confezione da %qty% pz",
    "Pack quantity, minimum order and unit price on every product.": "Quantità per confezione, ordine minimo e prezzo unitario su ogni prodotto.",
    "Packs and minimums always visible": "Confezioni e minimi sempre visibili",
    "Paste a list of codes": "Incolla un elenco di codici",
    "Price drops": "Prezzi ribassati",
    "Printer model or cartridge code": "Modello stampante o codice cartuccia",
    "Private customers and businesses": "Privati e aziende",
    "Product code": "Codice articolo",
    "Product code, row %row%": "Codice articolo, riga %row%",
    "Product code, supplier code, OEM code and brand.": "Codice articolo, codice fornitore, codice OEM e marca.",
    "Product list view": "Visualizzazione elenco prodotti",
    "Promotions": "Promozioni",
    "Quantity, row %row%": "Quantità, riga %row%",
    "Quick order by product code": "Ordine rapido per codice",
    "Quick reorder": "Riordino rapido",
    "Register with your company details and manage your addresses.": "Registrati con i dati aziendali e gestisci i tuoi indirizzi.",
    "Remove row %row%": "Rimuovi riga %row%",
    "Reorder from previous orders": "Riordina dagli ordini precedenti",
    "Reorder from your order history in one click.": "Riordina dallo storico ordini con un clic.",
    "Reorder in a few clicks from your previous orders.": "Riordina in pochi clic dai tuoi ordini precedenti.",
    "Request a quote": "Richiedi un preventivo",
    "Search by code": "Ricerca per codice",
    "Search by product name, product code, supplier code, OEM code or brand": "Cerca per nome prodotto, codice articolo, codice fornitore, codice OEM o marca",
    "Search the catalog": "Cerca nel catalogo",
    "Search the catalogue by product name, product code, supplier code, OEM code or brand.": "Cerca nel catalogo per nome prodotto, codice articolo, codice fornitore, codice OEM o marca.",
    "Send request": "Invia richiesta",
    "Shop by category": "Acquista per categoria",
    "Sign in to reorder from your order history and track your deliveries.": "Accedi per riordinare dallo storico ordini e seguire le tue spedizioni.",
    "Sign in to reorder from your previous orders.": "Accedi per riordinare dai tuoi ordini precedenti.",
    "Supplier code": "Codice fornitore",
    "Technical specifications": "Caratteristiche tecniche",
    "Technical specifications of %product_name%": "Caratteristiche tecniche di %product_name%",
    "Toner and cartridges": "Toner e cartucce",
    "VAT number %vat%": "P.IVA %vat%",
    "Welcome back, %name%": "Bentornato, %name%",
    "Wishlist": "Preferiti",
    "Your price": "Il tuo prezzo",
    "Your price list": "Il tuo listino",
    "Add to cart": "Aggiungi al carrello",
}

# Overrides of core domains where the Italian pack is wrong or half English
OVERRIDES = {
    "ShopThemeActions": {
        "Continue shopping": "Continua gli acquisti",
    },
}


def xliff(units):
    body = "\n".join(
        f'      <trans-unit id="{hashlib.md5(s.encode()).hexdigest()}">\n'
        f"        <source>{html.escape(s, quote=False)}</source>\n"
        f"        <target>{html.escape(t, quote=False)}</target>\n"
        f"      </trans-unit>"
        for s, t in units
    )
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">\n'
        '  <file original="themes/cshop" source-language="en-US" target-language="it-IT" datatype="plaintext">\n'
        f"    <body>\n{body}\n    </body>\n  </file>\n</xliff>\n"
    )


def main():
    out = subprocess.run(
        ["grep", "-rhoE", r"\{l s='[^']*'[^}]*d='Shop.Theme.Cshop'", "templates", "modules"],
        cwd=ROOT, capture_output=True, text=True,
    ).stdout
    used = sorted({m.group(1) for m in re.finditer(r"s='([^']*)'", out)})
    missing = [s for s in used if s not in IT]
    if missing:
        print("Missing Italian translations:", *missing, sep="\n  ")
        sys.exit(1)
    target = ROOT / "translations" / "it-IT"
    target.mkdir(parents=True, exist_ok=True)
    (target / "ShopThemeCshop.it-IT.xlf").write_text(xliff([(s, IT[s]) for s in used]))
    for domain, strings in OVERRIDES.items():
        (target / f"{domain}.it-IT.xlf").write_text(xliff(sorted(strings.items())))
    print(f"{len(used)} C-Shop strings, {sum(len(v) for v in OVERRIDES.values())} overrides")


if __name__ == "__main__":
    main()
