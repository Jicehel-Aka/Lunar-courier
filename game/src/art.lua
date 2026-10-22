-- LUNAR COURIER - illustrations : panoramas des cartes d'histoire (PNG 320x75) et portraits (PNG 48x48).
-- Pixel image = pixel de l'ecran AKA (dessin en echelle 2 dans le repere virtuel 640x480).
-- Tout est protege par pcall : si love.graphics.newImage manque ou si un fichier est absent,
-- les fonctions renvoient false et le jeu dessine son decor de secours en Lua.
-- Memoire : au plus 3 panoramas et 4 portraits decodes en meme temps (~100 Ko et ~9 Ko en RGBA).
local Art = {loaded = 0, failed = 0}
local VIEW_W = 320 -- largeur visible (pixels ecran AKA) ; les panoramas plus larges sont balayes lentement

local caches = {
    scene    = {dir = "assets/scenes/",    max = 3, map = {}, order = {}},
    portrait = {dir = "assets/portraits/", max = 4, map = {}, order = {}},
}

local function load(path)
    if not (love and love.graphics and love.graphics.newImage) then return false end
    local ok, img = pcall(love.graphics.newImage, path)
    if not ok or not img then Art.failed = Art.failed + 1; return false end
    if img.setFilter then pcall(img.setFilter, img, "nearest", "nearest") end
    Art.loaded = Art.loaded + 1
    return img
end

local function get(kind, name)
    if not name then return false end
    local c = caches[kind]
    local hit = c.map[name]
    if hit ~= nil then return hit end
    hit = load(c.dir..name..".png")
    c.map[name] = hit
    c.order[#c.order+1] = name
    if #c.order > c.max then
        local old = table.remove(c.order, 1)
        c.map[old] = nil   -- sera recharge si on y revient ; un echec aussi est oublie (on retente)
        collectgarbage("collect")
    end
    return hit
end

-- Panorama en haut de l'ecran virtuel (640 de large). t = temps ecoule sur la carte (s) :
-- balayage aller-retour doux si l'image depasse 320 px.
function Art.scene(name, t)
    local img = get("scene", name)
    if not img then return false end
    local ok = pcall(function()
        local iw = img:getWidth()
        local off = 0
        if iw > VIEW_W then off = (iw - VIEW_W) * 0.5 * (1 - math.cos((t or 0) * 0.35)) end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(img, -math.floor(off) * 2, 0, 0, 2, 2)
    end)
    return ok
end

-- Portrait 48x48 dessine a (x, y) en 96x96 virtuels.
function Art.portrait(name, x, y)
    local img = get("portrait", name)
    if not img then return false end
    local ok = pcall(function()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(img, x, y, 0, 2, 2)
    end)
    return ok
end

return Art
