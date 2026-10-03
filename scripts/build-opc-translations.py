#!/usr/bin/env python3
"""Italian catalogues for the ps_onepagecheckout module, shipped with the theme.

The module (PrestaShop 9.2 one-page checkout) has no it-IT translation. The
theme's translations/it-IT/*.xlf override any domain on the front office, so we
ship ModulesOnepagecheckoutShop and ModulesPsonepagecheckoutShop here.
Sources come from the module's en-US catalogues copied in scripts/data/.
Fails if a wording has no Italian translation below.
"""
import html
import pathlib
import re
import sys
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent
DATA = ROOT / 'scripts' / 'data'
OUT = ROOT / 'translations' / 'it-IT'

IT = {
    '-- please choose --': '-- seleziona --',
    'Account successfully created': 'Account creato',
    'Address details:': 'Dettagli indirizzo:',
    'Address options': 'Opzioni indirizzo',
    'Address successfully deleted.': 'Indirizzo eliminato.',
    'Already have an account? Sign in': 'Hai già un account? Accedi',
    'An error occurred while loading addresses. Please try again.': 'Errore nel caricamento degli indirizzi. Riprova.',
    'An error occurred while loading carriers. Please try again.': 'Errore nel caricamento dei corrieri. Riprova.',
    'An error occurred while loading payment methods. Please try again.': 'Errore nel caricamento dei metodi di pagamento. Riprova.',
    'Enter your email address above to see the delivery and payment options.': 'Inserisci la tua email qui sopra per vedere le opzioni di spedizione e pagamento.',
    'or': 'oppure',
    'Please accept the required terms above to see the delivery and payment options.': 'Accetta le condizioni obbligatorie qui sopra per vedere le opzioni di spedizione e pagamento.',
    'Please enter a valid email address.': 'Inserisci un indirizzo email valido.',
    'The email address is missing an "@" (e.g. name@example.com).': 'Nell\'indirizzo email manca la "@" (es. nome@esempio.it).',
    'The email address is missing the part after the "@" (e.g. name@example.com).': 'Nell\'indirizzo email manca la parte dopo la "@" (es. nome@esempio.it).',
    'The email address is missing the part before the "@" (e.g. name@example.com).': 'Nell\'indirizzo email manca la parte prima della "@" (es. nome@esempio.it).',
    'Unable to resolve checkout cart.': 'Impossibile recuperare il carrello.',
    "We couldn't load your delivery options. Please try again.": 'Non siamo riusciti a caricare le opzioni di spedizione. Riprova.',
    "We couldn't load your payment options. Please try again.": 'Non siamo riusciti a caricare i metodi di pagamento. Riprova.',
    'Complete your delivery address above to see your delivery options.': 'Completa l\'indirizzo di consegna qui sopra per vedere le opzioni di spedizione.',
    'Complete your delivery address above to see your payment options.': 'Completa l\'indirizzo di consegna qui sopra per vedere i metodi di pagamento.',
    'Still needed:': 'Manca ancora:',
    "We couldn't save your delivery address. Please check the fields above and try again.": 'Non siamo riusciti a salvare l\'indirizzo di consegna. Controlla i campi qui sopra e riprova.',
    'An error occurred. Please try again.': 'Si è verificato un errore. Riprova.',
    'Are you sure you want to delete this address?': 'Vuoi davvero eliminare questo indirizzo?',
    'Billing address': 'Indirizzo di fatturazione',
    'Cancel': 'Annulla',
    'Checkout': 'Cassa',
    'Close': 'Chiudi',
    'Connected as [1]%firstname% %lastname%[/1].': 'Accesso effettuato come [1]%firstname% %lastname%[/1].',
    'Contact information': 'Informazioni di contatto',
    'Continue as guest': 'Continua come ospite',
    'Create account': 'Crea account',
    'Delete': 'Elimina',
    'Delete this address?': 'Eliminare questo indirizzo?',
    'Delivery address': 'Indirizzo di consegna',
    'Delivery method': 'Metodo di spedizione',
    'Edit': 'Modifica',
    'Edit billing address': 'Modifica indirizzo di fatturazione',
    'Edit delivery address': 'Modifica indirizzo di consegna',
    'Gift wrapping is currently unavailable.': 'La confezione regalo al momento non è disponibile.',
    'I would like to receive my order in recycled packaging.': 'Vorrei ricevere l\'ordine in un imballaggio riciclato.',
    'If you sign out now, your cart will be emptied.': 'Se esci ora, il carrello verrà svuotato.',
    "If you'd like, you can add a note to the gift:": 'Se vuoi, puoi aggiungere un messaggio al regalo:',
    'Invalid delivery address.': 'Indirizzo di consegna non valido.',
    'Invalid email format.': 'Formato email non valido.',
    'Invalid security token.': 'Token di sicurezza non valido.',
    'Invoice address': 'Indirizzo di fatturazione',
    'Loading addresses...': 'Caricamento indirizzi...',
    'Loading delivery methods...': 'Caricamento metodi di spedizione...',
    'Loading payment methods...': 'Caricamento metodi di pagamento...',
    'Loading...': 'Caricamento...',
    'Missing delivery option.': 'Metodo di spedizione mancante.',
    'Missing payment selection payload.': 'Selezione del pagamento mancante.',
    'My Address': 'Il mio indirizzo',
    'My account (%firstname% %lastname%)': 'Il mio account (%firstname% %lastname%)',
    'New billing address': 'Nuovo indirizzo di fatturazione',
    'New delivery address': 'Nuovo indirizzo di consegna',
    'Not you? [1]Sign out[/1]': 'Non sei tu? [1]Esci[/1]',
    'One-page checkout is currently unavailable.': 'Il checkout al momento non è disponibile.',
    'One-page checkout is not enabled.': 'Il checkout in una pagina non è attivo.',
    'Order summary': 'Riepilogo ordine',
    'Order with an obligation to pay': 'Ordine con obbligo di pagamento',
    'Pay': 'Paga',
    'Payment method': 'Metodo di pagamento',
    'Please accept the terms of service.': 'Accetta le condizioni di vendita.',
    'Please correct the highlighted address fields.': 'Correggi i campi dell\'indirizzo evidenziati.',
    'Please select a delivery method.': 'Seleziona un metodo di spedizione.',
    'Please select a payment method.': 'Seleziona un metodo di pagamento.',
    'Please select a shipping method.': 'Seleziona un metodo di spedizione.',
    'Proceed to checkout': 'Procedi al checkout',
    'Retry': 'Riprova',
    'Save': 'Salva',
    'Saving...': 'Salvataggio...',
    'Select address: %alias%': 'Seleziona indirizzo: %alias%',
    'State': 'Provincia',
    'This action will remove the selected address from your checkout.': 'L\'indirizzo selezionato verrà rimosso dal checkout.',
    'Unable to delete address.': 'Impossibile eliminare l\'indirizzo.',
    'Unable to initialize checkout customer.': 'Impossibile avviare il checkout per questo cliente.',
    'Unable to initialize the selected payment method.': 'Impossibile avviare il metodo di pagamento scelto.',
    'Unable to load address fields.': 'Impossibile caricare i campi dell\'indirizzo.',
    'Unable to load delivery methods.': 'Impossibile caricare i metodi di spedizione.',
    'Unable to load payment methods.': 'Impossibile caricare i metodi di pagamento.',
    'Unable to load states.': 'Impossibile caricare le province.',
    'Unable to load the requested address.': 'Impossibile caricare l\'indirizzo richiesto.',
    'Unable to refresh addresses.': 'Impossibile aggiornare gli indirizzi.',
    'Unable to resolve checkout customer.': 'Impossibile recuperare il cliente.',
    'Unable to resolve the current cart.': 'Impossibile recuperare il carrello.',
    'Unable to resolve the current delivery address.': 'Impossibile recuperare l\'indirizzo di consegna.',
    'Unable to save address.': 'Impossibile salvare l\'indirizzo.',
    'Unable to select the delivery method.': 'Impossibile selezionare il metodo di spedizione.',
    'Unable to select the payment method.': 'Impossibile selezionare il metodo di pagamento.',
    'Unable to submit checkout.': 'Impossibile inviare l\'ordine.',
    'Unable to synchronize cart customer link.': 'Impossibile collegare il carrello al cliente.',
    'Unable to update guest email.': 'Impossibile aggiornare l\'email dell\'ospite.',
    'Unfortunately, there are no carriers available for your delivery address.': 'Purtroppo non ci sono corrieri disponibili per il tuo indirizzo di consegna.',
    'Unfortunately, there are no payment method available.': 'Purtroppo non ci sono metodi di pagamento disponibili.',
    'Use a different delivery address': 'Usa un indirizzo di consegna diverso',
    'Use the same address for invoice': 'Usa lo stesso indirizzo per la fattura',
    'Use this address for invoice too': 'Usa questo indirizzo anche per la fattura',
    'Write a comment about this order': 'Scrivi una nota sull\'ordine',
    'Write your comment...': 'Scrivi qui la tua nota...',
    "You will see the available delivery methods once you've entered your delivery address.": 'Vedrai i metodi di spedizione disponibili dopo aver inserito l\'indirizzo di consegna.',
    "You will see the available payment methods once you've entered your delivery address.": 'Vedrai i metodi di pagamento disponibili dopo aver inserito l\'indirizzo di consegna.',
}

