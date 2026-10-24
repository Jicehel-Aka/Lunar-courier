-- Debarquement : apres l'atterrissage (M3, M5, M9), le cosmonaute sort du vaisseau pose, descend
-- l'echelle et marche jusqu'a l'entree du lieu de la mission avant d'y entrer.
-- Echelle reelle : le vaisseau fait 6 fois la taille du cosmonaute.  La camera part d'un plan large
-- (vaisseau a sa taille de vol), zoome en continu pendant la sortie et atteint le 1:1 quand le
-- cosmonaute touche le sol.  Le monde est dessine a l'echelle 1:1 puis transforme par la camera.
-- game.lua fournit ui.sky, ui.ship (dessine le vaisseau en 0,0 a sa taille de vol) et ui.astro.
-- Rectangles uniquement, texte ASCII, touche d'action pour passer la scene.
local D = {}

local G = 420                    -- sol (monde, echelle 1:1)
local FEET = G + 10              -- les pieds s'enfoncent un peu dans le sol
local WALL_BOTTOM = G + 18       -- les murs descendent plus bas que les pieds
local S = 17.2                   -- vaisseau : de sa taille de vol (26 px) a 6 x 76 px
local Z0 = 1 / S
local T_WIDE, T_HATCH = 1.2, 2.0
local T_EXIT = 2.6               -- le cosmonaute apparait dans la porte
local HATCH_X0, HATCH_X1 = 80, 128
local HATCH_TOP, GANG_Y = G - 265, G - 145
local LADDER_X = 205
local T_LADDER = T_EXIT + (LADDER_X - 104) / 60
local T_WALK = T_LADDER + 2.2    -- zoom 1:1 atteint ici
local WALK_SPEED = 120

local SITES = {
    argo  = {door=820, text="LUNA : Sas exterieur de la station Argo. Entrez, pilote. Je reste en ligne."},
    coeur = {door=830, text="LUNA : Le Coeur Silencieux. Le module est sur vous : le sas devrait reconnaitre son code."},
    varga = {door=820, text="LUNA : Le campement de Varga. Tout est intact, comme si elle venait de partir."},
}
local SITE_OF = {[3]="argo", [5]="coeur", [9]="varga"}
function D.siteFor(mission) return SITE_OF[mission] end

local st = {active=false}
D.s = st

function D.start(site, cb)
    st.active, st.site, st.cfg, st.cb, st.t = true, site, SITES[site], cb, 0
    st.done = false
end

-- Position du cosmonaute : x, y des pieds, groupe de sprites (nil tant qu'il n'est pas sorti).
local function astro(t)
    if t < T_EXIT then return nil end
    if t < T_LADDER then return math.min(LADDER_X, 104 + (t - T_EXIT) * 60), GANG_Y, "walk_right" end
    if t < T_WALK then
        local f = (t - T_LADDER) / (T_WALK - T_LADDER)
        return LADDER_X, GANG_Y + (FEET - GANG_Y) * f, "orientation_up"
    end
    return LADDER_X + (t - T_WALK) * WALK_SPEED, FEET, "walk_right"
end

local function zoomAt(t)
    if t <= T_WIDE then return Z0, 0 end
    if t >= T_WALK then return 1, 1 end
    local u = (t - T_WIDE) / (T_WALK - T_WIDE)
    return Z0 * (1 / Z0) ^ u, u
end

function D.update(dt)
    if not st.active then return false end
    st.t = st.t + dt
    local x = astro(st.t)
    if x and x >= st.cfg.door + 76 + 44 then st.done = true end
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

-- ---- lieux (coordonnees monde, dx = x de la porte) -------------------------
-- back : fond et interieur (avant le cosmonaute) ; front : cadre et masque (apres)
local function back_argo(ui, dx, open)
    local c, r = ui.color, ui.rect
    c(20, 40, 56); r(dx - 240, 372, 70, 6); r(dx - 210, 378, 4, 42)      -- panneaux solaires
    c(40, 90, 120); r(dx - 236, 366, 62, 6)
    c(18, 32, 48); r(dx - 110, G - 600, 2400, 600 + 18)                  -- masse de la station
    c(32, 52, 69); r(dx - 110, G - 600, 2400, 10); r(dx - 110, G - 170, 2400, 6)
    for i = 0, 3 do c(80, 222, 212); r(dx - 94 + i * 40, 280, 22, 8) end
    c(255, 190, 79); r(dx - 100, 272, 6, 6)
    c(7, 16, 27); r(dx - 22, 336, 44, WALL_BOTTOM - 336)                  -- sas, jusqu'au sol
    if open > 0 then
        c(60, 120, 130); r(dx - 18 + math.floor(18 * (1 - open)), 340, 36 - math.floor(36 * (1 - open)), WALL_BOTTOM - 340)
    end
