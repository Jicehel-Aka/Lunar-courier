-- LUNAR COURIER - illustrations des cartes d'histoire (PNG 320x75, pixel = 1 pixel de l'ecran AKA).
-- Tout est protege par pcall : si love.graphics.newImage manque ou si un fichier est absent,
-- Art.draw renvoie false et le jeu dessine son decor de secours en Lua.
-- Au plus MAXC images en memoire (une image decodee = ~100 Ko en RGBA).
local Art = {cache = {}, order = {}, loaded = 0, failed = 0}
local MAXC = 3
local VIEW_W = 320 -- largeur visible (pixels ecran AKA) ; les images plus larges sont balayees lentement

local function load(name)
    if not (love and love.graphics and love.graphics.newImage) then return false end
    local ok, img = pcall(love.graphics.newImage, "assets/scenes/"..name..".png")
    if not ok or not img then Art.failed = Art.failed + 1; return false end
    if img.setFilter then pcall(img.setFilter, img, "nearest", "nearest") end
    Art.loaded = Art.loaded + 1
    return img
end

function Art.get(name)
    if not name then return false end
    local c = Art.cache[name]
    if c ~= nil then return c end
    c = load(name)
    Art.cache[name] = c
    Art.order[#Art.order+1] = name
    if #Art.order > MAXC then
        local old = table.remove(Art.order, 1)
        Art.cache[old] = nil   -- sera recharge si on y revient ; false aussi est oublie : on retente
        collectgarbage("collect")
    end
    return c
end

-- Dessine l'image en haut de l'ecran virtuel 640 de large (echelle 2 = 1 pixel image par pixel ecran).
-- t = temps ecoule sur la carte (secondes) : balayage aller-retour doux si l'image depasse 320 px.
function Art.draw(name, t)
    local img = Art.get(name)
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

return Art
