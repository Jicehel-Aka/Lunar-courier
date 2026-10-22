-- LUNAR COURIER - langues (FR/EN), clavier (AKA / AZERTY / QWERTY) et libelles de touches.
-- Tout le texte reste en ASCII pur : le runtime AKA-Love n'affiche pas les accents.
-- Pour ajouter une langue : un fichier text_<code>.lua (histoire), une table dans STR, une entree dans I.langs.
local I = {}

I.langs = {"fr", "en", "pt", "de", "es", "it"}                       -- langues disponibles (ordre du menu)
I.langNames = {fr = "FRANCAIS", en = "ENGLISH", pt = "PORTUGUES", de = "DEUTSCH", es = "ESPANOL", it = "ITALIANO"}
I.lang = "fr"                                -- francais par defaut
I.kbModes = {"aka", "azerty", "qwerty", "qwertz"}
I.kb = "azerty"
I.kbTouched = false                          -- vrai des que le joueur choisit lui-meme le clavier

-- Plateforme : AKA-Love renvoie "Other" pour love.system.getOS() ; un vrai LOVE renvoie Windows/Linux/OS X...
function I.detectAKA()
    local ok, name = pcall(function()
        if love.system and love.system.getOS then return love.system.getOS() end
        return nil
    end)
    if not ok or name == nil then return true end
    return name == "Other"
end
I.aka = I.detectAKA()
if I.aka then I.kb = "aka" end

local TEXTS = {}
local function texts(lang)
    if not TEXTS[lang] then
        local ok, t = pcall(require, "src.text_"..lang)
        TEXTS[lang] = ok and t or false
    end
    return TEXTS[lang] or TEXTS.fr or require("src.text_fr")
end

function I.mission(i) return texts(I.lang)[i] or texts("fr")[i] end

-- ---------------------------------------------------------------------------
-- Libelles des touches : A B C D MENU sur AKA, vraies touches du clavier sinon.
-- ---------------------------------------------------------------------------
local KEYNAMES = {
    aka = {A = "A", B = "B", C = "C", D = "D", MENU = "MENU"},
    fr  = {A = "ESPACE", B = "X", C = "C", D = "V", MENU = "ECHAP"},
    en  = {A = "SPACE",  B = "X", C = "C", D = "V", MENU = "ESC"},
    pt  = {A = "ESPACO", B = "X", C = "C", D = "V", MENU = "ESC"},
    de  = {A = "LEERTASTE", B = "X", C = "C", D = "V", MENU = "ESC"},
    es  = {A = "ESPACIO", B = "X", C = "C", D = "V", MENU = "ESC"},
    it  = {A = "SPAZIO", B = "X", C = "C", D = "V", MENU = "ESC"},
}
function I.keyName(k)
    local set = (I.kb == "aka") and KEYNAMES.aka or (KEYNAMES[I.lang] or KEYNAMES.fr)
    return set[k] or k
end

-- Touches de pilotage : fleches toujours ; lettres selon la disposition choisie.
function I.moveKeys()
    if I.kb == "azerty" then return {left = {"left", "q"}, right = {"right", "d"}, up = {"up", "z"}} end
    if I.kb == "qwerty" or I.kb == "qwertz" then return {left = {"left", "a"}, right = {"right", "d"}, up = {"up", "w"}} end
    return {left = {"left"}, right = {"right"}, up = {"up"}}
end

function I.setLang(code)
    for _, c in ipairs(I.langs) do
        if c == code then
            I.lang = code
            -- Tant que le joueur n'a pas choisi son clavier, il suit la langue (FR -> AZERTY, EN -> QWERTY).
            if not I.kbTouched and not I.aka then I.kb = (code == "fr") and "azerty" or ((code == "de") and "qwertz" or "qwerty") end
            return true
        end
    end
    return false
