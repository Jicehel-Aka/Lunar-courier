-- Station Argo (mission 3) : quatre pieces reliees par des portes.
--   1 SAS D'ACCES      : la porte s'ouvre en appuyant simplement sur la console.
--   2 COULOIR DE SERVICE : probleme des trois relais (ordre 1, 2, 3, indice sur la plaque).
--   3 SALLE D'ENERGIE  : mini-jeu de repartition d'energie (indices sur les notes de Varga).
--   4 ARCHIVES         : journal de Varga (3 pages), puis sortie par la console du sas.
-- Module sans etat global : game.lua appelle reset / update / interact / draw.
-- Ecran virtuel 640x480, texte ASCII, polygones interdits (rectangles seulement).
local S = {}

local ROOMS = 4
S.ROOMS = ROOMS
S.names = {"SAS D'ACCES", "COULOIR DE SERVICE", "SALLE D'ENERGIE", "ARCHIVES"}

local LIGHT = {0.62, 0.8, 0.95, 1.12}      -- la station se rallume piece apres piece
local FLOOR_Y = 451
local REACH = 36

local ITEMS = {
    [1] = {{x=150, k="note", id="r1"}, {x=470, k="door"}},
    [2] = {{x=120, k="note", id="r2"}, {x=190, k="relay", id=1}, {x=270, k="relay", id=2}, {x=350, k="relay", id=3}, {x=470, k="door"}},
    [3] = {{x=120, k="note", id="r3a"}, {x=250, k="note", id="r3b"}, {x=470, k="energy"}},
    [4] = {{x=300, k="journal"}, {x=470, k="exit"}},
}

-- Textes : au plus ~90 caracteres (console de LUNA : 4 lignes de 24).
local NOTES = {
    r1  = "PLAQUE : ARGO, RELAIS LUNAIRE. EQUIPAGE : 1. V. VARGA, INGENIEURE.",
    r2  = "NOTICE : redemarrage en 3 temps. Relais 1, puis 2, puis 3, de gauche a droite.",
    r3a = "NOTE DE VARGA : le journal ne se lit pas dans le noir. Il faut de la lumiere.",
    r3b = "NOTE DE VARGA : reserve de 6 unites. Sas 2, balise 1, eclairage 1, journal 3.",
}
local PAGES = {
    "VARGA, JOUR 12 : plus de relais. Je garde la balise allumee, quoi qu'il arrive.",
    "VARGA, JOUR 30 : quelqu'un nettoie les panneaux solaires. Ce n'est pas moi.",
    "SIGNAL RECU 00:00:03 AVANT SON EMISSION. IMPOSSIBLE. Il vient de la face cachee.",
}
local ARRIVE = {
    "LUNA : Sas interieur. Appuyez sur la console pres de la porte.",
    "LUNA : Un couloir de service. Les relais sont numerotes. Cherchez la notice.",
    "LUNA : La salle d'energie. Varga a laisse des notes sur les murs.",
    "LUNA : Les archives. Quelqu'un a nettoye ici. Tres recemment.",
}

-- Mini-jeu d'energie : reserve de 6 unites, il faut SAS + JOURNAL, et le journal exige l'ECLAIRAGE.
local CIRCUITS = {
    {id="sas",     label="SAS",       cost=2},
    {id="balise",  label="BALISE",    cost=1},
    {id="light",   label="ECLAIRAGE", cost=1},
    {id="journal", label="JOURNAL",   cost=3},
}
local BUDGET = 6
S.BUDGET = BUDGET
S.CIRCUITS = CIRCUITS

local st

function S.reset()
    st = {room=1, door={false,false,false,false}, anim={0,0,0,0}, repairs=0, solved=false,
          pages=0, logRead=false, mode="walk", sel=1, power={}, fails=0, flash=0, status="",
          t=0, msg=nil, msgD=0, visited={}}
    S.s = st
    S.enter(1)
end
function S.enter(r)
    st.room = r
    if not st.visited[r] then
        st.visited[r] = true
        st.msg, st.msgD = ARRIVE[r], 4.5
    end
end

function S.takeMsg()
    local m, d = st.msg, st.msgD
    st.msg = nil
    return m, d
end

local function say(m, d) st.msg, st.msgD = m, d or 4 end

local function used()
    local u = 0
    for _, c in ipairs(CIRCUITS) do if st.power[c.id] then u = u + c.cost end end
    return u
end
S.used = used