end
local function front_argo(ui, dx, open)
    local c, r = ui.color, ui.rect
    c(50, 75, 91); r(dx - 26, 332, 52, 4); r(dx - 26, 332, 4, WALL_BOTTOM - 332); r(dx + 22, 332, 4, WALL_BOTTOM - 332)
    local half = math.floor(20 * (1 - open))
    c(32, 58, 75); r(dx - 22, 336, half, WALL_BOTTOM - 336); r(dx + 22 - half, 336, half, WALL_BOTTOM - 336)
    c(255, 161, 55); r(dx - 3, 322, 6, 5)
    c(18, 32, 48); r(dx + 26, G - 600, 2400, 600 + 18)                   -- le mur descend jusqu'au sol
    c(32, 52, 69); r(dx + 26, G - 600, 2400, 10); r(dx + 26, G - 170, 2400, 6)
    c(80, 222, 212); r(dx + 50, 280, 22, 8)
    c(10, 20, 30); r(dx - 26, WALL_BOTTOM - 4, 2400, 4)                   -- plinthe
end

local function back_coeur(ui, dx, open)
    local c, r = ui.color, ui.rect
    c(52, 72, 88); r(dx - 290, 340, 14, 80); r(dx - 230, 340, 14, 80); r(dx - 294, 330, 82, 12)  -- arches en ruine
    c(14, 26, 44); r(dx - 130, 330, 2400, WALL_BOTTOM - 330)                                      -- voute en gradins
    r(dx - 110, 290, 2400, 40); r(dx - 80, 258, 2400, 32); r(dx - 40, 232, 2400, 26)
    r(dx - 20, G - 700, 2400, 470)
    c(60, 100, 130); r(dx - 130, 330, 2400, 3); r(dx - 110, 290, 2400, 3); r(dx - 80, 258, 2400, 3)
    c(150, 205, 230); r(dx + 30, 244, 10, 4); r(dx + 10, 300, 8, 4)
    c(7, 14, 26); r(dx - 28, 340, 56, WALL_BOTTOM - 340)
    if open > 0 then
        c(110, 190, 225); r(dx - 24 + math.floor(24 * (1 - open)), 344, 48 - math.floor(48 * (1 - open)), WALL_BOTTOM - 344)
    end
end
local function front_coeur(ui, dx, open)
    local c, r = ui.color, ui.rect
    c(60, 100, 130); r(dx - 32, 336, 64, 4); r(dx - 32, 336, 4, WALL_BOTTOM - 336); r(dx + 28, 336, 4, WALL_BOTTOM - 336)
    local half = math.floor(24 * (1 - open))
    c(30, 60, 85); r(dx - 28, 340, half, WALL_BOTTOM - 340); r(dx + 28 - half, 340, half, WALL_BOTTOM - 340)
    c(150, 205, 230); r(dx - 3, 326, 6, 6)
    c(14, 26, 44); r(dx + 32, G - 700, 2400, 700 + 18)
    c(60, 100, 130); r(dx + 32, 232, 2400, 3)
    c(8, 16, 30); r(dx + 32, WALL_BOTTOM - 4, 2400, 4)
end

local function back_varga(ui, dx, open)
    local c, r = ui.color, ui.rect
    c(20, 40, 56); r(dx - 220, 380, 60, 4); r(dx - 194, 384, 4, 36)       -- panneaux solaires propres
    c(60, 130, 170); r(dx - 216, 372, 52, 8)
    c(60, 80, 95); r(dx + 70, 300, 4, 120)                                 -- parabole sur mat
    c(150, 175, 185); r(dx + 58, 296, 28, 4); r(dx + 62, 290, 20, 4); r(dx + 66, 284, 12, 4)
    c(255, 190, 79); r(dx + 72, 276, 4, 8)
    c(46, 62, 74); r(dx - 80, 380, 150, WALL_BOTTOM - 380)                 -- tente-abri en gradins
    r(dx - 68, 352, 126, 28); r(dx - 52, 328, 94, 24); r(dx - 32, 308, 54, 20)
    c(90, 112, 124); r(dx - 80, 380, 150, 2); r(dx - 68, 352, 126, 2); r(dx - 52, 328, 94, 2)
    c(6, 12, 20); r(dx - 18, 352, 36, WALL_BOTTOM - 352)                   -- entree sombre
    if open > 0 then c(150, 110, 50); r(dx - 14, 356, 28, WALL_BOTTOM - 356) end
end
local function front_varga(ui, dx, open)
    local c, r = ui.color, ui.rect
    c(70, 90, 102); r(dx - 18, 348, 36, 4)
    local flap = math.floor((WALL_BOTTOM - 352) * (1 - open))
    c(46, 62, 74); r(dx - 18, 352, 36, flap)
    r(dx + 18, 300, 1200, WALL_BOTTOM - 300)
    c(90, 112, 124); r(dx + 18, 300, 1200, 2)
    c(30, 44, 56); r(dx - 78, 394, 26, 26)                                  -- poste radio
    c(75, 220, 184); r(dx - 72, 400, 14, 4)
    c(150, 175, 185); r(dx - 66, 376, 2, 18)
