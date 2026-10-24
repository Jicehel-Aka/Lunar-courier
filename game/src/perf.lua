-- Compteur de performance (menu : PERF). Mesure par ecran : images/s, temps de mise a jour et de dessin,
-- nombre de formes dessinees. Ecrit "perf.txt" (carte SD sur AKA) toutes les 10 s et a l'arret.
-- Tout est protege par pcall : sans love.timer, seules les formes et la cadence (dt) sont mesurees.
local P = {on = false, noraster = false}
local NAMES = {"rectangle", "polygon", "circle", "line", "print", "printf", "draw"}
local orig, shapes, stats, order = {}, 0, {}, {}
local tU, tD, wrote = 0, 0, 0
local last = {}

local function now()
    if love.timer and love.timer.getTime then return love.timer.getTime() end
    return nil
end

local function wrap()
    for _, n in ipairs(NAMES) do
        local f = love.graphics[n]
        if f and not orig[n] then
            orig[n] = f
            love.graphics[n] = function(...) shapes = shapes + 1; if P.noraster then return end; return f(...) end
        end
    end
end

local function unwrap()
    for n, f in pairs(orig) do love.graphics[n] = f; orig[n] = nil end
end

function P.report()
    local lines = {"etat images fps maj_ms(moy/max) dessin_ms(moy/max) formes(moy/max)"}
    for _, k in ipairs(order) do
        local s = stats[k]
        local n = math.max(1, s.n)
        lines[#lines + 1] = string.format("%s %d %.1f %.1f/%.1f %.1f/%.1f %d/%d", k, s.n, s.n / math.max(0.001, s.dt),
            s.u * 1000 / n, s.um * 1000, s.d * 1000 / n, s.dm * 1000, math.floor(s.sh / n), s.shm)
    end
    return table.concat(lines, "\n").."\n"
end

local function write()
    pcall(function()
        if love.filesystem and love.filesystem.write then love.filesystem.write("perf.txt", P.report()) end
    end)
end

function P.set(on)
    if on == P.on then return end
    P.on = on
    if on then wrap(); stats, order, wrote = {}, {}, 0
    else unwrap(); write() end
end

-- Cycle : arret -> mesure -> mesure SANS dessin reel (formes comptees mais non tracees) -> arret.
-- Le temps "dessin" du mode sans dessin = cout du script Lua seul ; la difference = cout du trace.
function P.cycle()
    if not P.on then P.noraster = false; P.set(true)
    elseif not P.noraster then P.noraster = true; stats, order = {}, {}
    else P.noraster = false; P.set(false) end
end
function P.label() return P.on and (P.noraster and "SANS TRACE" or "OUI") or "NON" end

function P.updBegin() if P.on then tU = now() end end
function P.updEnd(dt)
    if not P.on then return end
    local t = now()
    last.u = (t and tU) and (t - tU) or 0
    last.dt = dt
end

function P.drawBegin() if P.on then shapes = 0; tD = now() end end

-- key : nom de l'ecran ; font : police 16 pour l'affichage.
function P.drawEnd(key, font)
    if not P.on then return end
    local t = now()
    local d = (t and tD) and (t - tD) or 0
    local s = stats[key]
    if not s then s = {n = 0, dt = 0, u = 0, um = 0, d = 0, dm = 0, sh = 0, shm = 0}; stats[key] = s; order[#order + 1] = key end
    local u = last.u or 0
    s.n = s.n + 1; s.dt = s.dt + (last.dt or 0)
    s.u = s.u + u; if u > s.um then s.um = u end
    s.d = s.d + d; if d > s.dm then s.dm = d end
    s.sh = s.sh + shapes; if shapes > s.shm then s.shm = shapes end
    -- affichage : valeurs lissees sur la derniere seconde
    last.acc = (last.acc or 0) + (last.dt or 0); last.cnt = (last.cnt or 0) + 1
    last.sd = (last.sd or 0) + d; last.su = (last.su or 0) + u
    if last.acc >= 1 then
        last.fps = last.cnt / last.acc; last.ad = last.sd / last.cnt * 1000; last.au = last.su / last.cnt * 1000
        last.acc, last.cnt, last.sd, last.su = 0, 0, 0, 0
    end
    wrote = wrote + (last.dt or 0)
    if wrote >= 10 then wrote = 0; write() end
    local g = love.graphics
    local r, setc, setf = orig.rectangle or g.rectangle, g.setColor, g.setFont
    setc(0, 0, 0)
    r("fill", 0, 0, 330, 20)
    setc(0.6, 1, 0.6)
    if font then setf(font) end
    local txt = string.format("%s %d FPS  D%.0f U%.0f MS  F%d", key:sub(1, 8), math.floor(last.fps or 0), last.ad or 0, last.au or 0, shapes)
    local pr = orig.print or g.print
    pr(txt, 4, 2)
end

return P