local function isSolved()
    return st.power.sas and st.power.journal and st.power.light and used() <= BUDGET
end

-- Limites de deplacement de l'explorateur dans la piece courante.
-- Les portes sont des passages : on traverse la porte ouverte (centre x=565) pour changer de piece.
local DOOR_X, ARRIVE_X, FADE = 565, 56, 0.6
function S.minX() return st.room == 1 and 42 or 36 end
function S.maxX() return (st.room < ROOMS and st.door[st.room]) and (DOOR_X + 4) or 500 end

function S.update(dt, ex)
    st.t = st.t + dt
    st.flash = math.max(0, st.flash - dt)
    for r = 1, ROOMS do
        local target = st.door[r] and 1 or 0
        local a = st.anim[r]
        if a < target then a = math.min(target, a + dt * 1.6) elseif a > target then a = math.max(target, a - dt * 1.6) end
        st.anim[r] = a
    end
    if st.mode == "transit" and ex then
        st.tt = st.tt + dt
        if not st.switched and st.tt >= FADE / 2 then
            st.switched = true
            S.enter(st.to)
            ex.x = st.dir > 0 and ARRIVE_X or DOOR_X - 25
            ex.facing = st.dir
        end
        if st.tt >= FADE then st.mode = "walk" end
        return
    end
    if st.mode ~= "walk" or not ex then return end
    if st.room < ROOMS and st.door[st.room] and ex.x >= DOOR_X - 5 then
        st.mode, st.tt, st.switched, st.to, st.dir = "transit", 0, false, st.room + 1, 1
    elseif st.room > 1 and ex.x <= 44 then
        st.mode, st.tt, st.switched, st.to, st.dir = "transit", 0, false, st.room - 1, -1
    end
end

local function nearest(x)
    local best, bd
    for _, it in ipairs(ITEMS[st.room]) do
        local d = math.abs(x - it.x)
        if d <= REACH and (not bd or d < bd) then best, bd = it, d end
    end
    return best
end
S.nearest = nearest

function S.objective()
    local r = st.room
    if r == 1 then return st.door[1] and "SAS OUVERT - COULOIR" or "SAS : APPUYER SUR LA CONSOLE" end
    if r == 2 then return st.repairs >= 3 and "RELAIS 3/3 - PORTE OUVERTE" or ("RELAIS  "..st.repairs.."/3") end
    if r == 3 then return st.solved and "ENERGIE OK - PORTE OUVERTE" or "ENERGIE : SAS + JOURNAL" end
    return st.logRead and "RAPPORT COPIE - ACCES AU SAS" or ("JOURNAL DE VARGA  "..st.pages.."/3")
end

function S.hint()
    local r = st.room
    if r == 1 then return st.door[1] and "La porte est ouverte. Avancez a droite." or "Appuyez sur la console, pres de la porte." end
    if r == 2 then
        if st.repairs >= 3 then return "Le reseau est stable. Avancez a droite." end
        return "Relancer les relais dans l'ordre. La notice est a gauche."
    end
    if r == 3 then
        if st.solved then return "Energie repartie. La porte est ouverte." end
        return "Lisez les notes, puis utilisez la console de la porte."
    end
    if st.logRead then return "Rapport copie. Rejoignez la console du sas." end
    return "Consultez le journal sur le terminal central."
end

-- Action du joueur a la position x. Retourne (message, evenement) ; evenement "ok" ou "exit".
function S.interact(x)
    if st.mode ~= "walk" then return nil end
    local it = nearest(x)
    if not it then return "LUNA : Approchez-vous d'une console ou d'un panneau.", nil end
    local r = st.room
    if it.k == "note" then
        return NOTES[it.id], "ok"
    elseif it.k == "door" then
        if r == 1 then
            if st.door[1] then return "La porte est deja ouverte.", nil end
            st.door[1] = true
            return "Porte ouverte. LUNA : Rien n'a coupe l'alimentation du sas. Etrange.", "ok"
        end
        if st.repairs < 3 then return "Porte verrouillee : circuits hors service. Relancez les relais.", nil end
        return "La porte est ouverte.", nil
    elseif it.k == "relay" then
        if st.repairs >= 3 or it.id <= st.repairs then return "Ce relais est deja actif.", nil end
        if it.id ~= st.repairs + 1 then return "LUNA : Pas dans cet ordre. La notice dit : 1, puis 2, puis 3.", nil end
        st.repairs = it.id
        if it.id == 1 then return "LUNA : Relais 1 stable. Un circuit etait deja alimente. Par qui ?", "ok" end
        if it.id == 2 then return "LUNA : Deux relais actifs. Le signal ne vient pas de la station...", "ok" end
        st.door[2] = true
        return "LUNA : Reseau restaure. Ce signal ne figure sur aucune carte. La porte s'ouvre.", "ok"
    elseif it.k == "energy" then
        if st.solved then return "La repartition d'energie est correcte. La porte est ouverte.", nil end
        st.mode, st.sel, st.status = "energy", 1, "Alimentez le SAS et le JOURNAL."
        return nil, "ok"
    elseif it.k == "journal" then
        if st.pages < 3 then
            st.pages = st.pages + 1
            if st.pages == 3 then st.logRead = true end
            return PAGES[st.pages], "ok"
        end
        return PAGES[3], nil
    elseif it.k == "exit" then
        if not st.logRead then return "Console verrouillee : lisez d'abord le journal de Varga.", nil end
        return "RAPPORT VARGA copie. Ouverture du sas.", "exit"
    end
