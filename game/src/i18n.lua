-- LUNAR COURIER - langues (FR/EN), clavier (AKA / AZERTY / QWERTY) et libelles de touches.
-- Tout le texte reste en ASCII pur : le runtime AKA-Love n'affiche pas les accents.
-- Pour ajouter une langue : un fichier text_<code>.lua (histoire), une table dans STR, une entree dans I.langs.
local I = {}

I.langs = {"fr", "en"}                       -- langues disponibles (ordre du menu)
I.langNames = {fr = "FRANCAIS", en = "ENGLISH"}
I.lang = "fr"                                -- francais par defaut
I.kbModes = {"aka", "azerty", "qwerty"}
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
}
function I.keyName(k)
    local set = (I.kb == "aka") and KEYNAMES.aka or (KEYNAMES[I.lang] or KEYNAMES.fr)
    return set[k] or k
end

-- Touches de pilotage : fleches toujours ; lettres selon la disposition choisie.
function I.moveKeys()
    if I.kb == "azerty" then return {left = {"left", "q"}, right = {"right", "d"}, up = {"up", "z"}} end
    if I.kb == "qwerty" then return {left = {"left", "a"}, right = {"right", "d"}, up = {"up", "w"}} end
    return {left = {"left"}, right = {"right"}, up = {"up"}}
end

function I.setLang(code)
    for _, c in ipairs(I.langs) do
        if c == code then
            I.lang = code
            -- Tant que le joueur n'a pas choisi son clavier, il suit la langue (FR -> AZERTY, EN -> QWERTY).
            if not I.kbTouched and not I.aka then I.kb = (code == "fr") and "azerty" or "qwerty" end
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
    return I.kb == "azerty" and "AZERTY" or "QWERTY"
end

return I
