-- Debarquement : apres l'atterrissage (M3, M5, M9), le cosmonaute sort du vaisseau pose et marche
-- jusqu'a l'entree du lieu de la mission avant d'y entrer.  Scene de profil, une seule marche.
-- Le module ne connait ni le ciel ni le vaisseau : game.lua fournit ui.sky, ui.ship et ui.astro.
-- Rectangles uniquement, texte ASCII, ~8 secondes, ignorable avec une touche d'action.
local D = {}

local SITES = {
    argo  = {door=540, text="LUNA : Sas exterieur de la station Argo. Entrez, pilote. Je reste en ligne."},
    coeur = {door=530, text="LUNA : Le Coeur Silencieux. Le module est sur vous : le sas devrait reconnaitre son code."},
    varga = {door=520, text="LUNA : Le campement de Varga. Tout est intact, comme si elle venait de partir."},
}
local SITE_OF = {[3]="argo", [5]="coeur", [9]="varga"}
function D.siteFor(mission) return SITE_OF[mission] end

local SHIP_X, GROUND = 110, 420
local HATCH_X = SHIP_X + 24
local START, SPEED = 1.0, 75

local st = {active=false}
D.s = st

function D.start(site, cb)
    st.active, st.site, st.cfg, st.cb, st.t = true, site, SITES[site], cb, 0
    st.done = false
end

local function astroX(t) return HATCH_X + math.max(0, t - START) * SPEED end

-- Fait avancer la scene ; retourne true quand elle est terminee.
function D.update(dt)
    if not st.active then return false end
    st.t = st.t + dt
    if astroX(st.t) >= st.cfg.door + 36 + 40 then st.done = true end
    return st.done
end

function D.skip() if st.active then st.done = true end end

