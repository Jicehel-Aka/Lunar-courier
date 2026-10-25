-- Interieurs a pied supplementaires : M10 (epave et boite noire), M11 (acces a Argo-2), M12 (caisson de Varga).
-- Meme moteur que le relais de M9 (communications.lua) : trois salles, une console par salle, portes qui
-- s'ouvrent dans l'ordre. Ce fichier ne contient que les donnees, les textes (interiors_text.lua) et les accessoires dessines.
local M = {}
local I = require("src.i18n")
local TX = require("src.interiors_text")

local function clamp(v) return v < 0 and 0 or (v > 255 and 255 or v) end
local function mul(r, g, b, kr, kg, kb, add) return clamp(r * kr + add), clamp(g * kg + add), clamp(b * kb + add) end

M.kinds = {
    wreck   = {marker = {470, 310, 300}, tint = function(r, g, b) return mul(r, g, b, 1.18, 0.82, 0.72, 6) end},
    argo2   = {marker = {470, 310, 470}, tint = function(r, g, b) return mul(r, g, b, 0.86, 1.04, 1.16, 8) end},
    caisson = {marker = {470, 310, 470}, tint = function(r, g, b) return mul(r, g, b, 1.0, 1.06, 1.04, 5) end},
}
M.kindOfMission = {[10] = "wreck", [11] = "argo2", [12] = "caisson"}
M.kinds.relay = {marker = {470, 310, 470}}     -- relais de M9 : memes donnees d'accessoires, sans teinte