end

-- Touches du mini-jeu. Retourne true si la touche est consommee.
function S.key(k)
    if st.mode ~= "energy" then return false end
    if k == "up" or k == "left" or k == "z" or k == "q" then
        st.sel = st.sel - 1; if st.sel < 1 then st.sel = #CIRCUITS + 1 end
        return true, "move"
    elseif k == "down" or k == "right" or k == "s" or k == "d" then
        st.sel = st.sel + 1; if st.sel > #CIRCUITS + 1 then st.sel = 1 end
        return true, "move"
    elseif k == "escape" or k == "x" then
        st.mode = "walk"
        return true, "move"
    elseif k == "e" or k == "a" or k == "return" or k == "space" then
        if st.sel > #CIRCUITS then st.mode = "walk"; return true, "move" end
        local c = CIRCUITS[st.sel]
        if st.power[c.id] then
            st.power[c.id] = false
            st.status = c.label.." coupe."
        elseif used() + c.cost > BUDGET then
            st.fails, st.flash = st.fails + 1, 0.5
            st.status = "SURCHARGE : la reserve est de "..BUDGET.." unites. Coupez un circuit."
            return true, "bad"
        else
            st.power[c.id] = true
            st.status = c.label.." alimente."
        end
        if st.power.journal and not st.power.light then
            st.status = "Le journal est allume mais illisible : il fait noir."
            st.fails = st.fails + 1
        elseif not st.power.sas then
            st.status = st.status.." Le SAS doit rester alimente."
        end
        if isSolved() then
            st.solved, st.door[3], st.mode = true, true, "walk"
            if st.power.balise then st.power.balise = false end
            say("Energie repartie. Balise coupee... mais le signal continue d'arriver. La porte s'ouvre.", 5)
            return true, "solved"
        end
        return true, "ok"
    end
    return true
end

-- ---------------------------------------------------------------------------
-- Dessin (rectangles uniquement)
-- ---------------------------------------------------------------------------
local gfx
local function col(r, g, b, k)
    k = k or LIGHT[st.room]
    gfx.setColor(math.min(1, r * k / 255), math.min(1, g * k / 255), math.min(1, b * k / 255))
end
local function raw(r, g, b) gfx.setColor(r / 255, g / 255, b / 255) end
local function rect(x, y, w, h) gfx.rectangle("fill", x, y, w, h) end

-- petits chiffres 3x5 pour numeroter les relais
local GLYPH = {
    [1] = {"010", "110", "010", "010", "111"},
    [2] = {"111", "001", "111", "100", "111"},
    [3] = {"111", "001", "111", "001", "111"},
}
local function digit(n, x, y, s)
    for j, row in ipairs(GLYPH[n]) do
        for i = 1, 3 do
            if row:sub(i, i) == "1" then rect(x + (i - 1) * s, y + (j - 1) * s, s, s) end
        end
    end
end