local function wrapText(text, n)
    local lines, cur = {}, ""
    for word in text:gmatch("%S+") do
        if #cur > 0 and #cur + 1 + #word > n then lines[#lines + 1] = cur; cur = word
        else cur = (#cur > 0) and (cur.." "..word) or word end
    end
    if #cur > 0 then lines[#lines + 1] = cur end
    return lines
end

-- ---- lieux ----------------------------------------------------------------
local function site_argo(ui, open)
    local c, r = ui.color, ui.rect
    local dx = st.cfg.door
    -- panneaux solaires en fond
    c(20, 40, 56); r(300, 372, 70, 6); r(330, 378, 4, 42)
    c(40, 90, 120); r(304, 366, 62, 6)
    -- module : mur de fond
    c(18, 32, 48); r(430, 250, 210, 170)
    c(32, 52, 69); r(430, 250, 210, 8)
    c(65, 88, 104); r(430, 252, 210, 2)
    for i = 0, 3 do c(80, 222, 212); r(446 + i * 40, 280, 22, 8) end
    c(255, 190, 79); r(440, 272, 6, 6)
    -- sas : interieur lumineux quand la porte est ouverte
    c(7, 16, 27); r(dx - 22, 336, 44, 84)
    if open > 0 then c(60, 120, 130); r(dx - 18 + math.floor(18 * (1 - open)), 340, 36 - math.floor(36 * (1 - open)), 80) end
end
local function front_argo(ui, open)
    local c, r = ui.color, ui.rect
    local dx = st.cfg.door
    c(50, 75, 91); r(dx - 26, 332, 52, 4); r(dx - 26, 332, 4, 88); r(dx + 22, 332, 4, 88)
    -- vantaux qui coulissent
    local half = math.floor(20 * (1 - open))
    c(32, 58, 75); r(dx - 22, 336, half, 84); r(dx + 22 - half, 336, half, 84)
    c(255, 161, 55); r(dx - 3, 322, 6, 5)
    -- masque : le cosmonaute disparait derriere le montant droit
    c(18, 32, 48); r(dx + 26, 250, 640, 170)
    c(32, 52, 69); r(dx + 26, 250, 640, 8)
    c(80, 222, 212); r(dx + 50, 280, 22, 8)
end

local function site_coeur(ui, open)
    local c, r = ui.color, ui.rect
    local dx = st.cfg.door
    -- arches en ruine a gauche
    c(52, 72, 88); r(240, 340, 14, 80); r(300, 340, 14, 80); r(236, 330, 82, 12)
    -- voute en gradins
    c(14, 26, 44); r(400, 330, 240, 90); r(420, 290, 220, 40); r(450, 258, 190, 32); r(490, 232, 150, 26)
    c(60, 100, 130); r(400, 330, 240, 3); r(420, 290, 220, 3); r(450, 258, 190, 3); r(490, 232, 150, 3)
    c(150, 205, 230); r(560, 244, 10, 4); r(540, 300, 8, 4)
    c(7, 14, 26); r(dx - 28, 340, 56, 80)
    if open > 0 then c(110, 190, 225); r(dx - 24 + math.floor(24 * (1 - open)), 344, 48 - math.floor(48 * (1 - open)), 76) end
end
local function front_coeur(ui, open)
    local c, r = ui.color, ui.rect
    local dx = st.cfg.door
    c(60, 100, 130); r(dx - 32, 336, 64, 4); r(dx - 32, 336, 4, 84); r(dx + 28, 336, 4, 84)
    local half = math.floor(24 * (1 - open))
    c(30, 60, 85); r(dx - 28, 340, half, 80); r(dx + 28 - half, 340, half, 80)
    c(150, 205, 230); r(dx - 3, 326, 6, 6)
    c(14, 26, 44); r(dx + 32, 232, 640, 188)
    c(60, 100, 130); r(dx + 32, 232, 640, 3)
end

local function site_varga(ui, open)
    local c, r = ui.color, ui.rect
    local dx = st.cfg.door
    -- panneaux solaires propres (quelqu'un les nettoie)
    c(20, 40, 56); r(300, 380, 60, 4); r(326, 384, 4, 36)
    c(60, 130, 170); r(304, 372, 52, 8)
    -- parabole sur mat
    c(60, 80, 95); r(590, 300, 4, 120)
    c(150, 175, 185); r(578, 296, 28, 4); r(582, 290, 20, 4); r(586, 284, 12, 4)
    c(255, 190, 79); r(592, 276, 4, 8)
    -- tente-abri en gradins
    c(46, 62, 74); r(440, 380, 150, 40); r(452, 352, 126, 28); r(468, 328, 94, 24); r(488, 308, 54, 20)
    c(90, 112, 124); r(440, 380, 150, 2); r(452, 352, 126, 2); r(468, 328, 94, 2)
    -- entree sombre
    c(6, 12, 20); r(dx - 18, 352, 36, 68)
    if open > 0 then c(150, 110, 50); r(dx - 14, 356, 28, 64) end
end
local function front_varga(ui, open)
    local c, r = ui.color, ui.rect
    local dx = st.cfg.door
    -- rabat de toile qui se leve, puis masque a droite de l'entree
    c(70, 90, 102); r(dx - 18, 348, 36, 4)
    local flap = math.floor(60 * (1 - open))
    c(46, 62, 74); r(dx - 18, 352, 36, flap)
    c(46, 62, 74); r(dx + 18, 330, 640, 90)
    c(90, 112, 124); r(dx + 18, 330, 640, 2)
    -- poste radio devant la tente
    c(30, 44, 56); r(dx - 78, 394, 26, 26)
    c(75, 220, 184); r(dx - 72, 400, 14, 4)
    c(150, 175, 185); r(dx - 66, 376, 2, 18)
end

local DRAW = {
    argo = {site_argo, front_argo}, coeur = {site_coeur, front_coeur}, varga = {site_varga, front_varga},
}

-- ui : color, rect, panel, f16, sky(), ship(), astro(group, frame, x, feetY)
function D.draw(ui)
    if not st.active then return end
    local t = st.t
    ui.sky()
    local c, r = ui.color, ui.rect
    -- sol lunaire
    c(30, 52, 70); r(0, GROUND, 640, 60)
    c(70, 91, 105); r(0, GROUND, 640, 3)
    c(22, 40, 56); for i = 0, 15 do r(i * 44 + 8, GROUND + 14 + (i % 3) * 10, 18, 3) end
    -- vaisseau pose + sas qui s'allume
    ui.ship()
    if t > 0.3 then c(255, 179, 64); r(SHIP_X + 12, GROUND - 22, 5, 9) end
    local dx = st.cfg.door
    local x = astroX(t)
    local open = math.max(0, math.min(1, (x - (dx - 100)) / 70))
    local pair = DRAW[st.site]
    pair[1](ui, open)
    -- cosmonaute
    if t >= START then
        local walking = x < dx + 76
        ui.astro(walking and "walk_right" or "orientation_right", 1 + math.floor((t - START) * 8) % 4, math.floor(x), GROUND + 10)
    end
    pair[2](ui, open)
    -- sous-titre de LUNA
    ui.panel(22, 16, 596, 84)
    c(255, 177, 78); love.graphics.setFont(ui.f16)
    love.graphics.printf("LUNA // TRANSMISSION", 36, 22, 570, "left")
    c(206, 222, 230)
    local lines = wrapText(st.cfg.text, 34)
    local shown = math.floor(t * 40)
    for i = 1, math.min(3, #lines) do
        if shown > 0 then love.graphics.printf(lines[i]:sub(1, shown), 36, 44 + (i - 1) * 18, 570, "left") end
        shown = shown - #lines[i] - 1
    end
    c(255, 190, 98); love.graphics.printf("E / ESPACE : PASSER", 0, 446, 640, "center")
end

return D