-- Plan commun des 5 salles : 1, 2, 3 = salles a etape (puzzle), 0 = salle de fouille (porte ouverte d'emblee).
M.layout = {1, 0, 2, 0, 3}

-- Texte d'une scene (langue courante, repli francais) ; {A} etc. sont developpes.
function M.T(kind, key)
    local t = TX[I.lang] or TX.fr
    return I.expand(t[kind .. "_" .. key] or TX.fr[kind .. "_" .. key] or "")
end
-- Texte generique partage par toutes les scenes
function M.G(key)
    local t = TX[I.lang] or TX.fr
    return I.expand(t["gen_" .. key] or TX.fr["gen_" .. key] or "")
end

-- Console a l'emplacement x : voyant ambre, puis vert une fois utilisee.
local function console(col, rect, x, done)
    col(30, 54, 70); rect(x - 44, 308, 88, 112); col(8, 21, 35); rect(x - 35, 318, 70, 88)
    col(255, 179, 78); rect(x - 26, 330, 52, 4)
    col(done and 66 or 110, done and 222 or 95, done and 204 or 86)
    rect(x - 24, 345, 12, 12); rect(x - 5, 345, 12, 12); rect(x + 14, 345, 12, 12)
    col(done and 75 or 255, done and 230 or 179, done and 170 or 75); rect(x - 19, 372, 38, 6)
end

-- Accessoires propres a chaque piece (dessines apres la console)
function M.props(kind, room, st, col, rect)
    local d = st.step[room]
    if kind == "wreck" then
        if room == 1 then          -- tole tordue autour du sas, debris au sol
            col(58, 44, 38); rect(130, 330, 120, 10); rect(150, 340, 8, 70); rect(212, 340, 8, 52)
            col(36, 28, 26); rect(260, 420, 90, 10); rect(300, 410, 36, 10)
        elseif room == 2 then      -- couchettes
            for i = 0, 2 do col(46, 40, 44); rect(90 + i * 100, 370, 80, 12); col(72, 64, 70); rect(90 + i * 100, 360, 80, 10) end
        else                       -- boite noire sous la console
            col(20, 18, 20); rect(280, 428, 40, 18)                      -- logement de la boite noire
            if not d then col(255, 130, 40); rect(284, 431, 32, 12) end
        end
    elseif kind == "argo2" then
        col(190, 220, 235)
        if room == 1 then rect(90, 150, 50, 8); rect(110, 158, 6, 50); rect(500, 150, 40, 8); rect(512, 158, 6, 36)
        elseif room == 2 then      -- conduites de chauffage
            col(d and 255 or 90, d and 150 or 110, d and 60 or 130); rect(120, 330, 380, 8); rect(120, 350, 380, 6)
        else                       -- caisson de stase, jauge a 3 %
            col(30, 52, 68); rect(110, 300, 150, 120); col(8, 22, 38); rect(122, 312, 126, 60)
            col(120, 215, 230); rect(130, 320, 110, 6)
            col(255, 94, 78); rect(130, 380, 8, 28); col(28, 45, 60); rect(130, 380, 110, 8); col(255, 94, 78); rect(130, 380, 4, 8)
        end
    else  -- caisson
        if room == 1 then          -- logement du module sur la plateforme
            col(28, 48, 63); rect(250, 380, 120, 22)
            col(d and 75 or 255, d and 230 or 179, d and 170 or 75); rect(280, d and 356 or 372, 60, d and 24 or 8)
        elseif room == 2 then      -- faisceaux de cables
            col(42, 63, 78); rect(110, 374, 420, 12)
            for i = 0, 3 do col(d and 74 or 115, d and 220 or 100, d and 130 or 74); rect(140 + i * 100, 376, 60, 4) end
        else                       -- caisson qui s'ouvre
            local g = d and 30 or 0
            col(30, 52, 68); rect(110 - g, 300, 78, 120); rect(188 + g, 300, 78, 120)
            col(120, 215, 230); rect(130 - g, 330, 40, 40); rect(208 + g, 330, 40, 40)
            if d then col(235, 244, 248); rect(158, 330, 60, 80) end
        end
    end
end


-- ---------------------------------------------------------------------------
-- Salles : feuillets a lire (x = position de l'interaction) et decor (nom, x, parametre)
-- ---------------------------------------------------------------------------
M.rooms = {
    relay = {
        [1] = {notes = {{190, "a"}}, deco = {{"locker", 40}, {"crate", 330}}},
        [2] = {notes = {{120, "a"}, {250, "b"}, {380, "c"}}, deco = {{"shelf", 40}, {"map", 290}, {"table", 300}, {"chair", 396}, {"locker", 470}}},
        [3] = {notes = {{150, "a"}}, deco = {{"pipes", 0, 640}, {"crate", 90}, {"locker", 470}}},
        [4] = {notes = {{110, "a"}, {240, "b"}, {370, "c"}}, deco = {{"table", 110}, {"chair", 210}, {"monitors", 290}, {"screen", 440}}},
        [5] = {notes = {{200, "a"}}, deco = {{"pipes", 0, 420}, {"crate", 60}, {"stack", 330}}},
    },
    wreck = {
        [1] = {notes = {{190, "a"}}, deco = {{"locker", 40}, {"crate", 360}}},
        [2] = {notes = {{110, "a"}, {230, "b"}, {360, "c"}}, deco = {{"stack", 70}, {"crate", 160}, {"stack", 290}, {"crate", 400}, {"debris", 470}}},
        [3] = {notes = {{150, "a"}}, deco = {{"locker", 470}}},
        [4] = {notes = {{110, "a"}, {240, "b"}, {370, "c"}}, deco = {{"table", 90}, {"chair", 190}, {"table", 300}, {"chair", 400}, {"banner", 450}}},
        [5] = {notes = {{140, "a"}}, deco = {{"screen", 400}, {"chair", 180}, {"chair", 230}}},
    },
    argo2 = {
        [1] = {notes = {{190, "a"}}, deco = {{"frost", 20, 120}, {"locker", 40}, {"crate", 360}}},
        [2] = {notes = {{120, "a"}, {250, "b"}, {380, "c"}}, deco = {{"suits", 60}, {"locker", 280}, {"locker", 330}, {"frost", 400, 100}}},
        [3] = {notes = {{150, "a"}}, deco = {{"frost", 40, 200}, {"frost", 340, 220}, {"crate", 470}}},
        [4] = {notes = {{110, "a"}, {240, "b"}, {370, "c"}}, deco = {{"bunk", 30}, {"screen", 300}, {"shelf", 420}, {"chair", 340}}},
        [5] = {notes = {{200, "a"}}, deco = {{"frost", 300, 160}, {"shelf", 300}}},
    },
    caisson = {
        [1] = {notes = {{190, "a"}}, deco = {{"locker", 40}, {"crate", 110}, {"pipes", 0, 640}}},
        [2] = {notes = {{120, "a"}, {250, "b"}, {380, "c"}}, deco = {{"instrument", 70}, {"map", 290}, {"table", 430}, {"screen", 440}}},
        [3] = {notes = {{150, "a"}}, deco = {{"pipes", 0, 300}, {"crate", 470}}},
        [4] = {notes = {{110, "a"}, {240, "b"}, {370, "c"}}, deco = {{"cot", 50}, {"table", 230}, {"shelf", 400}, {"plant", 490}}},
        [5] = {notes = {{200, "a"}}, deco = {{"banner", 300}, {"plant", 360}}},
    },
}

-- Note a portee de x (dans la salle courante) : renvoie la lettre de la note ou nil
function M.noteAt(kind, room, x)
    local r = M.rooms[kind] and M.rooms[kind][room]
    if not r then return nil end
    local best, bd
    for _, n in ipairs(r.notes) do
        local d = math.abs(x - n[1])
        if d <= 40 and (not bd or d < bd) then best, bd = n, d end
    end
    return best and best[2], best and best[1]
end

local P = {}
function P.crate(col, rect, x)
    col(44, 52, 58); rect(x, 401, 56, 50); col(60, 70, 76); rect(x, 401, 56, 6); col(120, 100, 60); rect(x + 24, 401, 8, 50)
end
function P.stack(col, rect, x)
    P.crate(col, rect, x)
    col(52, 60, 66); rect(x + 10, 361, 38, 40); col(66, 76, 82); rect(x + 10, 361, 38, 5); col(120, 100, 60); rect(x + 25, 361, 6, 40)
end
function P.locker(col, rect, x)
    col(26, 43, 57); rect(x, 300, 44, 151); col(40, 62, 78); rect(x + 21, 300, 2, 151)
    col(12, 24, 36); rect(x + 6, 312, 12, 3); rect(x + 6, 320, 12, 3); rect(x + 26, 312, 12, 3); rect(x + 26, 320, 12, 3)
    col(150, 170, 180); rect(x + 16, 370, 3, 10); rect(x + 25, 370, 3, 10)
end
function P.bunk(col, rect, x)
    col(40, 60, 74); rect(x, 420, 96, 6); rect(x + 2, 426, 6, 25); rect(x + 88, 426, 6, 25)
    col(90, 110, 128); rect(x + 2, 408, 92, 12); col(200, 210, 215); rect(x + 4, 402, 26, 6)
end
function P.cot(col, rect, x)
    P.bunk(col, rect, x); col(60, 90, 120); rect(x + 30, 408, 64, 12)
end
function P.table(col, rect, x)
    col(40, 60, 74); rect(x, 404, 84, 6); rect(x + 6, 410, 6, 41); rect(x + 72, 410, 6, 41)
    col(235, 235, 230); rect(x + 30, 394, 12, 10); col(255, 190, 98); rect(x + 42, 397, 4, 5)
end
function P.chair(col, rect, x)
    col(52, 74, 88); rect(x, 420, 34, 5); rect(x, 392, 5, 33); rect(x + 3, 425, 4, 26); rect(x + 27, 425, 4, 26)
end
function P.screen(col, rect, x, _, st)
    col(10, 22, 34); rect(x, 196, 86, 52); col(14, 40, 52); rect(x + 5, 201, 76, 42)
    col(60, 190, 190); rect(x + 9, 208, 50, 3); rect(x + 9, 218, 36, 3); rect(x + 9, 228, 58, 3)
    if st and math.floor((st.t or 0) * 2) % 2 == 0 then col(255, 190, 79); rect(x + 62, 228, 6, 3) end
end
function P.monitors(col, rect, x, _, st)
    for i = 0, 2 do
        local mx = x + i * 48
        col(10, 22, 34); rect(mx, 206, 42, 32); col(14, 40, 52); rect(mx + 3, 209, 36, 26)
        local on = st and math.floor(((st.t or 0) * 1.5) + i) % 3 ~= 0
        if on then col(60, 190, 190) else col(30, 67, 82) end
        rect(mx + 6, 214, 22, 2); rect(mx + 6, 222, 28, 2)
    end
end
function P.map(col, rect, x)
    col(60, 80, 92); rect(x, 176, 100, 64); col(150, 155, 130); rect(x + 4, 180, 92, 56)
    col(60, 90, 100); rect(x + 14, 196, 4, 4); rect(x + 38, 214, 4, 4); rect(x + 66, 192, 4, 4); rect(x + 80, 220, 4, 4)
    col(190, 60, 50); rect(x + 58, 204, 10, 10)
end
function P.pipes(col, rect, x, w)
    col(40, 60, 74); rect(x, 246, w, 8); col(75, 99, 112); rect(x, 246, w, 2)
    for i = 0, math.floor(w / 120) do col(25, 41, 55); rect(x + 30 + i * 120, 240, 6, 20) end
end
function P.banner(col, rect, x)
    col(120, 40, 36); rect(x, 160, 36, 80); col(235, 235, 225); rect(x + 14, 176, 8, 40); rect(x + 6, 192, 24, 8)
end
function P.plant(col, rect, x)
    col(60, 48, 40); rect(x, 426, 26, 25); col(50, 120, 70); rect(x + 4, 396, 6, 30); rect(x + 12, 386, 6, 40); rect(x + 19, 402, 6, 24)
end
function P.suits(col, rect, x)
    for i = 0, 2 do
        local sx = x + i * 52
        if i < 2 then
            col(60, 70, 80); rect(sx + 14, 270, 4, 14)
            col(190, 200, 205); rect(sx, 300, 32, 70); rect(sx + 6, 284, 20, 16); col(80, 120, 140); rect(sx + 10, 288, 12, 8)
            col(170, 180, 186); rect(sx + 2, 370, 12, 50); rect(sx + 18, 370, 12, 50)
            col(225, 238, 245); rect(sx + 4, 302, 24, 3)
        else
            col(60, 70, 80); rect(sx + 14, 270, 4, 14)       -- crochet vide
        end
    end
end
function P.debris(col, rect, x)
    col(36, 28, 26); rect(x, 431, 60, 10); rect(x + 12, 421, 34, 10); rect(x + 40, 441, 40, 10)
end
function P.frost(col, rect, x, w)
    col(200, 225, 240); rect(x, 300, w, 3); rect(x + 6, 303, w - 12, 2); rect(x, 440, w, 4); rect(x + 10, 436, w - 20, 4)
end
function P.shelf(col, rect, x)
    col(40, 60, 74); rect(x, 330, 80, 5); col(80, 90, 100); rect(x + 6, 314, 20, 16); rect(x + 34, 320, 18, 10); rect(x + 58, 312, 14, 18)
end
function P.instrument(col, rect, x, _, st)
    col(60, 70, 80); rect(x + 20, 300, 4, 120)
    local a = st and math.floor((st.t or 0) * 6) % 2 == 0
    col(200, 210, 215)
    if a then rect(x + 8, 296, 10, 6); rect(x + 26, 296, 10, 6) else rect(x + 12, 292, 10, 6); rect(x + 22, 300, 10, 6) end
    col(40, 60, 74); rect(x + 6, 420, 32, 31)
end

-- Decor d'une salle (dessine avant les feuillets et la console)
function M.deco(kind, room, st, col, rect)
    local r = M.rooms[kind] and M.rooms[kind][room]
    if not r then return end
    for _, d in ipairs(r.deco) do
        local f = P[d[1]]
        if f then f(col, rect, d[2], d[3], st) end
    end
end

-- Feuillets muraux (papier clair sur le mur)
function M.drawNotes(kind, room, col, rect)
    local r = M.rooms[kind] and M.rooms[kind][room]
    if not r then return end
    for _, n in ipairs(r.notes) do
        col(210, 205, 170); rect(n[1] - 14, 320, 28, 36)
        col(120, 115, 90); rect(n[1] - 10, 328, 20, 2); rect(n[1] - 10, 335, 20, 2); rect(n[1] - 10, 342, 14, 2)
    end
end

M.console = console
return M