local function shell(r, t)
    gfx = love.graphics
    -- Chaque zone n'est remplie qu'une fois (le runtime AKA remplit en logiciel : le surdessin coute cher).
    col(3, 8, 19); rect(0, 118, 640, 150)               -- fond visible entre mur haut et mur bas
    col(18, 32, 48); rect(0, 0, 640, 118)
    col(32, 52, 69); rect(0, 92, 640, 26); rect(0, 268, 640, 12)
    col(65, 88, 104); rect(0, 94, 640, 3); rect(0, 274, 640, 3)
    for i = 0, 10 do
        local x = i * 64
        col(25, 43, 59); rect(x, 0, 4, 116); rect(x + 5, 8, 2, 83)
    end
    -- plancher
    col(50, 70, 84); rect(0, 280, 640, 5)
    col(22, 39, 53); rect(0, 285, 640, 195)
    for i = 0, 15 do
        col(39, 57, 70); rect(i * 44, 300, 2, 150)
    end
    col(95, 110, 115); rect(0, 451, 640, 4)
    col(240, 157, 54); rect(20, 456, 44, 4); rect(76, 456, 44, 4); rect(132, 456, 44, 4)
    col(24, 40, 54); rect(0, 462, 640, 18)
end

local function ceilingLights(r, t)
    if r == 1 then
        local p = math.floor((math.sin(t * 3) + 1) * 2)
        raw(255, 75, 58); rect(38, 101, 18, 5 + p); rect(584, 101, 18, 5 + p); rect(300, 101, 18, 5 + p)
    elseif r == 2 then
        local on = math.floor(t * 5) % 7 ~= 0
        raw(255, 170, 70); rect(120, 101, 26, 4)
        if on then rect(300, 101, 26, 4) end
        raw(80, 222, 212); rect(480, 101, 26, 4)
    elseif r == 3 then
        local fl = math.floor(t * 9) % 5
        raw(80, 222, 212); rect(100, 101, 30, 4); rect(380, 101, 30, 4)
        if fl ~= 0 then rect(240, 101, 30, 4) end
    else
        raw(120, 240, 228); rect(80, 101, 40, 4); rect(220, 101, 40, 4); rect(360, 101, 40, 4); rect(500, 101, 40, 4)
        raw(230, 245, 245); rect(90, 99, 20, 2); rect(230, 99, 20, 2); rect(370, 99, 20, 2); rect(510, 99, 20, 2)
    end
end

local function window(x, w)
    col(8, 20, 37); rect(x - 8, 116, w + 16, 156)
    col(18, 39, 58); rect(x, 124, w, 140)
    col(4, 12, 28); rect(x + 10, 134, w - 20, 118)
    col(30, 52, 70); rect(x + 10, 211, w - 20, 30)
    col(70, 91, 105); rect(x + 10, 225, w - 20, 2)
    col(13, 39, 68); rect(x + w - 90, 157, 54, 34)
    col(50, 118, 157); rect(x + w - 83, 163, 40, 22)
    col(170, 215, 229); rect(x + w - 74, 167, 8, 3); rect(x + w - 62, 174, 10, 4)
    col(205, 220, 226); rect(x + math.floor(w / 3), 134, 2, 118); rect(x + math.floor(2 * w / 3), 134, 2, 118)
end

local function propsRoom1(t)
    window(110, 330)
    -- ecoutille exterieure fermee a gauche
    col(7, 16, 27); rect(0, 165, 40, 286)
    col(50, 75, 91); rect(36, 165, 4, 286)
    raw(255, 75, 58); rect(10, 300, 20, 5)
end

local function propsRoom2(t)
    -- tuyaux de plafond et gaines
    col(40, 60, 74); rect(0, 124, 640, 10); rect(0, 142, 640, 6)
    col(75, 99, 112); rect(0, 124, 640, 2); rect(0, 142, 640, 2)
    for i = 0, 7 do col(25, 41, 55); rect(40 + i * 80, 124, 6, 24) end
    -- cables rompus au sol
    col(3, 9, 17); rect(400, 431, 60, 5); rect(410, 436, 5, 12)
    raw(232, 143, 45); rect(404, 429, 22, 2)
    -- trois relais numerotes
    for i = 1, 3 do
        local px = 190 + (i - 1) * 80 - 27
        local active = st.repairs >= i
        col(7, 15, 26); rect(px, 300, 54, 84)
        col(56, 80, 96); rect(px, 300, 54, 4); rect(px, 300, 3, 84); rect(px + 51, 300, 3, 84)
        col(20, 39, 54); rect(px + 7, 311, 40, 60)
        col(9, 21, 34); rect(px + 11, 316, 32, 28)
        if active then raw(75, 220, 184) else raw(30, 67, 82) end
        rect(px + 15, 320, 24, 4)
        if active then raw(75, 220, 184) else raw(255, 164, 57) end
        digit(i, px + 21, 328, 3)
        raw(100, 123, 133); rect(px + 15, 352, 24, 2)
    end
