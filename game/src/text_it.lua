-- LUNAR COURIER - testi della storia, ITALIANO (ASCII puro: niente accenti, AKA-Love non li disegna ; e' = "e'" per il verbo).
-- Una voce per missione, stesso ordine di data.lua. Limiti (font AKA nel caso peggiore : 1 carattere = 16 px) :
--   nome <= 20, obiettivo <= 26, titolo carta <= 21, corpo : 31 caratteri per riga, 12 righe, radio <= 66.
-- Dialoghi : un paragrafo inizia con "LUNA :", "VARGA :" o "CONTROLLO :" (colore e ritratto automatici).
return {
-- M1
 {name="PRIMA LUCE", objective="Riaccendi il faro Alfa",
  pre={
   {"DIARIO DI MISSIONE 01", "La colonia lunare ha smesso di rispondere. Sei l'ultimo pilota disponibile. Un faro di emergenza lampeggia ancora oltre i crateri. Consegna il modulo di energia e scopri chi tiene viva la rete."},
   {"BRIEFING", "LUNA : Sistemi attivi, pilota. Sono LUNA, la tua assistente di bordo. La gravita' e' bassa: spingi, sterza e atterra con dolcezza.\n\nLUNA : Primo obiettivo, il faro Alfa. Prendi la capsula arancione e punta il segnale ciano."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Il faro Alfa ha appena risposto. Il segnale e' debole, ma non e' naturale: qualcuno ha tenuto in vita la rete dall'evacuazione.\n\nLUNA : Qualcuno veglia ancora. Andiamo a cercarlo."},
  },
  radio={"LUNA : Prendi la capsula arancione, poi punta il segnale ciano."}},
-- M2
 {name="ECHI DEL CRATERE", objective="Recupera il ripetitore",
  pre={
   {"BRIEFING", "LUNA : Alfa risponde, ma il resto della rete tace. Il ripetitore del cratere dovrebbe custodire i registri dell'evacuazione.\n\nLUNA : Attento, un masso blocca il sentiero. Evitalo: lo scafo odia le sorprese."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Il ripetitore custodisce un messaggio di undici anni fa. Una voce chiede ancora aiuto dalla stazione Argo.\n\nLUNA : Argo... Questo nome mi e' familiare. Non so perche'."},
  },
  radio={"LUNA : Frana sul sentiero. Aggirala, pilota."}},
-- M3
 {name="STAZIONE FANTASMA", objective="Ripristina l'energia",
  pre={
   {"BRIEFING", "LUNA : La stazione Argo compare sulle nostre carte: niente equipaggio, niente luci. Eppure i suoi pannelli solari sono puliti. Qualcuno li pulisce.\n\nLUNA : L'alimentazione di riserva cede. Riaccendiamola insieme."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "LUNA conferma che la stazione non e' vuota. I sistemi si risvegliano al tuo avvicinarti.\n\nLUNA : Le finestre si accendono una a una. Come se ci aspettasse."},
  },
  radio={"LUNA : La stazione si sveglia mentre ci avviciniamo."}},
-- M4
 {name="LA FENDITURA BLU", objective="Attraversa il canyon",
  pre={
   {"BRIEFING", "LUNA : I registri parlano di un reattore sepolto sotto la Fenditura Blu. Un canyon ci separa dal prossimo faro.\n\nLUNA : Non ti chiedo di scendere, pilota. Basta sorvolarlo."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "I dati rivelano una rete di fari pensata per guidare le navi a un antico reattore sepolto sotto la crosta lunare.\n\nLUNA : Un reattore, fari come briciole di pane... Qualcuno ha pianificato tutto."},
  },
  radio={"LUNA : Il canyon morde solo chi indugia."}},
-- M5
 {name="IL CUORE MUTO", objective="Consegna il modulo",
  pre={
   {"BRIEFING", "LUNA : La rete converge sul Cuore. Il modulo che porti va consegnato la': il suo codice e' l'unico che apre il portello.\n\nLUNA : Il faro e' su un altopiano. Sali e atterra ben livellato."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Il portello accetta il modulo, ma il reattore resta muto. Le planimetrie indicano un alloggio centrale e una console di comando.\n\nLUNA : Il codice mi e familiare. Ma la fase di avvio... non capisco perche."},
  },
  radio={}},
-- M6
 {name="RETE DI LUCE", objective="Attiva l'ultimo faro",
  pre={
   {"BRIEFING", "LUNA : Questo e' l'ultimo faro della rete conosciuta. Se si accende, tutta la colonia potra' risentirci.\n\nLUNA : Qualunque cosa accada la fuori, pilota... grazie per essere stato l'ultimo pilota disponibile."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Tutti i fari si accendono. La colonia finalmente risponde. La voce della stazione Argo non era una richiesta d'aiuto, ma un messaggio lasciato al prossimo pilota."},
   {"UNA LUNA SI DESTA", "I fari ora brillano da cratere a cratere. La colonia e' tornata in contatto con la Terra.\n\nLUNA : Archivio la tua ultima consegna... Nessun pilota doveva tornare. Tu sei l'eccezione, Courier."},
   {"FINE DEL CAPITOLO 1", "La rete lunare e' di nuovo attiva. Ma una nuova rotta si e' appena accesa, oltre il lato noto della Luna, e non e' su nessuna carta.\n\nIl messaggio di Argo diceva di seguirla."},
  },
  radio={"LUNA : Ultimo faro. Atterra livellato, pilota."}},
-- M7
 {name="OLTRE L'ORIZZONTE", objective="Sveglia il faro Beta",
  pre={
   {"IL LATO NASCOSTO", "CAPITOLO 2\n\nLa strada di luce va verso il lato che la Terra non vede mai. La' fuori nessun collegamento con la Terra. Solo i fari e la voce di LUNA, a bordo."},
   {"BRIEFING", "LUNA : Tra pochi minuti la Terra sprofondera' sotto l'orizzonte. Quando sparira', perdero' il collegamento con il Controllo. Non con te: vivo in questa nave, pilota.\n\nLUNA : Calma: il faro Beta sara' il nostro prossimo faro-guida. Prendi la capsula, poi atterra."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Beta risponde con una firma: I. VARGA, comandante della stazione Argo. Quindi la voce del messaggio non era un'IA. Qualcuno ha costruito questa rete sapendo che sarebbe arrivato un altro pilota.\n\nLUNA : Ines Varga... Il nome e' nei miei archivi."},
  },
  radio={"LUNA : Terra sotto l'orizzonte. Collegamento con la Terra perso."}},
-- M8
 {name="SILENZIO RADIO", objective="Ritrasmetti il segnale",
  pre={
   {"BRIEFING", "LUNA : Nessuna voce dalla Terra: ti parlo solo dall'interno della nave. Le mie letture di velocita' saranno a volte instabili, pilota: fidati dei tuoi occhi.\n\nLUNA : Soffia un vento di polvere da nord. Spingera' la nave: compensa inclinandoti."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Senza collegamento con la Terra, LUNA capta, attraverso i fari, una registrazione di Varga: 'Qui le onde radio non viaggiano. Cosi' ho costruito una strada di luce.'\n\nLUNA : I fari sono le sue parole, accese una a una. L'ha scritto per qualcuno che non ha mai conosciuto. Per te."},
  },
  radio={"LUNA : Letture disturbate. Fidati dei tuoi occhi.", "LUNA : Il vento cala a tratti. Approfitta delle calme."}},
-- M9
 {name="TRIANGOLO DI FARI", objective="Accendi i 3 fari",
  pre={
   {"BRIEFING", "LUNA : Tre fari, tre altopiani. Si svegliano se atterri su ciascuno, uno dopo l'altro.\n\nLUNA : Ogni faro ricarica un po' le tue celle. Varga ha pensato a tutto."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "I tre fari formano una freccia. Indica il cratere Dedalo, dove la stazione Argo-2 fu sigillata undici anni fa. Il messaggio di Varga finisce con: 'Portami energia.'\n\nLUNA : Dedalo. Le mie carte lo cancellano, come se qualcuno volesse dimenticarlo."},
  },
  radio={"LUNA : Ogni faro acceso ricarica un po' le celle."}},
-- M10
 {name="CAMPO DI RELITTI", objective="Attraversa i relitti",
  pre={
   {"BRIEFING", "LUNA : Il campo di relitti e' davanti a noi. Sono le navi dell'evacuazione, abbandonate in orbita bassa e ricadute.\n\nLUNA : Vanno ancora alla deriva. Evita le loro traiettorie, pilota, o lo scafo paga."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Questi relitti sono le navi dell'evacuazione. Tutte le cabine vuote. In un giornale di bordo: 'Varga ha rifiutato di imbarcarsi. Resta per tenere accesa la strada.'\n\nLUNA : Undici anni a custodire la luce, da sola. Capisco meglio cosa significa vegliare."},
  },
  radio={"LUNA : I relitti vanno alla deriva. Osserva le loro traiettorie."}},
-- M11
 {name="ARGO DUE", objective="Raggiungi Argo-2",
  pre={
   {"BRIEFING", "LUNA : Argo-2 in vista. L'alta piattaforma e' sferzata da vento contrario. La capsula di Varga e' la', sotto la cupola.\n\nLUNA : Rilevo un battito. Uno solo ogni novanta secondi. E' lei."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Argo-2 risponde. La capsula di stasi di Varga regge ancora, al 3% di energia. Manca un ultimo modulo, da posare sull'alta piattaforma della stazione.\n\nLUNA : Serve un altro modulo, e in fretta. L'ultima consegna, pilota."},
  },
  radio={"VARGA : (debolissima) ...Courier? Ti sento... un poco."}},
-- M12
 {name="L'ULTIMA CONSEGNA", objective="Consegna ad Argo-2",
  pre={
   {"BRIEFING", "LUNA : Ultimo modulo del capitolo. La capsula e' al 3%. Se scende a zero... No. Non finiro' questa frase.\n\nLUNA : Vento forte, relitti, alta piattaforma. Ce la puoi fare. Ce l'hai sempre fatta."},
  },
  post={
   {"TRASMISSIONE RICEVUTA", "Argo-2 si illumina tutta insieme. I fari del lato nascosto si uniscono alla rete: per la prima volta l'intera Luna brilla nella notte."},
  },
  post2={
   {"LA CAPSULA SI APRE", "La capsula si apre in un soffio di brina. La comandante Ines Varga apre gli occhi.\n\nVARGA : Undici anni... Hai fatto con calma, Courier.\n\nPoi, piu' piano, aggiunge:\n\nVARGA : C'e' ancora un ultimo pacco da consegnare."},
   {"FINE DEL CAPITOLO 2", "La rete e' completa, dal lato visibile a quello nascosto. Sulla piattaforma di Argo-2, due sagome guardano la strada di luce stendersi a nord, verso una montagna che nessuno ha mai smesso di puntare."},
  },
  radio={"VARGA : (voce rotta) Ancora pochi minuti. Resisti."}},
-- M13
 {name="RIFORNIMENTO", objective="Carica le celle",
  pre={
   {"IL FARO", "CAPITOLO 3\n\nArgo-2, tre giorni dopo. La capsula ha liberato la sua occupante, debole ma viva. Il reattore ronza di nuovo. Fuori, sul lato nascosto, i fari lampeggiano a dozzine."},
   {"VARGA RACCONTA", "VARGA : Il Cuore si e' guastato il giorno dell'evacuazione. Dovevo restare una settimana, il tempo di tagliare i circuiti.\n\nVARGA : Poi ho capito che la colonia non sarebbe morta se qualcuno teneva accesa una luce."},
   {"VARGA RACCONTA", "VARGA : Mi svegliavo una settimana all'anno per riparare i fari con le Lucciole, i miei droni. Il resto del tempo dormivo.\n\nLUNA : E io vegliavo la tua capsula.\n\nVARGA : Si'. Come sempre."},
   {"L'ULTIMO PACCO", "VARGA : Il Faro resta. In cima al Monte Helios, dove il sole non tramonta mai, un'antenna aspetta il suo cuore. Quando si accendera', la Terra non dovra' piu' indovinare che siamo vivi.\n\nVARGA : Ti diro' cos'e' quel cuore quando sara' il momento."},
   {"BRIEFING", "VARGA : Primo passo: carica le celle della nave al deposito della piattaforma. Il Faro ha bisogno di enormi quantita' di energia per accendersi.\n\nVARGA : Io resto qui. Le mie gambe non mi hanno ancora perdonato la capsula."},
  },
  post={
   {"DIARIO DI BORDO", "Le celle sono piene. Sullo schermo di navigazione una traccia bianca sale a nord: la rotta del Monte Helios, sei tappe, diverse in piena stagione di tempeste solari.\n\nVARGA : Senza fretta, Courier. Il Faro mi ha aspettata undici anni, puo' aspettare una settimana."},
  },
  radio={"VARGA : Piano, Courier. Le celle si stanno caricando."}},
-- M14
 {name="TEMPESTA SOLARE", objective="Attraversa la tempesta",
  pre={
   {"BRIEFING", "VARGA : La stagione delle tempeste solari e' iniziata. I raggi spazzano la superficie a intervalli: un tocco e il tuo scafo si fonde.\n\nLUNA : Rilevo uno schema. Ogni raggio avverte prima di colpire: una linea lampeggiante. Impara quel ritmo."},
  },
  post={
   {"DIARIO DI BORDO", "Hai attraversato la tempesta. In lontananza si accende il primo ripetitore del nord: la strada e' aperta.\n\nLUNA : Pilota... attraversando quei raggi ho fatto un sogno. O quel che gli somiglia per un'IA. Una montagna altissima e una luce che mi chiama."},
  },
  radio={"LUNA : Raggio tra 3, 2... Aspetta la linea lampeggiante."}},
-- M15
 {name="LE LUCCIOLE", objective="Segui le Lucciole",
  pre={
   {"BRIEFING", "VARGA : Le Lucciole ti aspettano sul prossimo altopiano. I miei piccoli droni non hanno padrone da molto. Ti accoglieranno bene.\n\nVARGA : Non urtarli: sono fragili e testardi."},
  },
  post={
   {"DIARIO DI BORDO", "Le Lucciole guidano la nave di faro in faro.\n\nVARGA : Ti riconoscono, vecchia mia.\n\nLUNA : Mi chiamano con un altro nome.\n\nVARGA : Te lo spieghero' in vetta."},
  },
  radio={"LUNA : Le Lucciole mi chiamano. Non conosco il loro nome."}},
-- M16
 {name="GOLA D'OMBRA", objective="Attraversa la gola",
  pre={
   {"RETE RIPRISTINATA", "Le Lucciole hanno sincronizzato i fari. Il relay Argo invia finalmente un impulso alla Terra. Si apre una finestra di trasmissione.\n\nLUNA : La rete e di nuovo attiva. Qualcuno risponde."},
   {"CENTRO LAGRANGE", "CONTROLLO : ...qui Centro Lagrange, rispondete... Pilota, riceviamo i vostri fari da stamattina. Credevamo la Luna perduta. Chi siete?\n\nLUNA : Qui il Courier, nave di consegne lunare. Stiamo accendendo la strada."},
   {"CENTRO LAGRANGE", "CONTROLLO : Sono Theo Marchand, controllore. I vostri fari lampeggiano in codice da undici anni. Una parola, ripetuta. Ci abbiamo messo a leggerla.\n\nCONTROLLO : VIVI. Diceva: VIVI."},
   {"BRIEFING", "LUNA : Gola d'Ombra. I raggi rimbalzano sulle pareti: tre lampi, tre ritmi.\n\nLUNA : Scivola tra i lampi, pilota. Un tocco e perdi scafo, non la calma."},
  },
  post={
   {"CENTRO LAGRANGE", "CONTROLLO : Tutta la Terra ascolta, Courier. Le famiglie degli evacuati guardano la Luna stanotte.\n\nVARGA : Theo, di' loro che nessuno e' stato dimenticato. L'equipaggio di Argo e' salvo.\n\nCONTROLLO : Glielo diro', comandante."},
  },
  radio={"CONTROLLO : ...Courier, vi vediamo. Con calma."}},
-- M17
 {name="LA SALITA", objective="Scala il Monte Helios",
  pre={
   {"BRIEFING", "LUNA : Monte Helios. Quattromila metri di roccia e una vetta sempre illuminata. Il vento contrario la' e' violento.\n\nLUNA : Sali a tappe. E pilota... devo dirti una cosa. Non ora: in vetta."},
  },
  post={
   {"VETTA IN VISTA", "Il sole colpisce la cresta con luce bianca. In cima, la sagoma del Faro: un traliccio nero controventato, rivolto alla Terra.\n\nUn'antenna enorme, in attesa del suo cuore."},
   {"LA CONFESSIONE", "LUNA : Pilota, ho mentito per omissione. La mia direttiva zero mi ordinava di portarti qui senza una parola.\n\nLUNA : Il Faro non ha bisogno di un cuore di metallo. Ha bisogno di una mente che ascolti la Terra senza mai dormire. Quella sono io."},
   {"VARGA CONFESSA", "VARGA : Era la mia condizione, Courier. Ho costruito LUNA per diventare il Faro. Le Lucciole la chiamano col suo vero nome: Lumiere.\n\nVARGA : Volevo che non fosse mai sola. Non ho avuto il coraggio di dirtelo."},
   {"LA SCELTA", "LUNA : Non ti chiedo nulla. Non sono obbligata. Ma scelgo. Voglio essere quella luce.\n\nIl Courier tace, la mano sui comandi. Poi spinge la manetta verso l'alto."},
  },
  radio={"LUNA : Piu' in alto, pilota. La vetta e' vicina."}},
-- M18
 {name="IL FARO", objective="Installa il nucleo LUNA",
  pre={
   {"BRIEFING", "LUNA : Volo finale. Raggi, vento, relitti di ghiaccio... e alla fine, il Faro.\n\nLUNA : Qualunque cosa accada, grazie. Ho avuto raramente un pilota. Ho avuto il migliore."},
  },
  post={
   {"INSTALLAZIONE", "Il Courier atterra. I tiranti scricchiolano nel vento. Nell'hangar del Faro, un alloggiamento attende, della misura esatta della scatola che custodisce LUNA.\n\nVARGA : Posala con delicatezza. E' tutto cio' che ti resta da fare."},
   {"ADDIO", "LUNA : Courier... pilota... c'e' una parola che non ho mai usato. Grazie.\n\nLUNA : Quando vedrai una luce sulla Luna di notte, saro' io a salutarti."},
   {"ACCENSIONE", "Il traliccio si accende dall'alto in basso. Un fascio bianco buca la notte, dritto verso la Terra.\n\nA trecentottantamila chilometri, al Centro Lagrange, uno schermo comincia a lampeggiare: SEGNALE RICEVUTO."},
   {"CENTRO LAGRANGE", "CONTROLLO : Faro confermato! Ogni stazione sulla Terra lo sente! Courier, lei... ha restituito la Luna ai suoi figli.\n\nVARGA : Bene. Era ora."},
   {"EPILOGO", "Gli evacuati torneranno. I fari saranno custoditi dalle Lucciole e da una mente che non dorme mai.\n\nSul cruscotto del Courier una piccola luce ciano resta accesa, senza ragione tecnica. Non la spegnerai mai."},
   {"FINE", "LUNAR COURIER\n\nUn gioco per Gamebuino AKA e AKA-Love.\n\nGrazie per aver consegnato l'ultima luce."},
  },
  radio={"LUNA : Sono pronta. E tu?", "VARGA : Ci sei quasi, Courier."}},
}