end
function I.nextLang()
    for i, c in ipairs(I.langs) do
        if c == I.lang then I.setLang(I.langs[i % #I.langs + 1]); return end
    end
end
function I.setKb(mode, explicit)
    for _, m in ipairs(I.kbModes) do
        if m == mode then I.kb = mode; if explicit then I.kbTouched = true end; return true end
    end
    return false
end
function I.nextKb()
    for i, m in ipairs(I.kbModes) do
        if m == I.kb then I.setKb(I.kbModes[i % #I.kbModes + 1], true); return end
    end
end

-- ---------------------------------------------------------------------------
-- Textes d'interface. {A} {B} {C} {D} {MENU} = libelle de la touche (selon plateforme/clavier).
-- ---------------------------------------------------------------------------
local STR = {}
STR.fr = {
    title_sub = "UNE AVENTURE LUNAIRE", title_tag = "LIVREZ LA DERNIERE LUMIERE",
    menu_continue = "CONTINUER  M%02d", menu_new = "NOUVELLE PARTIE", menu_chapter = "CHAPITRE %d",
    hint1 = "HAUT / BAS : MENU", hint2 = "{A} : OK    {B} : SON", hint3 = "{MENU} MENU  {C} PAUSE  {D} RECOMMENCER",
    card_next = "{A} : CONTINUER", card_launch = "{A} : DECOLLER", card_title = "{A} : TITRE", card_nextm = "{A} : MISSION SUIVANTE",
    obj = "OBJ: ",
    debrief_title = "MISSION ACCOMPLIE", fuel = "Carburant : %d%%", hull = "Coque : %d%%", time = "Temps : %s",
    saved = "Progression sauvegardee",
    rank = "Rang : %s", rank_best = "Meilleur : %s",
    pause = "PAUSE", pause_resume = "{C} : reprendre", pause_menu = "{MENU} : menu", pause_music = "{B} : musique %s",
    on = "OUI", off = "NON",
    hull_broken = "COQUE BRISEE - {D} : RECOMMENCER", landed = "ATTERRISSAGE CONFIRME - {A} : CONTINUER",
    fuel_out = "CARBURANT EPUISE - {D} : RECOMMENCER",
    pad_on = "BALISE %d/%d ACTIVEE  +25%% CARBURANT", cell_got = "MODULE RECUPERE  +22%% CARBURANT",
    hit_rock = "DEBRIS ! COQUE -20%%", hit_wreck = "EPAVE ! COQUE -20%%", hit_beam = "RAYON SOLAIRE ! COQUE -20%%",
    drone = "LUCIOLE ! DOUCEMENT", no_cargo = "MODULE MANQUANT : PRENEZ LA CAPSULE",
    too_fast = "TROP RAPIDE OU PENCHE", off_pad = "HORS ZONE - VISEZ LA BALISE CYAN",
    tilt = "REDRESSEZ LE VAISSEAU", bounce = "REBOND ! RALENTISSEZ",
    help_title = "COMMANDES",
    help_turn_aka = "GAUCHE / DROITE : tourner", help_thrust_aka = "HAUT : propulseur",
    help_turn_azerty = "FLECHES ou Q / D : tourner", help_thrust_azerty = "HAUT ou Z : propulseur",
    help_turn_qwerty = "FLECHES ou A / D : tourner", help_thrust_qwerty = "HAUT ou W : propulseur",
    help_ok = "{A} : valider    {C} : pause", help_restart = "{D} : recommencer    {MENU} : menu",
    help_music = "{B} : musique oui / non", help_mission = "MISSION",
    help_m1 = "1. Prenez la capsule orange", help_m2 = "2. Posez-vous sur la balise cyan",
    help_m3 = "   doucement, vaisseau droit", help_m4 = "F carburant   H coque",
    help_m5 = "V orange = trop vite", help_m6 = "Les fleches du bord : la cible",
    menu_title = "MENU", m_resume = "REPRENDRE", m_controls = "COMMANDES", m_lang = "LANGUE : %s", m_kb = "CLAVIER : %s",
    m_music = "MUSIQUE : %s", m_shot = "CAPTURE D'ECRAN", m_credits = "CREDITS", m_totitle = "RETOUR AU TITRE",
    m_quit_aka = "RETOUR AU LOADER", m_quit_pc = "QUITTER", menu_foot = "{A} : OK    {B} : RETOUR",
    shot_ok = "CAPTURE : %s", shot_na = "CAPTURE INDISPONIBLE", shot_fail = "ECHEC DE LA CAPTURE",
    credits_title = "CREDITS", credits_1 = "LUNAR COURIER", credits_2 = "Un jeu de Jicehel",
    credits_3 = "pour Gamebuino AKA", credits_4 = "et AKA-Love", credits_5 = "Merci d'avoir joue !",
    speakers = {{"LUNA :", {120,235,225}, "luna"}, {"VARGA :", {255,188,83}, "varga"}, {"CONTROLE :", {140,225,150}, "controle"}},
}
STR.en = {
    title_sub = "A LUNAR ADVENTURE", title_tag = "DELIVER THE LAST LIGHT",
    menu_continue = "CONTINUE  M%02d", menu_new = "NEW GAME", menu_chapter = "CHAPTER %d",
    hint1 = "UP / DOWN : MENU", hint2 = "{A} : OK    {B} : SOUND", hint3 = "{MENU} MENU  {C} PAUSE  {D} RESTART",
    card_next = "{A} : CONTINUE", card_launch = "{A} : LAUNCH", card_title = "{A} : TITLE", card_nextm = "{A} : NEXT MISSION",
    obj = "OBJ: ",
    debrief_title = "MISSION COMPLETE", fuel = "Fuel : %d%%", hull = "Hull : %d%%", time = "Time : %s",
    saved = "Progress saved",
    rank = "Rank : %s", rank_best = "Best : %s",
    pause = "PAUSE", pause_resume = "{C} : resume", pause_menu = "{MENU} : menu", pause_music = "{B} : music %s",
    on = "ON", off = "OFF",
    hull_broken = "HULL DESTROYED - {D} : RESTART", landed = "LANDING CONFIRMED - {A} : CONTINUE",
    fuel_out = "OUT OF FUEL - {D} : RESTART",
    pad_on = "BEACON %d/%d LIT  +25%% FUEL", cell_got = "MODULE RECOVERED  +22%% FUEL",
    hit_rock = "DEBRIS! HULL -20%%", hit_wreck = "WRECK! HULL -20%%", hit_beam = "SOLAR RAY! HULL -20%%",
    drone = "FIREFLY! GENTLY", no_cargo = "MODULE MISSING: GET THE CAPSULE",
    too_fast = "TOO FAST OR TILTED", off_pad = "OFF TARGET - AIM FOR THE CYAN BEACON",
    tilt = "LEVEL THE SHIP", bounce = "BOUNCE! SLOW DOWN",
    help_title = "CONTROLS",
    help_turn_aka = "LEFT / RIGHT : rotate", help_thrust_aka = "UP : thrust",
    help_turn_azerty = "ARROWS or Q / D : rotate", help_thrust_azerty = "UP or Z : thrust",
    help_turn_qwerty = "ARROWS or A / D : rotate", help_thrust_qwerty = "UP or W : thrust",
    help_ok = "{A} : confirm    {C} : pause", help_restart = "{D} : restart    {MENU} : menu",
    help_music = "{B} : music on / off", help_mission = "MISSION",
    help_m1 = "1. Grab the orange capsule", help_m2 = "2. Land on the cyan beacon",
    help_m3 = "   gently, ship upright", help_m4 = "F fuel   H hull",
    help_m5 = "Orange V = too fast", help_m6 = "Edge arrows point to the target",
    menu_title = "MENU", m_resume = "RESUME", m_controls = "CONTROLS", m_lang = "LANGUAGE : %s", m_kb = "KEYS : %s",
    m_music = "MUSIC : %s", m_shot = "SCREENSHOT", m_credits = "CREDITS", m_totitle = "BACK TO TITLE",
    m_quit_aka = "BACK TO LOADER", m_quit_pc = "QUIT", menu_foot = "{A} : OK    {B} : BACK",
    shot_ok = "SCREENSHOT: %s", shot_na = "SCREENSHOT UNAVAILABLE", shot_fail = "SCREENSHOT FAILED",
    credits_title = "CREDITS", credits_1 = "LUNAR COURIER", credits_2 = "A game by Jicehel",
    credits_3 = "for Gamebuino AKA", credits_4 = "and AKA-Love", credits_5 = "Thanks for playing!",
    speakers = {{"LUNA :", {120,235,225}, "luna"}, {"VARGA :", {255,188,83}, "varga"}, {"CONTROL :", {140,225,150}, "controle"}},
}
STR.pt = {
    title_sub = "UMA AVENTURA LUNAR", title_tag = "ENTREGUE A ULTIMA LUZ",
    menu_continue = "CONTINUAR  M%02d", menu_new = "NOVO JOGO", menu_chapter = "CAPITULO %d",
    hint1 = "CIMA / BAIXO : MENU", hint2 = "{A} : OK    {B} : SOM", hint3 = "{MENU} MENU  {C} PAUSA  {D} REINICIAR",
    card_next = "{A} : CONTINUAR", card_launch = "{A} : DECOLAR", card_title = "{A} : TITULO", card_nextm = "{A} : PROXIMA MISSAO",
    obj = "OBJ: ",
    debrief_title = "MISSAO CUMPRIDA", fuel = "Combustivel : %d%%", hull = "Casco : %d%%", time = "Tempo : %s",
    saved = "Progresso salvo",
    rank = "Nota : %s", rank_best = "Melhor : %s",
    pause = "PAUSA", pause_resume = "{C} : retomar", pause_menu = "{MENU} : menu", pause_music = "{B} : musica %s",
    on = "SIM", off = "NAO",
    hull_broken = "CASCO DESTRUIDO - {D} : REINICIAR", landed = "POUSO CONFIRMADO - {A} : CONTINUAR",
    fuel_out = "SEM COMBUSTIVEL - {D} : REINICIAR",
    pad_on = "FAROL %d/%d ATIVO  +25%% COMBUSTIVEL", cell_got = "MODULO RECUPERADO  +22%% COMBUSTIVEL",
    hit_rock = "DESTROCO! CASCO -20%%", hit_wreck = "NAUFRAGIO! CASCO -20%%", hit_beam = "RAIO SOLAR! CASCO -20%%",
    drone = "VAGALUME! DEVAGAR", no_cargo = "SEM MODULO: PEGUE A CAPSULA",
    too_fast = "RAPIDO OU INCLINADO DEMAIS", off_pad = "FORA DA ZONA - MIRE O FAROL CIANO",
    tilt = "ENDIREITE A NAVE", bounce = "QUICOU! REDUZA",
    help_title = "COMANDOS",
    help_turn_aka = "ESQUERDA / DIREITA : girar", help_thrust_aka = "CIMA : propulsor",
    help_turn_azerty = "SETAS ou Q / D : girar", help_thrust_azerty = "CIMA ou Z : propulsor",
    help_turn_qwerty = "SETAS ou A / D : girar", help_thrust_qwerty = "CIMA ou W : propulsor",
    help_ok = "{A} : confirmar    {C} : pausa", help_restart = "{D} : reiniciar    {MENU} : menu",
    help_music = "{B} : musica sim / nao", help_mission = "MISSAO",
    help_m1 = "1. Pegue a capsula laranja", help_m2 = "2. Pouse no farol ciano",
    help_m3 = "   devagar, nave reta", help_m4 = "F combustivel   H casco",
    help_m5 = "V laranja = rapido demais", help_m6 = "Setas na borda : o alvo",
    menu_title = "MENU", m_resume = "RETOMAR", m_controls = "COMANDOS", m_lang = "IDIOMA : %s", m_kb = "TECLADO : %s",
    m_music = "MUSICA : %s", m_shot = "CAPTURA DE TELA", m_credits = "CREDITOS", m_totitle = "VOLTAR AO TITULO",
    m_quit_aka = "VOLTAR AO LOADER", m_quit_pc = "SAIR", menu_foot = "{A} : OK    {B} : VOLTAR",
    shot_ok = "CAPTURA: %s", shot_na = "CAPTURA INDISPONIVEL", shot_fail = "FALHA NA CAPTURA",
    credits_title = "CREDITOS", credits_1 = "LUNAR COURIER", credits_2 = "Um jogo de Jicehel",
    credits_3 = "para Gamebuino AKA", credits_4 = "e AKA-Love", credits_5 = "Obrigado por jogar!",
    speakers = {{"LUNA :", {120,235,225}, "luna"}, {"VARGA :", {255,188,83}, "varga"}, {"CONTROLE :", {140,225,150}, "controle"}},
}
STR.de = {
    title_sub = "EIN MONDABENTEUER", title_tag = "BRING DAS LETZTE LICHT",
    menu_continue = "WEITER  M%02d", menu_new = "NEUES SPIEL", menu_chapter = "KAPITEL %d",
    hint1 = "HOCH / RUNTER : MENUE", hint2 = "{A} : OK    {B} : TON", hint3 = "{MENU} MENUE {C} PAUSE {D} NEUSTART",
    card_next = "{A} : WEITER", card_launch = "{A} : START", card_title = "{A} : TITEL", card_nextm = "{A} : NAECHSTE MISSION",
    obj = "ZIEL: ",
    debrief_title = "MISSION ERFUELLT", fuel = "Treibstoff : %d%%", hull = "Huelle : %d%%", time = "Zeit : %s",
    saved = "Fortschritt gespeichert",
    rank = "Rang : %s", rank_best = "Beste : %s",
    pause = "PAUSE", pause_resume = "{C} : weiter", pause_menu = "{MENU} : Menue", pause_music = "{B} : Musik %s",
    on = "AN", off = "AUS",
    hull_broken = "HUELLE ZERSTOERT - {D} : NEUSTART", landed = "LANDUNG BESTAETIGT - {A} : WEITER",
    fuel_out = "TANK LEER - {D} : NEUSTART",
    pad_on = "BAKE %d/%d AN  +25%% TREIBSTOFF", cell_got = "MODUL GEBORGEN  +22%% TREIBSTOFF",
    hit_rock = "TRUEMMER! HUELLE -20%%", hit_wreck = "WRACK! HUELLE -20%%", hit_beam = "SONNENSTRAHL! HUELLE -20%%",
    drone = "GLUEHWUERMCHEN! LANGSAM", no_cargo = "MODUL FEHLT: KAPSEL HOLEN",
    too_fast = "ZU SCHNELL ODER SCHIEF", off_pad = "DANEBEN - ZIEL IST DIE CYAN-BAKE",
    tilt = "SCHIFF AUFRICHTEN", bounce = "AUFPRALL! LANGSAMER",
    help_title = "STEUERUNG",
    help_turn_aka = "LINKS / RECHTS : drehen", help_thrust_aka = "HOCH : Schub",
    help_turn_azerty = "PFEILE oder Q / D : drehen", help_thrust_azerty = "HOCH oder Z : Schub",
    help_turn_qwerty = "PFEILE oder A / D : drehen", help_thrust_qwerty = "HOCH oder W : Schub",
    help_ok = "{A} : bestaetigen    {C} : Pause", help_restart = "{D} : Neustart    {MENU} : Menue",
    help_music = "{B} : Musik an / aus", help_mission = "MISSION",
    help_m1 = "1. Orange Kapsel einsammeln", help_m2 = "2. Auf der Cyan-Bake landen",
    help_m3 = "   sanft, Schiff gerade", help_m4 = "F Treibstoff   H Huelle",
    help_m5 = "Oranges V = zu schnell", help_m6 = "Randpfeile zeigen das Ziel",
    menu_title = "MENUE", m_resume = "WEITER", m_controls = "STEUERUNG", m_lang = "SPRACHE : %s", m_kb = "TASTATUR : %s",
    m_music = "MUSIK : %s", m_shot = "SCREENSHOT", m_credits = "CREDITS", m_totitle = "ZUM TITEL",
    m_quit_aka = "ZUM LOADER", m_quit_pc = "BEENDEN", menu_foot = "{A} : OK    {B} : ZURUECK",
    shot_ok = "SCREENSHOT: %s", shot_na = "SCREENSHOT NICHT MOEGLICH", shot_fail = "SCREENSHOT FEHLGESCHLAGEN",
    credits_title = "CREDITS", credits_1 = "LUNAR COURIER", credits_2 = "Ein Spiel von Jicehel",
    credits_3 = "fuer Gamebuino AKA", credits_4 = "und AKA-Love", credits_5 = "Danke fuers Spielen!",
    speakers = {{"LUNA :", {120,235,225}, "luna"}, {"VARGA :", {255,188,83}, "varga"}, {"KONTROLLE :", {140,225,150}, "controle"}},
}
STR.es = {
    title_sub = "UNA AVENTURA LUNAR", title_tag = "ENTREGA LA ULTIMA LUZ",
    menu_continue = "CONTINUAR  M%02d", menu_new = "NUEVA PARTIDA", menu_chapter = "CAPITULO %d",
    hint1 = "ARRIBA / ABAJO : MENU", hint2 = "{A} : OK    {B} : SONIDO", hint3 = "{MENU} MENU  {C} PAUSA  {D} REINICIAR",
    card_next = "{A} : CONTINUAR", card_launch = "{A} : DESPEGAR", card_title = "{A} : TITULO", card_nextm = "{A} : SIGUIENTE MISION",
    obj = "OBJ: ",
    debrief_title = "MISION CUMPLIDA", fuel = "Combustible : %d%%", hull = "Casco : %d%%", time = "Tiempo : %s",
    saved = "Progreso guardado",
    rank = "Rango : %s", rank_best = "Mejor : %s",
    pause = "PAUSA", pause_resume = "{C} : reanudar", pause_menu = "{MENU} : menu", pause_music = "{B} : musica %s",
    on = "SI", off = "NO",
    hull_broken = "CASCO DESTRUIDO - {D} : REINICIAR", landed = "ATERRIZAJE OK - {A} : CONTINUAR",
    fuel_out = "SIN COMBUSTIBLE - {D} : REINICIAR",
    pad_on = "BALIZA %d/%d ON  +25%% COMBUSTIBLE", cell_got = "MODULO RECUPERADO  +22%% COMB.",
    hit_rock = "ESCOMBRO! CASCO -20%%", hit_wreck = "RESTO! CASCO -20%%", hit_beam = "RAYO SOLAR! CASCO -20%%",
    drone = "LUCIERNAGA! DESPACIO", no_cargo = "FALTA MODULO: COGE LA CAPSULA",
    too_fast = "DEMASIADO RAPIDO O INCLINADO", off_pad = "FUERA - APUNTA A LA BALIZA CIAN",
    tilt = "ENDEREZA LA NAVE", bounce = "REBOTE! FRENA",
    help_title = "CONTROLES",
    help_turn_aka = "IZQUIERDA / DERECHA : girar", help_thrust_aka = "ARRIBA : propulsor",
    help_turn_azerty = "FLECHAS o Q / D : girar", help_thrust_azerty = "ARRIBA o Z : propulsor",
    help_turn_qwerty = "FLECHAS o A / D : girar", help_thrust_qwerty = "ARRIBA o W : propulsor",
    help_ok = "{A} : confirmar    {C} : pausa", help_restart = "{D} : reiniciar    {MENU} : menu",
    help_music = "{B} : musica si / no", help_mission = "MISION",
    help_m1 = "1. Coge la capsula naranja", help_m2 = "2. Aterriza en la baliza cian",
    help_m3 = "   con suavidad, nave recta", help_m4 = "F combustible   H casco",
    help_m5 = "V naranja = muy rapido", help_m6 = "Flechas del borde : el objetivo",
    menu_title = "MENU", m_resume = "REANUDAR", m_controls = "CONTROLES", m_lang = "IDIOMA : %s", m_kb = "TECLADO : %s",
    m_music = "MUSICA : %s", m_shot = "CAPTURA DE PANTALLA", m_credits = "CREDITOS", m_totitle = "VOLVER AL TITULO",
    m_quit_aka = "VOLVER AL LOADER", m_quit_pc = "SALIR", menu_foot = "{A} : OK    {B} : ATRAS",
    shot_ok = "CAPTURA: %s", shot_na = "CAPTURA NO DISPONIBLE", shot_fail = "FALLO DE CAPTURA",
    credits_title = "CREDITOS", credits_1 = "LUNAR COURIER", credits_2 = "Un juego de Jicehel",
    credits_3 = "para Gamebuino AKA", credits_4 = "y AKA-Love", credits_5 = "Gracias por jugar!",
    speakers = {{"LUNA :", {120,235,225}, "luna"}, {"VARGA :", {255,188,83}, "varga"}, {"CONTROL :", {140,225,150}, "controle"}},
}
STR.it = {
    title_sub = "UN'AVVENTURA LUNARE", title_tag = "CONSEGNA L'ULTIMA LUCE",
    menu_continue = "CONTINUA  M%02d", menu_new = "NUOVA PARTITA", menu_chapter = "CAPITOLO %d",
    hint1 = "SU / GIU : MENU", hint2 = "{A} : OK    {B} : SUONO", hint3 = "{MENU} MENU  {C} PAUSA  {D} RIAVVIA",
    card_next = "{A} : CONTINUA", card_launch = "{A} : DECOLLA", card_title = "{A} : TITOLO", card_nextm = "{A} : PROSSIMA MISSIONE",
    obj = "OBI: ",
    debrief_title = "MISSIONE COMPIUTA", fuel = "Carburante : %d%%", hull = "Scafo : %d%%", time = "Tempo : %s",
    saved = "Progressi salvati",
    rank = "Grado : %s", rank_best = "Migliore : %s",
    pause = "PAUSA", pause_resume = "{C} : riprendi", pause_menu = "{MENU} : menu", pause_music = "{B} : musica %s",
    on = "SI", off = "NO",
    hull_broken = "SCAFO DISTRUTTO - {D} : RIAVVIA", landed = "ATTERRAGGIO OK - {A} : CONTINUA",
    fuel_out = "CARBURANTE FINITO - {D} : RIAVVIA",
    pad_on = "FARO %d/%d ON  +25%% CARBURANTE", cell_got = "MODULO RECUPERATO  +22%% CARB.",
    hit_rock = "DETRITO! SCAFO -20%%", hit_wreck = "RELITTO! SCAFO -20%%", hit_beam = "RAGGIO SOLARE! SCAFO -20%%",
    drone = "LUCCIOLA! PIANO", no_cargo = "MANCA IL MODULO: PRENDI LA CAPSULA",
    too_fast = "TROPPO VELOCE O INCLINATO", off_pad = "FUORI - PUNTA IL FARO CIANO",
    tilt = "RADDRIZZA LA NAVE", bounce = "RIMBALZO! RALLENTA",
    help_title = "COMANDI",
    help_turn_aka = "SINISTRA / DESTRA : ruota", help_thrust_aka = "SU : propulsore",
    help_turn_azerty = "FRECCE o Q / D : ruota", help_thrust_azerty = "SU o Z : propulsore",
    help_turn_qwerty = "FRECCE o A / D : ruota", help_thrust_qwerty = "SU o W : propulsore",
    help_ok = "{A} : conferma    {C} : pausa", help_restart = "{D} : riavvia    {MENU} : menu",
    help_music = "{B} : musica si / no", help_mission = "MISSIONE",
    help_m1 = "1. Prendi la capsula arancio", help_m2 = "2. Atterra sul faro ciano",
    help_m3 = "   piano, nave dritta", help_m4 = "F carburante   H scafo",
    help_m5 = "V arancio = troppo veloce", help_m6 = "Frecce ai bordi : il bersaglio",
    menu_title = "MENU", m_resume = "RIPRENDI", m_controls = "COMANDI", m_lang = "LINGUA : %s", m_kb = "TASTIERA : %s",
    m_music = "MUSICA : %s", m_shot = "SCREENSHOT", m_credits = "CREDITI", m_totitle = "TORNA AL TITOLO",
    m_quit_aka = "TORNA AL LOADER", m_quit_pc = "ESCI", menu_foot = "{A} : OK    {B} : INDIETRO",
    shot_ok = "SCREENSHOT: %s", shot_na = "SCREENSHOT NON DISPONIBILE", shot_fail = "SCREENSHOT FALLITO",
    credits_title = "CREDITI", credits_1 = "LUNAR COURIER", credits_2 = "Un gioco di Jicehel",
    credits_3 = "per Gamebuino AKA", credits_4 = "e AKA-Love", credits_5 = "Grazie per aver giocato!",
    speakers = {{"LUNA :", {120,235,225}, "luna"}, {"VARGA :", {255,188,83}, "varga"}, {"CONTROLLO :", {140,225,150}, "controle"}},
}
I.STR = STR

local function expand(s)
    return (s:gsub("{(%u+)}", function(k) return I.keyName(k) end))
end
I.expand = expand

-- Texte d'interface : t("key") ou t("key", a, b) (string.format), touches {A}.. remplacees.
function I.t(key, ...)
    local s = (STR[I.lang] and STR[I.lang][key]) or STR.fr[key] or key
    if type(s) ~= "string" then return s end
    s = expand(s)
    if s:find("%", 1, true) then return string.format(s, ...) end
    return s
end
function I.speakers() return (STR[I.lang] or STR.fr).speakers end
function I.onoff(b) return I.t(b and "on" or "off") end

function I.kbLabel()
    if I.kb == "aka" then return "AKA" end
    return I.kb == "azerty" and "AZERTY" or (I.kb == "qwertz" and "QWERTZ" or "QWERTY")
end

return I