end

local function propsRoom3(t)
    -- cuves d'energie et noyau central pulse
    for i = 0, 2 do
        local x = 180 + i * 80
        col(10, 22, 34); rect(x, 190, 60, 96)
        col(38, 60, 76); rect(x, 190, 60, 4); rect(x, 282, 60, 4)
        col(16, 38, 52); rect(x + 6, 200, 48, 76)
        local h = 20 + ((math.floor(t * 2 + i) % 3) * 12)
        raw(60, 190, 190); rect(x + 10, 272 - h, 40, h)
    end
    local p = math.floor((math.sin(t * 4) + 1) * 2)
    col(12, 24, 36); rect(420, 300, 18, 140)
    raw(111, 242, 226); rect(424, 320, 10, 8 + p * 3)
    col(3, 9, 17); rect(40, 431, 70, 5)
    raw(232, 143, 45); rect(48, 429, 26, 2)
end

local function propsRoom4(t)
    window(250, 300)
    -- baies de serveurs
    for i = 0, 2 do
        local x = 112 + i * 20
        col(10, 22, 34); rect(x, 300, 16, 150)
        for j = 0, 6 do
            local on = (math.floor(t * 3 + i * 2 + j) % 3) ~= 0
            if on then raw(80, 222, 212) else raw(30, 67, 82) end
            rect(x + 3, 306 + j * 20, 10, 3)
        end
    end
    -- table et tasse
    col(40, 60, 74); rect(180, 400, 70, 6); rect(187, 406, 6, 45); rect(237, 406, 6, 45)
    raw(240, 240, 235); rect(207, 388, 14, 12)
    raw(255, 190, 98); rect(221, 391, 4, 6)
    col(150, 175, 185); rect(209, 382, 2, 5 + math.floor(t * 2) % 2)
    -- terminal central du journal
    col(7, 16, 27); rect(270, 330, 60, 120)
    col(50, 75, 91); rect(270, 330, 60, 4)
    col(11, 24, 39); rect(278, 340, 44, 44)
    raw(71, 208, 206); rect(282, 346, 36, 4); rect(282, 355, 36, 3); rect(282, 362, 24, 3); rect(282, 369, 30, 3)
    if st.pages < 3 and math.floor(t * 3) % 2 == 0 then raw(255, 169, 60); rect(282, 376, 6, 3) end
end

local function doorAt(r, x, anim, locked)
    -- porte coulissante : deux vantaux qui se retirent
    col(7, 16, 27); rect(x, 230, 90, 221)
    local half = math.floor(40 * (1 - anim))
    col(32, 58, 75); rect(x + 4, 234, half, 217); rect(x + 86 - half, 234, half, 217)
    col(50, 75, 91); rect(x, 230, 90, 4); rect(x, 230, 4, 221); rect(x + 86, 230, 4, 221)
    if anim < 0.9 then
        if locked then raw(255, 161, 55) else raw(75, 220, 184) end
        rect(x + 40, 250, 10, 5)
    end
    if anim > 0.05 then col(14, 30, 44); rect(x + 4 + half, 234, 82 - 2 * half, 217) end
end

local function consoleAt(x, state, t)
    -- state : "locked", "open", "game"
    col(7, 16, 27); rect(x - 14, 320, 28, 80)
    col(50, 75, 91); rect(x - 14, 320, 28, 4)
    col(11, 24, 39); rect(x - 10, 328, 20, 24)
    if state == "locked" then raw(255, 161, 55) elseif state == "open" then raw(75, 220, 184) else raw(255, 190, 98) end
    rect(x - 8, 332, 16, 3)
    if state == "game" then raw(111, 242, 226); rect(x - 8, 340, 10, 3) end
    raw(255, 169, 60); rect(x - 6, 360, 12, 6)
end

