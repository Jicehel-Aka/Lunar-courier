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

M.console = console
return M
