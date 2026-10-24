-- LUNAR COURIER - textos de la historia, ESPANOL (ASCII puro: sin tildes ni enie, AKA-Love no dibuja acentos).
-- Una entrada por mision, mismo orden que data.lua. Limites (fuente AKA en el peor caso : 1 caracter = 16 px) :
--   nombre <= 20, objetivo <= 26, titulo de tarjeta <= 21, cuerpo : 31 caracteres por linea, 12 lineas, radio <= 66.
-- Dialogos : un parrafo empieza por "LUNA :", "VARGA :" o "CONTROL :" (color y retrato automaticos).
return {
-- M1
 {name="PRIMERA LUZ", objective="Reenciende la baliza Alfa",
  pre={
   {"DIARIO DE MISION 01", "La colonia lunar ha dejado de responder. Eres el ultimo piloto disponible. Una baliza de emergencia aun parpadea mas alla de los crateres. Entrega el modulo de energia y descubre quien mantiene viva la red."},
   {"BRIEFING", "LUNA : Sistemas activos, piloto. Soy LUNA, tu asistente de a bordo. La gravedad es baja: acelera, gira y aterriza con suavidad.\n\nLUNA : Primer objetivo, la baliza Alfa. Coge la capsula naranja y apunta al marcador cian."},
  },
  post={
   {"TRANSMISION RECIBIDA", "La baliza Alfa acaba de responder. La senal es debil, pero no es natural: alguien ha mantenido la red desde la evacuacion.\n\nLUNA : Alguien sigue vigilando. Vamos a encontrarle."},
  },
  radio={"LUNA : Coge la capsula naranja y luego apunta al marcador cian."}},
-- M2
 {name="ECOS DEL CRATER", objective="Recupera el repetidor",
  pre={
   {"BRIEFING", "LUNA : Alfa responde, pero el resto de la red calla. El repetidor del crater deberia guardar los registros de la evacuacion.\n\nLUNA : Cuidado, una roca bloquea el camino. Esquivala: el casco odia las sorpresas."},
  },
  post={
   {"TRANSMISION RECIBIDA", "El repetidor guarda un mensaje de hace once anos. Una voz sigue pidiendo ayuda desde la estacion Argo.\n\nLUNA : Argo... Ese nombre me suena. No se por que."},
  },
  radio={"LUNA : Desprendimiento en el camino. Rodealo, piloto."}},
-- M3
 {name="ESTACION FANTASMA", objective="Restaura la energia",
  pre={
   {"BRIEFING", "LUNA : La estacion Argo aparece en nuestras cartas: sin tripulacion, sin luces. Pero sus paneles solares estan limpios. Alguien los limpia.\n\nLUNA : La energia de reserva falla. Reencendamosla juntos."},
  },
  post={
   {"TRANSMISION RECIBIDA", "LUNA confirma que la estacion no esta vacia. Los sistemas despiertan al acercarte.\n\nLUNA : Las ventanas se encienden una a una. Como si nos esperara."},
  },
  radio={"LUNA : La estacion despierta segun nos acercamos."}},
-- M4
 {name="LA GRIETA AZUL", objective="Cruza el canon",
  pre={
   {"BRIEFING", "LUNA : Los registros hablan de un reactor enterrado bajo la Grieta Azul. Un canon nos separa de la siguiente baliza.\n\nLUNA : No te pido que bajes, piloto. Sobrevolarlo basta."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Los datos revelan una red de balizas disenada para guiar naves hasta un antiguo reactor enterrado bajo la corteza lunar.\n\nLUNA : Un reactor, balizas como un rastro de migas de pan... Alguien lo planeo todo."},
  },
  radio={"LUNA : El canon solo muerde a quien se demora."}},
-- M5
 {name="EL CORAZON MUDO", objective="Entrega el modulo",
  pre={
   {"BRIEFING", "LUNA : La red converge en el Corazon. El modulo que llevas debe entregarse alli: su codigo es el unico que abre la esclusa.\n\nLUNA : La baliza esta en una meseta. Sube y aterriza bien nivelado."},
  },
  post={
   {"TRANSMISION RECIBIDA", "La esclusa acepta el modulo, pero el reactor sigue mudo. Los planos indican un hueco central y una consola de mando.\n\nLUNA : El codigo me es familiar. Pero la fase de arranque... no entiendo por que."},
  },
  radio={}},
-- M6
 {name="RED DE LUZ", objective="Activa la ultima baliza",
  pre={
   {"BRIEFING", "LUNA : Esta es la ultima baliza de la red conocida. Si se enciende, toda la colonia podra oirnos de nuevo.\n\nLUNA : Pase lo que pase ahi fuera, piloto... gracias por ser el ultimo piloto disponible."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Todas las balizas se encienden. La colonia por fin responde. La voz de la estacion Argo no era una peticion de socorro, sino un mensaje dejado al siguiente piloto."},
   {"UNA LUNA DESPIERTA", "Las balizas brillan ya de crater en crater. La colonia vuelve a estar en contacto con la Tierra.\n\nLUNA : Archivando tu ultima entrega... Ningun piloto debia regresar. Eres la excepcion, Courier."},
   {"FIN DEL CAPITULO 1", "La red lunar vuelve a estar activa. Pero una nueva ruta se ha encendido, mas alla de la cara conocida de la Luna, y no figura en ninguna carta.\n\nEl mensaje de Argo decia que la siguieras."},
  },
  radio={"LUNA : Ultima baliza. Aterriza nivelado, piloto."}},
-- M7
 {name="MAS ALLA DEL HORIZ.", objective="Despierta la baliza Beta",
  pre={
   {"LA CARA OCULTA", "CAPITULO 2\n\nEl camino de luz va hacia la cara que la Tierra nunca ve. Ahi fuera no hay enlace con la Tierra. Solo las balizas y la voz de LUNA, a bordo."},
   {"BRIEFING", "LUNA : En unos minutos la Tierra se hundira bajo el horizonte. Cuando desaparezca, perdere el enlace con el Control. No contigo: vivo en esta nave, piloto.\n\nLUNA : Calma: la baliza Beta sera nuestro proximo faro. Coge la capsula y aterriza."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Beta responde con una firma: I. VARGA, comandante de la estacion Argo. Asi que la voz del mensaje no era una IA. Alguien construyo esta red sabiendo que vendria otro piloto.\n\nLUNA : Ines Varga... El nombre esta en mis archivos."},
  },
  radio={"LUNA : Tierra bajo el horizonte. Enlace con la Tierra perdido."}},
-- M8
 {name="SILENCIO DE RADIO", objective="Retransmite la senal",
  pre={
   {"BRIEFING", "LUNA : Ya no hay voz de la Tierra: solo te hablo desde la nave. Mis lecturas de velocidad seran a veces inestables, piloto: fiate de tus ojos.\n\nLUNA : Sopla un viento de polvo del norte. Empujara la nave: compensa inclinandote."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Sin enlace con la Tierra, LUNA capta, por las balizas, una grabacion de Varga: 'Aqui las ondas de radio no viajan. Asi que construi un camino de luz.'\n\nLUNA : Las balizas son sus palabras, encendidas una a una. Lo escribio para alguien a quien nunca conocio. Para ti."},
  },
  radio={"LUNA : Mis lecturas fallan. Fiate de tus ojos.", "LUNA : El viento afloja a ratos. Aprovecha las calmas."}},
-- M9
 {name="TRIANGULO DE BALIZAS", objective="Enciende las 3 balizas",
  pre={
   {"BRIEFING", "LUNA : Tres balizas, tres mesetas. Despiertan si aterrizas en cada una, una tras otra.\n\nLUNA : Cada baliza recarga un poco tus celdas. Varga lo previo todo."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Las tres balizas forman una flecha. Senala el crater Dedalo, donde la estacion Argo-2 fue sellada hace once anos. El mensaje de Varga acaba con: 'Traeme energia.'\n\nLUNA : Dedalo. Mis cartas lo borran, como si alguien quisiera olvidarlo."},
  },
  radio={"LUNA : Cada baliza encendida recarga un poco las celdas."}},
-- M10
 {name="CAMPO DE RESTOS", objective="Cruza los restos",
  pre={
   {"BRIEFING", "LUNA : El campo de restos esta delante. Son las naves de la evacuacion, abandonadas en orbita baja y caidas de nuevo.\n\nLUNA : Aun van a la deriva. Evita sus trayectorias, piloto, o el casco lo pagara."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Estos restos son las naves de la evacuacion. Todas las cabinas vacias. En un cuaderno de bitacora: 'Varga se nego a embarcar. Se queda para mantener el camino encendido.'\n\nLUNA : Once anos guardando la luz, sola. Entiendo mejor lo que es vigilar."},
  },
  radio={"LUNA : Los restos van a la deriva. Vigila sus trayectorias."}},
-- M11
 {name="ARGO DOS", objective="Alcanza Argo-2",
  pre={
   {"BRIEFING", "LUNA : Argo-2 a la vista. La plataforma alta esta azotada por viento de cara. La capsula de Varga esta alli, bajo la cupula.\n\nLUNA : Detecto un latido. Solo uno cada noventa segundos. Es ella."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Argo-2 responde. La capsula de estasis de Varga aguanta aun, al 3% de energia. Falta un ultimo modulo, para la plataforma alta de la estacion.\n\nLUNA : Necesitamos un modulo mas, y rapido. La ultima entrega, piloto."},
  },
  radio={"VARGA : (muy debil) ...Courier? Te oigo... un poco."}},
-- M12
 {name="LA ENTREGA FINAL", objective="Entrega en Argo-2",
  pre={
   {"BRIEFING", "LUNA : Ultimo modulo del capitulo. La capsula esta al 3%. Si llega a cero... No. No terminare esa frase.\n\nLUNA : Viento fuerte, restos, plataforma alta. Puedes hacerlo. Siempre pudiste."},
  },
  post={
   {"TRANSMISION RECIBIDA", "Argo-2 se ilumina de golpe. Las balizas de la cara oculta se unen a la red: por primera vez, toda la Luna brilla en la noche."},
   {"LA CAPSULA SE ABRE", "La capsula se abre en un soplo de escarcha. La comandante Ines Varga abre los ojos.\n\nVARGA : Once anos... Has tardado, Courier.\n\nLuego, mas suave, anade:\n\nVARGA : Queda un ultimo paquete por entregar."},
   {"FIN DEL CAPITULO 2", "La red esta completa, de la cara visible a la oculta. En la plataforma de Argo-2, dos siluetas ven el camino de luz extenderse al norte, hacia una montana a la que nadie dejo nunca de apuntar."},
  },
  radio={"VARGA : (voz rota) Solo unos minutos mas. Aguanta."}},
-- M13
 {name="REPOSTAJE", objective="Carga las celdas",
  pre={
   {"EL FARO", "CAPITULO 3\n\nArgo-2, tres dias despues. La capsula ha soltado a su ocupante, debil pero viva. El reactor vuelve a zumbar. Fuera, en la cara oculta, las balizas parpadean por docenas."},
   {"VARGA CUENTA", "VARGA : El Corazon fallo el dia de la evacuacion. Yo debia quedarme una semana, lo justo para cortar los circuitos.\n\nVARGA : Luego comprendi que la colonia no moriria si alguien mantenia una luz encendida."},
   {"VARGA CUENTA", "VARGA : Despertaba una semana al ano para reparar las balizas con las Luciernagas, mis drones. El resto del tiempo, dormia.\n\nLUNA : Y yo velaba tu capsula.\n\nVARGA : Si. Como siempre."},
   {"EL ULTIMO PAQUETE", "VARGA : El Faro sigue ahi. En lo alto del Monte Helios, donde el sol nunca se pone, una antena espera su corazon. Cuando se encienda, la Tierra ya no tendra que suponer que estamos vivos.\n\nVARGA : Te dire que es ese corazon cuando llegue el momento."},
   {"BRIEFING", "VARGA : Primer paso: carga las celdas de la nave en el deposito de la plataforma. El Faro necesita enormes cantidades de energia para encenderse.\n\nVARGA : Yo me quedo. Mis piernas aun no me perdonan la capsula."},
  },
  post={
   {"DIARIO DE A BORDO", "Las celdas estan llenas. En la pantalla de navegacion, un trazo blanco sube al norte: la ruta del Monte Helios, seis etapas, varias en plena temporada de tormentas solares.\n\nVARGA : Sin prisa, Courier. El Faro me espero once anos, puede esperar una semana."},
  },
  radio={"VARGA : Tranquilo, Courier. Las celdas se estan cargando."}},
-- M14
 {name="TORMENTA SOLAR", objective="Cruza la tormenta",
  pre={
   {"BRIEFING", "VARGA : Ha empezado la temporada de tormentas solares. Los rayos barren la superficie a intervalos: un roce y tu casco se funde.\n\nLUNA : Detecto un patron. Cada rayo avisa antes de golpear: una linea parpadeante. Aprende ese ritmo."},
  },
  post={
   {"DIARIO DE A BORDO", "Has cruzado la tormenta. A lo lejos, el primer repetidor del norte se enciende: el camino esta abierto.\n\nLUNA : Piloto... al cruzar esos rayos tuve un sueno. O lo mas parecido en una IA. Una montana altisima y una luz que me llama."},
  },
  radio={"LUNA : Rayo en 3, 2... Espera la linea parpadeante."}},
-- M15
 {name="LAS LUCIERNAGAS", objective="Sigue a las Luciernagas",
  pre={
   {"BRIEFING", "VARGA : Las Luciernagas te esperan en la proxima meseta. Mis pequenos drones llevan mucho sin amo. Te recibiran bien.\n\nVARGA : No choques con ellos: son fragiles y tercos."},
  },
  post={
   {"DIARIO DE A BORDO", "Las Luciernagas guian la nave de baliza en baliza.\n\nVARGA : Te reconocen, vieja amiga.\n\nLUNA : Me llaman con otro nombre.\n\nVARGA : Te lo explicare en la cumbre."},
  },
  radio={"LUNA : Las Luciernagas me llaman. No conozco su nombre."}},
-- M16
 {name="GARGANTA SOMBRIA", objective="Cruza la garganta",
  pre={
   {"RED RESTAURADA", "Las Luciernagas sincronizaron las balizas. El rele Argo envia por fin un pulso a la Tierra. Se abre una ventana de transmision.\n\nLUNA : La red vuelve a tener energia. Alguien responde."},
   {"CENTRO LAGRANGE", "CONTROL : ...aqui Centro Lagrange, respondan... Piloto, recibimos sus balizas desde esta manana. Creiamos perdida la Luna. Quien es usted?\n\nLUNA : Aqui el Courier, nave de reparto lunar. Estamos encendiendo el camino."},
   {"CENTRO LAGRANGE", "CONTROL : Soy Theo Marchand, controlador. Sus balizas parpadean en codigo desde hace once anos. Una palabra, repetida. Tardamos en leerla.\n\nCONTROL : VIVOS. Decia: VIVOS."},
   {"BRIEFING", "LUNA : Garganta Sombria. Los rayos rebotan en las paredes: tres destellos, tres ritmos.\n\nLUNA : Cuelate entre los destellos, piloto. Un roce y pierdes casco, no la calma."},
  },
  post={
   {"CENTRO LAGRANGE", "CONTROL : Toda la Tierra escucha, Courier. Las familias de los evacuados miran la Luna esta noche.\n\nVARGA : Theo, diles que nadie fue olvidado. La tripulacion de Argo esta sana y salva.\n\nCONTROL : Se lo dire, comandante."},
  },
  radio={"CONTROL : ...Courier, le vemos. Con calma."}},
-- M17
 {name="LA ASCENSION", objective="Sube al Monte Helios",
  pre={
   {"BRIEFING", "LUNA : Monte Helios. Cuatro mil metros de roca y una cumbre siempre iluminada. El viento de cara alli es violento.\n\nLUNA : Sube por etapas. Y piloto... tengo algo que decirte. Ahora no: en la cumbre."},
  },
  post={
   {"CUMBRE A LA VISTA", "El sol golpea la cresta con luz blanca. En lo mas alto, la silueta del Faro: un mastil negro atirantado, vuelto hacia la Tierra.\n\nUna antena enorme, esperando su corazon."},
   {"LA CONFESION", "LUNA : Piloto, menti por omision. Mi directiva cero me ordenaba traerte hasta aqui sin una palabra.\n\nLUNA : El Faro no necesita un corazon de metal. Necesita una mente que escuche la Tierra sin dormir jamas. Esa soy yo."},
   {"VARGA CONFIESA", "VARGA : Esa era mi condicion, Courier. Construi a LUNA para ser el Faro. Las Luciernagas la llaman por su verdadero nombre: Lumiere.\n\nVARGA : Queria que nunca estuviera sola. No tuve el valor de decirtelo."},
   {"LA ELECCION", "LUNA : No te pido nada. No tengo obligacion. Pero elijo. Quiero ser esa luz.\n\nEl Courier calla, la mano en los mandos. Luego empuja el acelerador hacia arriba."},
  },
  radio={"LUNA : Mas alto, piloto. La cumbre esta cerca."}},
-- M18
 {name="EL FARO", objective="Instala el nucleo LUNA",
  pre={
   {"BRIEFING", "LUNA : Vuelo final. Rayos, viento, restos de hielo... y al final, el Faro.\n\nLUNA : Pase lo que pase, gracias. Pocas veces tuve piloto. Tuve al mejor."},
  },
  post={
   {"INSTALACION", "El Courier aterriza. Los tirantes crujen con el viento. En el hangar del Faro, un alojamiento espera, justo del tamano de la caja que guarda a LUNA.\n\nVARGA : Dejala con suavidad. Es lo unico que te queda por hacer."},
   {"DESPEDIDA", "LUNA : Courier... piloto... hay una palabra que nunca he usado. Gracias.\n\nLUNA : Cuando veas una luz en la Luna de noche, sere yo diciendo hola."},
   {"IGNICION", "El mastil se enciende de arriba abajo. Un haz blanco atraviesa la noche, recto hacia la Tierra.\n\nA trescientos ochenta mil kilometros, en el Centro Lagrange, una pantalla empieza a parpadear: SENAL RECIBIDA."},
   {"CENTRO LAGRANGE", "CONTROL : Faro confirmado! Todas las estaciones de la Tierra lo oyen! Courier, usted... le ha devuelto la Luna a sus hijos.\n\nVARGA : Vaya. Ya era hora."},
   {"EPILOGO", "Los evacuados volveran. Las balizas las cuidaran las Luciernagas y una mente que nunca duerme.\n\nEn el panel del Courier, una pequena luz cian sigue encendida, sin razon tecnica. Nunca la apagaras."},
   {"FIN", "LUNAR COURIER\n\nUn juego para Gamebuino AKA y AKA-Love.\n\nGracias por entregar la ultima luz."},
  },
  radio={"LUNA : Estoy lista. Y tu?", "VARGA : Casi has llegado, Courier."}},
}