end

local DRAW = {
    argo = {back_argo, front_argo}, coeur = {back_coeur, front_coeur}, varga = {back_varga, front_varga},
}

-- Porte du vaisseau, coursive et echelle (monde, vaisseau en x=0).
local function shipHatch(ui, t)
    local c, r = ui.color, ui.rect
    local open = math.max(0, math.min(1, (t - T_HATCH) / 0.5))
    c(10, 24, 34); r(HATCH_X0 - 4, HATCH_TOP - 4, HATCH_X1 - HATCH_X0 + 8, GANG_Y - HATCH_TOP + 4)
    c(25, 40, 52); r(HATCH_X0, HATCH_TOP, HATCH_X1 - HATCH_X0, GANG_Y - HATCH_TOP)
    if open > 0 then
        c(255, 179, 64); r(HATCH_X0 + 4, HATCH_TOP + 4, HATCH_X1 - HATCH_X0 - 8, math.floor((GANG_Y - HATCH_TOP - 8) * open))
        c(60, 40, 20); r(HATCH_X0 + 10, HATCH_TOP + 10, HATCH_X1 - HATCH_X0 - 20, math.floor((GANG_Y - HATCH_TOP - 20) * open))
    end
    c(122, 158, 177); r(HATCH_X1 - 2, GANG_Y, LADDER_X + 20 - HATCH_X1, 8)       -- coursive
    c(80, 110, 125); r(HATCH_X1 - 2, GANG_Y + 8, LADDER_X + 20 - HATCH_X1, 3)
    c(122, 158, 177)                                                               -- echelle
    r(LADDER_X - 12, GANG_Y, 5, FEET - GANG_Y); r(LADDER_X + 8, GANG_Y, 5, FEET - GANG_Y)
    c(95, 125, 140)
    for y = GANG_Y + 14, FEET - 4, 22 do r(LADDER_X - 9, y, 20, 4) end
end

-- ui : color, rect, panel, f16, sky(), ship(), astro(group, frame, x, feetY)
function D.draw(ui)
    if not st.active then return end
    local t = st.t
    local g = love.graphics
    ui.sky()
    local c, r = ui.color, ui.rect
    local z, u = zoomAt(t)
    local ax, ay, grp = astro(t)
    local dx = st.cfg.door
    -- camera : centre monde (cx, cy) ; le sol reste vers le bas de l'ecran
    local cx0 = dx / 2
    local follow = LADDER_X
    if t >= T_WALK and ax then follow = math.min(math.max(LADDER_X, ax), dx - 80) end
    local cx = cx0 + (follow - cx0) * u
    local groundY = 400 + 20 * u
    local cy = G - (groundY - 300) / z
    g.push()
    g.translate(320 - cx * z, 300 - cy * z)
    g.scale(z, z)
    -- sol
    c(30, 52, 70); r(-6000, G, 12000, 3000)
    c(70, 91, 105); r(-6000, G, 12000, 3)
    c(22, 40, 56); for i = -40, 80 do r(i * 44 + 8, G + 14 + (i % 3) * 10, 18, 3) end
    -- lieu : fond, cosmonaute, puis cadre et masque
    local pair = DRAW[st.site]
    local open = ax and math.max(0, math.min(1, (ax - (dx - 100)) / 70)) or 0
    pair[1](ui, dx, open)
    -- vaisseau a l'echelle 6 : de sa taille de vol (x S) ; porte, coursive et echelle
    g.push(); g.translate(0, G); g.scale(S, S); ui.ship(); g.pop()
    shipHatch(ui, t)
    if ax then
        local walking = grp == "walk_right"
        local bob = (grp == "orientation_up") and (math.floor(t * 4) % 2) * 2 or 0
        ui.astro(grp, 1 + math.floor((t - T_EXIT) * 8) % 4, math.floor(ax), math.floor(ay) + bob)
    end
    pair[2](ui, dx, open)
    g.pop()
    -- sous-titre de LUNA (ecran)
    ui.panel(22, 16, 596, 84)
    c(255, 177, 78); g.setFont(ui.f16)
    g.printf("LUNA // TRANSMISSION", 36, 22, 570, "left")
    c(206, 222, 230)
    local lines = wrapText(st.cfg.text, 34)
    local shown = math.floor(t * 40)
    for i = 1, math.min(3, #lines) do
        if shown > 0 then g.printf(lines[i]:sub(1, shown), 36, 44 + (i - 1) * 18, 570, "left") end
        shown = shown - #lines[i] - 1
    end
    c(255, 190, 98); g.printf("E / ESPACE : PASSER", 0, 446, 640, "center")
end

return D
