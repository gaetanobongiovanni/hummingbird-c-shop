# cshopcod — contrassegno con supplemento

Sostituisce `ps_cashondelivery`. Supplemento = importo fisso + percentuale del totale
ordine (spedizione e IVA incluse); default 2,50 € + 1,4%, modificabili in Configura.

Il supplemento entra nell'ordine come prodotto virtuale nascosto **"Spese contrassegno"**
(riferimento `CSHOPCOD-FEE`, visibilità "da nessuna parte", IVA = regola più usata dal
catalogo) con un prezzo specifico legato al solo carrello: compare come riga a sé in
ordine, fattura ed email. Il prodotto non va cancellato (gli ordini lo citano).

## Installazione
1. `npm run zip:cod` → `dist/cshopcod-<versione>.zip`, poi Moduli › Carica un modulo.
2. Controlla in Catalogo › Prodotti "Spese contrassegno": regola IVA corretta (22%).
3. Pagamento › Preferenze: valute/paesi/gruppi/corrieri come il contrassegno attuale.
4. Disattiva `ps_cashondelivery` (lo stato ordine "In attesa di verifica contrassegno" resta).
5. Ordine di prova in contrassegno: verifica riga supplemento, totale e fattura.

Test: `npm run test:cod`.