UNIT = re.compile(r'<trans-unit id="([^"]+)"[^>]*>\s*<source>(.*?)</source>', re.S)


def main() -> int:
    missing = []
    for src in sorted(DATA.glob('Modules*Shop.en-US.xlf')):
        domain = src.name.split('.')[0]
        units = []
        for uid, raw in UNIT.findall(src.read_text(encoding='utf-8')):
            source = html.unescape(raw)
            if source not in IT:
                missing.append(source)
                continue
            units.append(
                f'      <trans-unit id="{uid}">\n'
                f'        <source>{escape(source)}</source>\n'
                f'        <target>{escape(IT[source])}</target>\n'
                f'      </trans-unit>\n'
            )
        out = OUT / f'{domain}.it-IT.xlf'
        out.write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<xliff xmlns="urn:oasis:names:tc:xliff:document:1.2" version="1.2">\n'
            '  <file original="modules/ps_onepagecheckout" source-language="en-US" target-language="it-IT" datatype="plaintext">\n'
            f'    <body>\n{"".join(units)}    </body>\n  </file>\n</xliff>\n',
            encoding='utf-8',
        )
        print(f'{out.relative_to(ROOT)}: {len(units)} wordings')
    if missing:
        print('Missing Italian translations:', *sorted(set(missing)), sep='\n  ')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
