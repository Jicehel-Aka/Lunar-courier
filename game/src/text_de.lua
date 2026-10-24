-- LUNAR COURIER - Geschichtstexte, DEUTSCH (reines ASCII: ae/oe/ue/ss statt Umlaute, AKA-Love zeichnet keine Akzente).
-- Ein Eintrag pro Mission, gleiche Reihenfolge wie data.lua. Grenzen (AKA-Schrift im schlimmsten Fall : 1 Zeichen = 16 px) :
--   Name <= 20, Ziel <= 26, Kartentitel <= 21, Text : 31 Zeichen pro Zeile, 12 Zeilen, Funk <= 66.
-- Dialoge : Absatz beginnt mit "LUNA :", "VARGA :" oder "KONTROLLE :" (Farbe und Portrait automatisch).
return {
-- M1
 {name="ERSTES LICHT", objective="Alpha-Bake neu zuenden",
  pre={
   {"MISSIONSLOG 01", "Die Mondkolonie antwortet nicht mehr. Du bist der letzte verfuegbare Pilot. Jenseits der Krater blinkt noch eine Notbake. Bring das Energiemodul hin und finde heraus, wer das Netz am Leben haelt."},
   {"BRIEFING", "LUNA : Systeme aktiv, Pilot. Ich bin LUNA, deine Bordassistentin. Die Schwerkraft ist gering: Schub geben, lenken, sanft landen.\n\nLUNA : Erstes Ziel, die Alpha-Bake. Nimm die orange Kapsel und steuere die cyanfarbene Markierung an."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Die Alpha-Bake hat gerade geantwortet. Das Signal ist schwach, aber nicht natuerlich: Jemand hat das Netz seit der Evakuierung am Laufen gehalten.\n\nLUNA : Jemand wacht noch. Suchen wir ihn."},
  },
  radio={"LUNA : Nimm die orange Kapsel, dann flieg die Cyan-Marke an."}},
-- M2
 {name="KRATERECHOS", objective="Relais bergen",
  pre={
   {"BRIEFING", "LUNA : Alpha antwortet, aber der Rest des Netzes schweigt. Das Kraterrelais sollte die Evakuierungsprotokolle enthalten.\n\nLUNA : Vorsicht, ein Felsbrocken versperrt den Weg. Weich aus: Die Huelle hasst Ueberraschungen."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Das Relais enthaelt eine elf Jahre alte Nachricht. Eine Stimme bittet noch immer von der Station Argo um Hilfe.\n\nLUNA : Argo... Der Name kommt mir bekannt vor. Ich weiss nicht, warum."},
  },
  radio={"LUNA : Steinschlag auf dem Weg. Flieg drumherum, Pilot."}},
-- M3
 {name="GEISTERSTATION", objective="Strom wiederherstellen",
  pre={
   {"BRIEFING", "LUNA : Die Station Argo erscheint auf unseren Karten: keine Crew, kein Licht. Doch ihre Solarpaneele sind sauber. Jemand putzt sie.\n\nLUNA : Die Notstromversorgung versagt. Zuenden wir sie gemeinsam wieder."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "LUNA bestaetigt, dass die Station nicht leer ist. Die Systeme erwachen, als du dich naeherst.\n\nLUNA : Die Fenster gehen eins nach dem anderen an. Als haette sie auf uns gewartet."},
  },
  radio={"LUNA : Die Station erwacht, je naeher wir kommen."}},
-- M4
 {name="DER BLAUE RISS", objective="Schlucht ueberqueren",
  pre={
   {"BRIEFING", "LUNA : Die Logs erwaehnen einen Reaktor unter dem Blauen Riss. Eine Schlucht trennt uns von der naechsten Bake.\n\nLUNA : Ich verlange nicht, dass du hinabsteigst, Pilot. Drueberfliegen genuegt."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Die Daten enthuellen ein Baken-Netz, das Schiffe zu einem uralten Reaktor unter der Mondkruste lotsen soll.\n\nLUNA : Ein Reaktor, Baken wie eine Brotkrumenspur... Jemand hat alles geplant."},
  },
  radio={"LUNA : Die Schlucht beisst nur, wer troedelt."}},
-- M5
 {name="DAS STILLE HERZ", objective="Modul abliefern",
  pre={
   {"BRIEFING", "LUNA : Das Netz laeuft im Herz zusammen. Das Modul, das du traegst, muss dort abgeliefert werden: Sein Code oeffnet als einziger die Schleuse.\n\nLUNA : Die Bake steht auf einem Plateau. Steig auf und lande schoen waagerecht."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Die Schleuse nimmt das Modul an, doch der Reaktor bleibt stumm. Die Plaene zeigen einen zentralen Schacht und eine Kommandokonsole.\n\nLUNA : Der Code kommt mir bekannt vor. Aber die Startphase... ich verstehe nicht, warum."},
  },
  radio={}},
-- M6
 {name="NETZ AUS LICHT", objective="Letzte Bake aktivieren",
  pre={
   {"BRIEFING", "LUNA : Das ist die letzte Bake des bekannten Netzes. Wenn sie leuchtet, kann uns die ganze Kolonie wieder hoeren.\n\nLUNA : Was auch passiert, Pilot... danke, dass du der letzte verfuegbare Pilot warst."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Alle Baken leuchten auf. Die Kolonie antwortet endlich. Die Stimme der Station Argo war kein Hilferuf, sondern eine Nachricht an den naechsten Piloten."},
   {"EIN MOND ERWACHT", "Die Baken leuchten nun von Krater zu Krater. Die Kolonie hat wieder Kontakt zur Erde.\n\nLUNA : Archiviere deine letzte Lieferung... Kein Pilot sollte je zurueckkehren. Du bist die Ausnahme, Courier."},
   {"ENDE VON KAPITEL 1", "Das Mondnetz ist wieder aktiv. Doch jenseits der bekannten Mondseite hat eine neue Route aufgeleuchtet, auf keiner Karte.\n\nArgos Nachricht sagte, ihr zu folgen."},
  },
  radio={"LUNA : Letzte Bake. Lande waagerecht, Pilot."}},
-- M7
 {name="JENSEITS DES RANDS", objective="Beta-Bake wecken",
  pre={
   {"DIE RUECKSEITE", "KAPITEL 2\n\nDie Strasse aus Licht fuehrt zur Seite, die die Erde nie sieht. Dort draussen keine Verbindung zur Erde. Nur die Baken und LUNAs Stimme an Bord."},
   {"BRIEFING", "LUNA : In wenigen Minuten versinkt die Erde hinter dem Horizont. Wenn sie verschwindet, verliere ich die Verbindung zur Kontrolle. Nicht zu dir: Ich lebe in diesem Schiff, Pilot.\n\nLUNA : Keine Panik: Die Beta-Bake wird unser naechster Leuchtturm. Nimm die Kapsel, dann lande."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Beta antwortet mit einer Signatur: I. VARGA, Kommandantin der Station Argo. Die Stimme der Nachricht war also keine KI. Jemand baute dieses Netz im Wissen, dass ein weiterer Pilot kommt.\n\nLUNA : Ines Varga... Der Name steht in meinen Archiven."},
  },
  radio={"LUNA : Erde unter dem Horizont. Erdverbindung verloren."}},
-- M8
 {name="FUNKSTILLE", objective="Signal weiterleiten",
  pre={
   {"BRIEFING", "LUNA : Keine Stimme mehr von der Erde: Ich spreche nur noch aus dem Schiff. Meine Geschwindigkeitswerte sind manchmal instabil, Pilot: Vertrau deinen Augen.\n\nLUNA : Ein Staubwind weht von Norden. Er drueckt das Schiff: Gleiche durch Neigen aus."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Ohne Verbindung zur Erde faengt LUNA ueber die Baken eine Aufnahme von Varga auf: 'Hier tragen Funkwellen nicht. Also baute ich eine Strasse aus Licht.'\n\nLUNA : Die Baken sind ihre Worte, eins nach dem anderen entzuendet. Sie schrieb das fuer jemanden, den sie nie traf. Fuer dich."},
  },
  radio={"LUNA : Meine Werte sind gestoert. Vertrau deinen Augen.", "LUNA : Der Wind laesst manchmal nach. Nutze die Flauten."}},
-- M9
 {name="BAKEN-DREIECK", objective="3 Baken zuenden",
  pre={
   {"BRIEFING", "LUNA : Drei Baken, drei Plateaus. Sie erwachen, wenn du nacheinander auf jeder landest.\n\nLUNA : Jede Bake laedt deine Zellen ein wenig auf. Varga hat an alles gedacht."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Die drei Baken bilden einen Pfeil. Er zeigt auf den Krater Daedalus, wo die Station Argo-2 vor elf Jahren versiegelt wurde. Vargas Nachricht endet mit: 'Bring mir Strom.'\n\nLUNA : Daedalus. Meine Karten loeschen ihn, als wolle jemand ihn vergessen."},
  },
  radio={"LUNA : Jede entzuendete Bake laedt die Zellen ein wenig auf."}},
-- M10
 {name="WRACKFELD", objective="Wracks durchqueren",
  pre={
   {"BRIEFING", "LUNA : Das Wrackfeld liegt voraus. Es sind die Evakuierungsschiffe, im niedrigen Orbit aufgegeben und zurueckgestuerzt.\n\nLUNA : Sie treiben noch. Meide ihre Bahnen, Pilot, sonst zahlt die Huelle."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Diese Wracks sind die Evakuierungsschiffe. Alle Kabinen leer. In einem Logbuch: 'Varga weigerte sich einzusteigen. Sie bleibt, um die Strasse beleuchtet zu halten.'\n\nLUNA : Elf Jahre das Licht gehalten, allein. Ich verstehe besser, was Wachen heisst."},
  },
  radio={"LUNA : Die Wracks treiben. Achte auf ihre Bahnen."}},
-- M11
 {name="ARGO ZWEI", objective="Argo-2 erreichen",
  pre={
   {"BRIEFING", "LUNA : Argo-2 in Sicht. Die hohe Plattform wird von Gegenwind gepeitscht. Vargas Kapsel steht dort, unter der Kuppel.\n\nLUNA : Ich registriere einen Herzschlag. Nur einen alle neunzig Sekunden. Sie ist es."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Argo-2 antwortet. Vargas Stasiskapsel haelt noch, bei 3% Energie. Ein letztes Modul fehlt, es gehoert auf die hohe Plattform der Station.\n\nLUNA : Wir brauchen ein weiteres Modul, und zwar schnell. Die letzte Lieferung, Pilot."},
  },
  radio={"VARGA : (sehr leise) ...Courier? Ich hoere dich... ein wenig."}},
-- M12
 {name="DIE LETZTE LIEFERUNG", objective="Argo-2 beliefern",
  pre={
   {"BRIEFING", "LUNA : Letztes Modul des Kapitels. Die Kapsel steht bei 3%. Faellt sie auf null... Nein. Den Satz beende ich nicht.\n\nLUNA : Starker Wind, Wracks, hohe Plattform. Du schaffst das. Das konntest du immer."},
  },
  post={
   {"NACHRICHT EMPFANGEN", "Argo-2 leuchtet mit einem Schlag auf. Die Baken der Rueckseite schliessen sich dem Netz an: Zum ersten Mal strahlt der ganze Mond in der Nacht."},
  },
  post2={
   {"KAPSEL OEFFNET SICH", "Die Kapsel oeffnet sich in einem Hauch von Frost. Kommandantin Ines Varga schlaegt die Augen auf.\n\nVARGA : Elf Jahre... Du hast dir Zeit gelassen, Courier.\n\nDann fuegt sie leiser hinzu:\n\nVARGA : Ein letztes Paket ist noch zu liefern."},
   {"ENDE VON KAPITEL 2", "Das Netz ist vollstaendig, von der Vorder- bis zur Rueckseite. Auf der Plattform von Argo-2 sehen zwei Silhouetten die Lichterstrasse nach Norden laufen, zu einem Berg, den nie jemand aus dem Blick verlor."},
  },
  radio={"VARGA : (bruechig) Nur noch wenige Minuten. Halt durch."}},
-- M13
 {name="AUFTANKEN", objective="Zellen aufladen",
  pre={
   {"DER LEUCHTTURM", "KAPITEL 3\n\nArgo-2, drei Tage spaeter. Die Kapsel hat ihre Insassin freigegeben, schwach, aber lebendig. Der Reaktor summt wieder. Draussen auf der Rueckseite blinken Baken zu Dutzenden."},
   {"VARGA ERZAEHLT", "VARGA : Das Herz versagte am Evakuierungstag. Ich sollte eine Woche bleiben, nur um die Kreise zu kappen.\n\nVARGA : Dann begriff ich, dass die Kolonie nicht stirbt, wenn jemand ein Licht anlaesst."},
   {"VARGA ERZAEHLT", "VARGA : Ich erwachte eine Woche im Jahr, um die Baken mit den Gluehwuermchen, meinen Drohnen, zu reparieren. Die restliche Zeit schlief ich.\n\nLUNA : Und ich wachte ueber deine Kapsel.\n\nVARGA : Ja. Wie immer."},
   {"DAS LETZTE PAKET", "VARGA : Der Leuchtturm bleibt. Auf dem Gipfel des Mount Helios, wo die Sonne nie untergeht, wartet eine Antenne auf ihr Herz. Wenn sie leuchtet, muss die Erde nicht mehr raten, dass wir leben.\n\nVARGA : Was dieses Herz ist, sage ich dir, wenn es soweit ist."},
   {"BRIEFING", "VARGA : Erster Schritt: Lade die Zellen des Schiffs am Depot der Plattform. Der Leuchtturm braucht enorm viel Energie zum Zuenden.\n\nVARGA : Ich bleibe hier. Meine Beine haben mir die Kapsel noch nicht verziehen."},
  },
  post={
   {"BORDBUCH", "Die Zellen sind voll. Auf dem Navigationsschirm klettert eine weisse Spur nach Norden: die Route zum Mount Helios, sechs Etappen, mehrere mitten in der Sonnensturmzeit.\n\nVARGA : Keine Hast, Courier. Der Leuchtturm hat elf Jahre auf mich gewartet, er wartet auch eine Woche."},
  },
  radio={"VARGA : Ruhig, Courier. Die Zellen laden."}},
-- M14
 {name="SONNENSTURM", objective="Sturm durchqueren",
  pre={
   {"BRIEFING", "VARGA : Die Sonnensturmzeit hat begonnen. Strahlen fegen in Abstaenden ueber die Oberflaeche: eine Beruehrung, und deine Huelle schmilzt.\n\nLUNA : Ich erkenne ein Muster. Jeder Strahl warnt vor dem Schlag: eine blinkende Linie. Lerne diesen Rhythmus."},
  },
  post={
   {"BORDBUCH", "Du hast den Sturm durchquert. In der Ferne leuchtet das erste Relais im Norden auf: Der Weg ist frei.\n\nLUNA : Pilot... beim Durchqueren der Strahlen hatte ich einen Traum. Oder das, was einer KI am naechsten kommt. Ein sehr hoher Berg und ein Licht, das mich ruft."},
  },
  radio={"LUNA : Strahl in 3, 2... Warte auf die blinkende Linie."}},
-- M15
 {name="DIE GLUEHWUERMCHEN", objective="Gluehwuermchen folgen",
  pre={
   {"BRIEFING", "VARGA : Die Gluehwuermchen warten auf dich auf dem naechsten Plateau. Meine kleinen Drohnen haben lange keinen Meister. Sie werden dich willkommen heissen.\n\nVARGA : Stoss nicht mit ihnen zusammen: Sie sind zerbrechlich und stur."},
  },
  post={
   {"BORDBUCH", "Die Gluehwuermchen lotsen das Schiff von Bake zu Bake.\n\nVARGA : Sie erkennen dich, altes Maedchen.\n\nLUNA : Sie nennen mich bei einem anderen Namen.\n\nVARGA : Ich erklaere es auf dem Gipfel."},
  },
  radio={"LUNA : Die Gluehwuermchen rufen mich. Ich kenne ihren Namen nicht."}},
-- M16
 {name="SCHATTENSCHLUCHT", objective="Schlucht durchqueren",
  pre={
   {"NETZ WIEDER AKTIV", "Die Leuchtkaefer synchronisierten die Baken. Relais Argo sendet endlich einen Impuls zur Erde. Ein Sendefenster ist offen.\n\nLUNA : Das Netz ist wieder aktiv. Jemand antwortet."},
   {"ZENTRUM LAGRANGE", "KONTROLLE : ...hier Zentrum Lagrange, bitte melden... Pilot, wir empfangen deine Baken seit heute Morgen. Wir hielten den Mond fuer verloren. Wer bist du?\n\nLUNA : Hier der Courier, Lieferschiff des Mondes. Wir zuenden die Strasse."},
   {"ZENTRUM LAGRANGE", "KONTROLLE : Hier Theo Marchand, Fluglotse. Deine Baken blinken seit elf Jahren im Code. Ein Wort, immer wieder. Wir brauchten lange, es zu lesen.\n\nKONTROLLE : LEBEND. Es hiess: LEBEND."},
   {"BRIEFING", "LUNA : Schattenschlucht. Die Strahlen prallen von den Waenden ab: drei Blitze, drei Rhythmen.\n\nLUNA : Schluepfe zwischen den Blitzen durch, Pilot. Eine Beruehrung kostet Huelle, nicht die Ruhe."},
  },
  post={
   {"ZENTRUM LAGRANGE", "KONTROLLE : Die ganze Erde hoert zu, Courier. Die Familien der Evakuierten sehen heute Nacht zum Mond.\n\nVARGA : Theo, sag ihnen, niemand wurde vergessen. Die Crew von Argo ist wohlauf.\n\nKONTROLLE : Mache ich, Kommandantin."},
  },
  radio={"KONTROLLE : ...Courier, wir sehen dich. Immer mit der Ruhe."}},
-- M17
 {name="DER AUFSTIEG", objective="Mount Helios besteigen",
  pre={
   {"BRIEFING", "LUNA : Mount Helios. Viertausend Meter Fels und ein ewig beleuchteter Gipfel. Der Gegenwind dort ist heftig.\n\nLUNA : Steig in Etappen auf. Und Pilot... ich muss dir etwas sagen. Nicht jetzt: auf dem Gipfel."},
  },
  post={
   {"GIPFEL IN SICHT", "Die Sonne trifft den Grat mit weissem Licht. Ganz oben die Silhouette des Leuchtturms: ein schwarzer, abgespannter Mast, der Erde zugewandt.\n\nEine riesige Antenne, die auf ihr Herz wartet."},
   {"DAS GESTAENDNIS", "LUNA : Pilot, ich habe durch Verschweigen gelogen. Meine Direktive Null befahl mir, dich ohne ein Wort hierher zu bringen.\n\nLUNA : Der Leuchtturm braucht kein Herz aus Metall. Er braucht einen Geist, der die Erde hoert und nie schlaeft. Das bin ich."},
   {"VARGA GESTEHT", "VARGA : Das war meine Bedingung, Courier. Ich baute LUNA, um der Leuchtturm zu werden. Die Gluehwuermchen nennen sie bei ihrem wahren Namen: Lumiere.\n\nVARGA : Ich wollte, dass sie nie allein ist. Mir fehlte der Mut, es dir zu sagen."},
   {"DIE WAHL", "LUNA : Ich verlange nichts von dir. Ich bin zu nichts verpflichtet. Aber ich waehle. Ich will dieses Licht sein.\n\nDer Courier schweigt, die Hand an den Reglern. Dann schiebt er den Schub nach oben."},
  },
  radio={"LUNA : Hoeher, Pilot. Der Gipfel ist nah."}},
-- M18
 {name="DER LEUCHTTURM", objective="LUNA-Kern einbauen",
  pre={
   {"BRIEFING", "LUNA : Letzter Flug. Strahlen, Wind, Eiswracks... und am Ende der Leuchtturm.\n\nLUNA : Was auch geschieht, danke. Ich hatte selten einen Piloten. Ich hatte den besten."},
  },
  post={
   {"EINBAU", "Der Courier landet. Die Abspannseile knarren im Wind. In der Bucht des Leuchtturms wartet eine Fassung, genau so gross wie das Gehaeuse, das LUNA birgt.\n\nVARGA : Setz es sanft ab. Es ist alles, was dir noch bleibt."},
   {"ABSCHIED", "LUNA : Courier... Pilot... es gibt ein Wort, das ich nie benutzt habe. Danke.\n\nLUNA : Wenn du nachts ein Licht auf dem Mond siehst, bin ich es und sage hallo."},
   {"ZUENDUNG", "Der Mast leuchtet von oben nach unten auf. Ein weisser Strahl durchbohrt die Nacht, geradewegs zur Erde.\n\nDreihundertachtzigtausend Kilometer entfernt, im Zentrum Lagrange, beginnt ein Schirm zu blinken: SIGNAL EMPFANGEN."},
   {"ZENTRUM LAGRANGE", "KONTROLLE : Leuchtturm bestaetigt! Jede Station der Erde hoert ihn! Courier, du hast... du hast den Mond seinen Kindern zurueckgegeben.\n\nVARGA : Na also. Wurde Zeit."},
   {"EPILOG", "Die Evakuierten werden zurueckkehren. Die Baken werden von den Gluehwuermchen gehuetet und von einem Geist, der nie schlaeft.\n\nAuf dem Armaturenbrett des Couriers bleibt ein kleines cyanfarbenes Licht an, ohne technischen Grund. Du wirst es nie ausschalten."},
   {"ENDE", "LUNAR COURIER\n\nEin Spiel fuer Gamebuino AKA und AKA-Love.\n\nDanke, dass du das letzte Licht geliefert hast."},
  },
  radio={"LUNA : Ich bin bereit. Und du?", "VARGA : Du bist fast da, Courier."}},
}