function S.draw(ex)
    local r, t = st.room, st.t
    gfx = love.graphics
    shell(r, t)
    if r == 1 then propsRoom1(t) elseif r == 2 then propsRoom2(t) elseif r == 3 then propsRoom3(t) else propsRoom4(t) end
    -- notes murales (plaques et feuillets)
    for _, it in ipairs(ITEMS[r]) do
        if it.k == "note" then
            col(210, 205, 170); rect(it.x - 14, 320, 28, 36)
            col(120, 115, 90); rect(it.x - 10, 328, 20, 2); rect(it.x - 10, 335, 20, 2); rect(it.x - 10, 342, 14, 2)
        end
    end
    -- porte de droite et console associee
    if r < ROOMS then
        doorAt(r, 520, st.anim[r], not st.door[r])
        local state = st.door[r] and "open" or ((r == 3) and "game" or "locked")
        consoleAt(470, state, t)
    else
        doorAt(r, 520, st.anim[4], not st.logRead)
        consoleAt(470, st.logRead and "open" or "locked", t)
    end
    -- passage ouvert vers la piece precedente
    if r > 1 then doorAt(r, 8, 1, false) end
    ceilingLights(r, t)
    -- repere clignotant sur l'element a portee
    if st.mode == "walk" and ex then
        local it = nearest(ex.x)
        if it then
            if math.floor(t * 4) % 2 == 0 then raw(255, 190, 79); rect(it.x - 4, 296, 8, 6); rect(it.x - 2, 302, 4, 3) end
        end
    end
end

-- Interface du mini-jeu (ui : color, rect, panel, f16, f24).
local function wrapText(text, n)
    local lines, cur = {}, ""
    for word in text:gmatch("%S+") do
        if #cur > 0 and #cur + 1 + #word > n then lines[#lines + 1] = cur; cur = word
        else cur = (#cur > 0) and (cur.." "..word) or word end
    end
    if #cur > 0 then lines[#lines + 1] = cur end
    return lines
end

function S.drawEnergy(ui)
    if st.mode == "transit" and st.tt > FADE * 0.2 and st.tt < FADE * 0.8 then
        ui.color(0, 0, 0); ui.rect(0, 0, 640, 480)
        return
    end
    if st.mode ~= "energy" then return end
    local g = love.graphics
    ui.panel(60, 96, 520, 346)
    g.setFont(ui.f16)
    ui.color(255, 177, 78); g.printf("RESEAU D'ENERGIE - ARGO", 84, 106, 472, "left")
    ui.color(43, 205, 211); ui.rect(74, 130, 492, 1)
    for i, c in ipairs(CIRCUITS) do
        local y = 140 + (i - 1) * 42
        local on = st.power[c.id]
        if st.sel == i then
            ui.color(20, 52, 66); ui.rect(70, y - 6, 500, 34)
            ui.color(255, 190, 79); g.printf(">", 80, y, 20, "left")
        end
        ui.color(on and 135 or 120, on and 239 or 140, on and 231 or 150)
        g.printf(c.label, 108, y, 160, "left")
        ui.color(255, 190, 98); g.printf(c.cost.." U", 280, y, 60, "left")
        if on then ui.color(75, 220, 184) else ui.color(150, 100, 90) end
        g.printf(on and "ON" or "OFF", 350, y, 50, "left")
        if c.id == "journal" and on and not st.power.light then
            ui.color(255, 120, 90); g.printf("ILLISIBLE", 420, y, 146, "left")
        elseif c.id == "balise" and on then
            ui.color(255, 190, 98); g.printf("EMET", 420, y, 146, "left")
        end
    end
    local yq = 140 + #CIRCUITS * 42
    if st.sel > #CIRCUITS then
        ui.color(20, 52, 66); ui.rect(70, yq - 6, 500, 34)
        ui.color(255, 190, 79); g.printf(">", 80, yq, 20, "left")
    end
    ui.color(160, 180, 190); g.printf("QUITTER", 108, yq, 160, "left")
    -- jauge de reserve
    local yb = yq + 40
    ui.color(214, 225, 230); g.printf("RESERVE", 84, yb, 120, "left")
    local u = used()
    for i = 1, BUDGET do
        if i <= u then
            if st.flash > 0 and math.floor(st.flash * 12) % 2 == 0 then ui.color(244, 93, 85) else ui.color(75, 220, 184) end
        else ui.color(25, 55, 70) end
        ui.rect(220 + (i - 1) * 40, yb, 32, 20)
    end
    ui.color(255, 190, 98); g.printf(u.."/"..BUDGET, 480, yb, 80, "left")
    -- message d'etat (3 lignes de 29 caracteres)
    ui.color(206, 222, 230)
    local lines = wrapText(st.status, 29)
    for i = 1, math.min(3, #lines) do g.printf(lines[i], 84, yb + 30 + (i - 1) * 19, 472, "left")
    end
end

S.reset()

return S
