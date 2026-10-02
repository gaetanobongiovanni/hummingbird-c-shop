# cshopcookie — banner cookie

Banner e preferenze per i cookie facoltativi (statistiche, marketing), secondo le
linee guida del Garante del 10 giugno 2021:
- "Rifiuta" ha lo stesso peso di "Accetta tutti"; la X chiude rifiutando;
- nessun cookie wall: il sito resta navigabile;
- la scelta dura 6 mesi (cookie `cshop_consent`) e si cambia da "Preferenze cookie" nel footer
  o da qualsiasi link `href="#cookie-settings"`.

## Come si usa con gli script di terze parti
Scrivi lo script come testo, con la categoria; il modulo lo esegue solo dopo il consenso:

```html
<script type="text/plain" data-cs-consent="analytics" async src="https://www.googletagmanager.com/gtag/js?id=G-XXXX"></script>
<script type="text/plain" data-cs-consent="analytics">gtag('js', new Date()); gtag('config', 'G-XXXX');</script>
```

Google Consent Mode v2 è già impostato (default `denied`, stampato in `<head>`), quindi i tag
Google caricati normalmente rispettano comunque la scelta.

JS: `CshopConsent.get()`, `CshopConsent.has('analytics')`, `CshopConsent.open()`, evento `cshop:consent`.
PHP: `Cshopcookie::hasConsent('marketing')`.

## Configurazione
- "Mostra il banner cookie" accende o spegne il banner, indipendentemente dalle categorie.
- Attiva solo le categorie davvero usate: senza categorie il banner dice solo che il negozio usa cookie tecnici ("Ho capito").
- "Richiedi a tutti" incrementa la versione: chi aveva già scelto rivede il banner
  (da usare quando aggiungi un servizio o cambi la cookie policy).

Test: `npm run test:cookie` · Pacchetto: `npm run zip:cookie`.
