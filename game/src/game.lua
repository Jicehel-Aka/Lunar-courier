-- LUNAR COURIER v0.9 - moteur de jeu (AKA-Love / LOVE 11.x, Lua 5.1)
-- Regles de compatibilite : pas d'alpha, pas de canvas, pas de polygone concave,
-- pas de love.graphics.clear, texte ASCII, 1 seul argument par isDown(),
-- audio et sauvegarde protegees par pcall (le jeu tourne meme sans).
local Data  = require("src.data")
local Audio = require("src.audio")
local Save  = require("src.save")
local Game = {}

local W, H = 640, 480

-- ---------------------------------------------------------------------------
-- Constantes de reglage (physique) - a ajuster ici apres les tests sur console
-- ---------------------------------------------------------------------------
local THRUST     = 105     -- poussee (px/s2)
local TURN       = 2.25    -- rotation (rad/s)
local SAFE_VY    = 38      -- vitesse verticale max pour se poser
local SAFE_VX    = 40      -- vitesse horizontale max pour se poser
local SAFE_ANGLE = 0.30    -- inclinaison max pour se poser (rad)
local CRASH_VY   = 75      -- au-dessus : rebond qui abime la coque
local FEET       = 12      -- distance centre -> pieds du vaisseau
local PAD_HALF   = 39      -- demi-largeur d'une zone d'atterrissage
local TOP_LIMIT  = 70      -- plafond (sous le HUD)
local COL        = 4       -- largeur des colonnes de terrain
local NCOL       = W / COL
local EMPTY      = {}

-- ---------------------------------------------------------------------------
-- Etat
-- ---------------------------------------------------------------------------
local state, time = "title", 0
local stars, particles = {}, {}
local ship = {}
local missionIndex, fuel, hull, cargo, missionTime = 1, 100, 100, 0, 0
local padIndex, padDone = 1, {}
local failed, fuelWarned, lowWarned = false, false, false
local thrustTimer = 0
local message, messageTimer = "", 0
local noteTimers = {}
local radioShown = {}
local paused = false
local windCur = 0
local fonts = {}
local tg, runs, maxG = {}, {}, 390   -- terrain : hauteur par colonne, segments, plus bas
local pads = {}
local ridge1, ridge2 = {}, {}
local cardList, cardIdx, cardDone, cardLast = nil, 1, nil, "A : CONTINUER"
local menu, menuSel = {}, 1
local skyOverride = nil
local titleAnim = 0 -- chronometre de la sequence d arrivee du vaisseau

local PAL = {
    earth = {bg={4,9,22},  band1={7,17,37},  band2={9,23,43},  r1={9,20,38},  r2={16,30,48},
             top={77,91,101}, ground={49,61,72}, speck={63,75,86}},
    far   = {bg={3,5,16},  band1={12,10,32}, band2={18,14,44}, r1={14,14,32}, r2={22,22,44},
             top={104,110,132}, ground={58,62,82}, speck={74,78,100}},
    peak  = {bg={6,14,30}, band1={10,26,50}, band2={14,34,62}, r1={12,30,54}, r2={20,42,70},
             top={150,172,192}, ground={72,88,106}, speck={96,112,130}},
}

local function mission() return Data.missions[missionIndex] end
local function pal() return PAL[skyOverride or mission().sky] or PAL.earth end
local function chapterOf(i)
    if i >= Data.chapterStart[3] then return 3 elseif i >= Data.chapterStart[2] then return 2 end
    return 1
end

local function color(r,g,b) love.graphics.setColor(r/255,g/255,b/255) end
local function colorT(t) love.graphics.setColor(t[1]/255,t[2]/255,t[3]/255) end
local function rect(x,y,w,h) love.graphics.rectangle("fill",x,y,w,h) end
local function clamp(v,a,b) if v<a then return a elseif v>b then return b end return v end

-- ---------------------------------------------------------------------------
-- Texte : modele de largeur prudent (1 caractere = taille de police en px),
-- identique sur PC et AKA ; les lignes sont ensuite centrees via printf.
-- ---------------------------------------------------------------------------
local function mkfont(n) return {obj=love.graphics.newFont(n), size=n} end

local function wrap(text, maxW, size)
    local maxChars = math.max(1, math.floor(maxW / size))
    local lines = {}
    for para in (text.."\n"):gmatch("(.-)\n") do
        if para == "" then
            lines[#lines+1] = ""
        else
            local cur = ""
            for word in para:gmatch("%S+") do
                if cur == "" then cur = word
                elseif #cur + 1 + #word <= maxChars then cur = cur.." "..word
                else lines[#lines+1] = cur; cur = word end
            end
            lines[#lines+1] = cur
        end
    end
    return lines
end

local function fit(text, maxW, list)
    for _,f in ipairs(list) do
        if #text * f.size <= maxW then return f end
    end
    return list[#list]
end

local function centered(text, y, font, c, x0, w)
    love.graphics.setFont(font.obj); color(c[1],c[2],c[3])
    love.graphics.printf(text, x0 or 0, y, w or W, "center")
end

local function drawLines(lines, x0, y, w, font, c, lh)
    lh = lh or (font.size + 6)
    love.graphics.setFont(font.obj)
    for i,l in ipairs(lines) do
        if l ~= "" then
            if type(c[1]) == "table" then colorT(c[(i-1) % #c + 1]) else color(c[1],c[2],c[3]) end
            love.graphics.printf(l, x0, y + (i-1)*lh, w, "center")
        end
    end
end

local function panel(x,y,w,h)
    color(4,11,25); rect(x,y,w,h)
    color(9,23,40); rect(x+2,y+2,w-4,math.min(18,h-4))
    color(43,205,211)
    if love.graphics.setLineWidth then love.graphics.setLineWidth(1) end
    love.graphics.rectangle("line",x,y,w,h)
    -- Coins lumineux : une signature visuelle commune aux menus, cartes et HUD.
    color(255,190,79)
    rect(x+1,y+1,10,2); rect(x+1,y+1,2,8)
    color(48,197,207)
    rect(x+w-9,y+1,8,2); rect(x+w-2,y+1,2,8)
    rect(x+1,y+h-2,8,1); rect(x+w-8,y+h-2,7,1)
end

-- ---------------------------------------------------------------------------
-- Messages
-- ---------------------------------------------------------------------------
local function setMessage(text, duration) message, messageTimer = text, duration or 3 end
local function note(key, text, dur, cd)
    if (noteTimers[key] or 0) <= 0 then
        setMessage(text, dur)
        noteTimers[key] = cd or 4
        return true
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Terrain
-- ---------------------------------------------------------------------------
local function groundAt(x)
    local i = math.floor(x / COL)
    if i < 0 then i = 0 elseif i > NCOL-1 then i = NCOL-1 end
    return tg[i]
end

local function buildTerrain(pts)
    maxG = 0
    for i = 0, NCOL-1 do
        local x = i*COL + COL/2
        local y = pts[#pts][2]
        for k = 1, #pts-1 do
            local a, b = pts[k], pts[k+1]
            if x >= a[1] and x <= b[1] then
                local t = 0
                if b[1] ~= a[1] then t = (x - a[1]) / (b[1] - a[1]) end
                y = a[2] + (b[2]-a[2]) * t
                break
            end
        end
        tg[i] = math.floor(y + 0.5)
        if tg[i] > maxG then maxG = tg[i] end
    end
    runs = {}
    local s = 0
    for i = 1, NCOL do
        if i == NCOL or tg[i] ~= tg[s] then
            runs[#runs+1] = {x=s*COL, w=(i-s)*COL, y=tg[s]}
            s = i
        end
    end
end

-- ---------------------------------------------------------------------------
-- Mission
-- ---------------------------------------------------------------------------
local function resetMission()
    local m = mission()
    buildTerrain(m.terrain)
    pads = {}
    for i,p in ipairs(m.pads) do pads[i] = {x=p.x, y=groundAt(p.x)} end
    padIndex, padDone = 1, {}
    ship = {x=80, y=175, vx=0, vy=0, angle=0, thrust=false, landed=false, resting=false, hitCooldown=0}
    fuel, hull, cargo, missionTime = 100, 100, 0, 0
    failed, fuelWarned, lowWarned, paused = false, false, false, false
    particles, noteTimers, windCur, radioShown = {}, {}, 0, {}
    message, messageTimer = "", 0
    thrustTimer = 0
    Audio.thrust(false)
end

local function startMission(i)
    skyOverride = nil
    missionIndex = i
    resetMission()
    state = "game"
end

local function buildMenu()
    menu = {}
    if Save.next > 1 and Save.next <= #Data.missions then
        menu[#menu+1] = {label="CONTINUER  M"..string.format("%02d", Save.next), act="continue"}
    end
    menu[#menu+1] = {label="NOUVELLE PARTIE", act="new"}
    for ch = 2, 3 do
        local start = Data.chapterStart[ch]
        if Save.unlockAll or Save.best >= start then
            menu[#menu+1] = {label="CHAPITRE "..ch, act="chapter", mission=start}
        end
    end
    menuSel = clamp(menuSel, 1, #menu)
end

function Game.load()
    titleAnim = 0
    if os and os.time then math.randomseed(os.time())
    elseif love.timer and love.timer.getTime then math.randomseed(math.floor(love.timer.getTime()*100000))
    else math.randomseed(12345) end
    fonts.f16, fonts.f24, fonts.f32, fonts.f48 = mkfont(16), mkfont(24), mkfont(32), mkfont(48)
    for i = 1, 40 do
        stars[#stars+1] = {x=math.random(0,W), y=math.random(0,330), s=math.random(2,3), phase=math.random()*6.28}
    end
    for i = 0, 31 do
        ridge1[i] = math.floor(292 + 30*math.sin(i*0.9) + 18*math.sin(i*2.6+1))
        ridge2[i] = math.floor(350 + 14*math.sin(i*1.4) + 8*math.sin(i*4.2))
    end
    Save.load()
    Audio.musicOn = (Save.music ~= 0)
    Audio.load()
    resetMission()
    buildMenu()
end

-- ---------------------------------------------------------------------------
-- Particules
-- ---------------------------------------------------------------------------
local function addParticles(x,y,count,kind)
    for i = 1, count do
        local a = math.random()*math.pi*2
        local speed = math.random(15,85)
        particles[#particles+1] = {
            x=x, y=y, vx=math.cos(a)*speed, vy=math.sin(a)*speed-math.random(0,25),
            life=0.35+math.random()*0.55, size=math.random(2,3), kind=kind or "dust"}
    end
end

-- ---------------------------------------------------------------------------
-- Obstacles
-- ---------------------------------------------------------------------------
local function debrisPos(d)
    local s = math.sin(missionTime*d.speed + (d.phase or 0))
    if d.axis == "y" then return d.x, d.y + d.amp*s end
    return d.x + d.amp*s, d.y
end

local function beamState(b)
    local u = (missionTime + b.phase) % b.period
    if u < b.on then return "on" end
    if u >= b.period - b.warn then return "warn" end
    return "off"
end

local function failMission(text)
    failed = true
    ship.thrust = false
    setMessage(text, 99)
    Audio.thrust(false)
    Audio.play("fail")
end

local function hit(dx, text)
    ship.hitCooldown = 1.2
    ship.vx = ship.vx + (dx >= 0 and 45 or -45)
    ship.vy = -math.abs(ship.vy)*0.45 - 22
    hull = math.max(0, hull - 20)
    addParticles(ship.x, ship.y, 12, "spark")
    Audio.play("hit")
    if hull <= 0 then failMission("COQUE BRISEE - D : RECOMMENCER")
    else setMessage(text, 2.2) end
end

local function activatePad()
    padDone[padIndex] = true
    if padIndex >= #pads then
        ship.landed = true
        addParticles(ship.x, ship.y + FEET, 22, "dust")
        setMessage("ATTERRISSAGE CONFIRME - A : CONTINUER", 99)
        Audio.thrust(false)
        Audio.play("land")
    else
        padIndex = padIndex + 1
        fuel = math.min(100, fuel + 25)
        addParticles(ship.x, ship.y + FEET, 14, "pickup")
        setMessage("BALISE "..(padIndex-1).."/"..#pads.." ACTIVEE  +25% CARBURANT", 3)
        Audio.play("pad")
    end
end

-- ---------------------------------------------------------------------------
-- Mise a jour
-- ---------------------------------------------------------------------------
local function down(k) return love.keyboard.isDown(k) end

local function syncMusic()
    if state == "game" or state == "debrief" then Audio.setMusic("mus_ch"..chapterOf(missionIndex))
    else Audio.setMusic("mus_story") end
end

function Game.update(dt)
    dt = math.min(dt, 1/30)
    time = time + dt
    if state == "title" then titleAnim = math.min(titleAnim + dt, 4.2) end
    syncMusic()
    if messageTimer > 0 then messageTimer = math.max(0, messageTimer - dt) end
    for k,v in pairs(noteTimers) do noteTimers[k] = v - dt end
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx*dt; p.y = p.y + p.vy*dt
        p.vx = p.vx*0.98; p.vy = p.vy + 16*dt
        p.life = p.life - dt
        if p.life <= 0 then table.remove(particles, i) end
    end
    if state ~= "game" or paused or ship.landed or failed then Audio.thrust(false); return end

    local m = mission()
    missionTime = missionTime + dt

    -- Repliques radio en vol
    for i,r in ipairs(m.radio or EMPTY) do
        if not radioShown[i] and missionTime >= r.t then
            radioShown[i] = true
            setMessage(r.text, 4.5)
        end
    end

    -- Commandes (un seul argument par appel : compatible runtime AKA)
    if down("left") or down("q") or down("a") then ship.angle = ship.angle - TURN*dt end
    if down("right") or down("d") then ship.angle = ship.angle + TURN*dt end
    local thrusting = (down("up") or down("z") or down("w")) and fuel > 0
    ship.thrust = thrusting
    if thrusting then thrustTimer = 0.15 else thrustTimer = math.max(0, thrustTimer - dt) end
    Audio.thrust(thrustTimer > 0)
    if thrusting then
        ship.vx = ship.vx + math.sin(ship.angle)*THRUST*dt
        ship.vy = ship.vy - math.cos(ship.angle)*THRUST*dt
        fuel = math.max(0, fuel - m.fuelUse*dt)
        ship.resting = false
        if math.random() < 0.85 then
            addParticles(ship.x - math.sin(ship.angle)*17, ship.y + math.cos(ship.angle)*17, 1, "flame")
        end
    end
    if fuel < 25 and not lowWarned then lowWarned = true; Audio.play("warn") end
    if fuel <= 0 and not fuelWarned then
        fuelWarned = true
        setMessage("CARBURANT EPUISE - D : RECOMMENCER", 99)
    end

    -- Vent (rafales) : ne pousse pas un vaisseau pose
    if m.wind ~= 0 then windCur = m.wind * (0.55 + 0.45*math.sin(missionTime*0.8)) else windCur = 0 end
    if not ship.resting then ship.vx = ship.vx + windCur*dt end

    ship.vy = ship.vy + m.gravity*dt
    ship.vx = ship.vx * (1 - 0.035*dt)
    ship.vy = ship.vy * (1 - 0.012*dt)
    ship.x = ship.x + ship.vx*dt
    ship.y = ship.y + ship.vy*dt

    if ship.x < 16 then ship.x = 16; ship.vx = math.abs(ship.vx)*0.35 end
    if ship.x > W-16 then ship.x = W-16; ship.vx = -math.abs(ship.vx)*0.35 end
    if ship.y < TOP_LIMIT then ship.y = TOP_LIMIT; ship.vy = math.abs(ship.vy)*0.25 end

    -- Capsule energetique
    if m.cell and cargo == 0 and math.abs(ship.x - m.cell.x) < 24 and math.abs(ship.y - m.cell.y) < 26 then
        cargo = 1
        fuel = math.min(100, fuel + 22)
        addParticles(m.cell.x, m.cell.y, 18, "pickup")
        setMessage("MODULE RECUPERE  +22% CARBURANT", 3)
        Audio.play("pickup")
    end

    -- Obstacles
    ship.hitCooldown = math.max(0, ship.hitCooldown - dt)
    if ship.hitCooldown <= 0 and not failed then
        for _,r in ipairs(m.rocks or EMPTY) do
            local ry = groundAt(r.x) - 9
            if math.abs(ship.x - r.x) < 20 and math.abs(ship.y - ry) < 22 then
                hit(ship.x - r.x, "DEBRIS ! COQUE -20%"); break
            end
        end
    end
    if ship.hitCooldown <= 0 and not failed then
        for _,d in ipairs(m.debris or EMPTY) do
            local dx0, dy0 = debrisPos(d)
            local rad = d.soft and 18 or 24
            if math.abs(ship.x - dx0) < rad and math.abs(ship.y - dy0) < rad then
                if d.soft then
                    ship.hitCooldown = 0.5
                    ship.vx = ship.vx + ((ship.x - dx0) >= 0 and 25 or -25)
                    note("drone", "LUCIOLE ! DOUCEMENT", 1.5, 2)
                else
                    hit(ship.x - dx0, "EPAVE ! COQUE -20%")
                end
                break
            end
        end
    end
    if ship.hitCooldown <= 0 and not failed then
        for _,b in ipairs(m.beams or EMPTY) do
            if beamState(b) == "on" and math.abs(ship.x - b.x) < 17 then
                hit(ship.x - b.x, "RAYON SOLAIRE ! COQUE -20%"); break
            end
        end
    end
    if failed then return end

    -- Contact avec le sol
    local gy = math.min(groundAt(ship.x - 9), groundAt(ship.x), groundAt(ship.x + 9))
    ship.resting = false
    if ship.y + FEET >= gy then
        local impact = ship.vy
        ship.y = gy - FEET
        local live = pads[padIndex]
        local onLive = live ~= nil and math.abs(ship.x - live.x) < PAD_HALF and gy == live.y
        local safe = math.abs(ship.vy) < SAFE_VY and math.abs(ship.vx) < SAFE_VX and math.abs(ship.angle) < SAFE_ANGLE
        if onLive and safe then
            ship.vx, ship.vy = 0, 0
            ship.resting = true
            if (not m.cell) or cargo == 1 then
                activatePad()
            else
                note("nocargo", "MODULE MANQUANT : PRENEZ LA CAPSULE", 2.5, 4)
            end
        elseif math.abs(ship.vy) < 60 and math.abs(ship.angle) < 0.5 then
            ship.vy = 0
            ship.vx = ship.vx * 0.8
            ship.resting = true
            if math.abs(impact) > 12 then
                if onLive then note("rough", "TROP RAPIDE OU PENCHE", 2.2, 3)
                else note("off", "HORS ZONE - VISEZ LA BALISE CYAN", 2.5, 4) end
            elseif onLive and math.abs(ship.angle) >= SAFE_ANGLE then
                note("tilt", "REDRESSEZ LE VAISSEAU", 2, 5)
            end
        else
            if math.abs(impact) > CRASH_VY then
                hull = math.max(0, hull - 12)
                if hull <= 0 then failMission("COQUE BRISEE - D : RECOMMENCER") end
            end
            ship.vy = -math.min(math.abs(ship.vy)*0.38 + 10, 65)
            ship.vx = ship.vx * 0.62
            ship.angle = ship.angle * 0.72
            addParticles(ship.x, ship.y + FEET, 7, "dust")
            if not failed and note("bounce", "REBOND ! RALENTISSEZ", 2, 3) then
                Audio.play("bounce")
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Dessin : decor
-- ---------------------------------------------------------------------------
local function drawSky()
    local p = pal()
    local sky = skyOverride or mission().sky
    colorT(p.bg); rect(0,0,W,H)
    colorT(p.band1); rect(0,48,W,62)
    colorT(p.band2); rect(0,96,W,52)
    if sky == "earth" then
        color(18,48,85);   love.graphics.circle("fill",520,93,46)
        color(37,103,157); love.graphics.circle("fill",520,93,40)
        color(31,119,126)
        love.graphics.circle("fill",505,80,10); love.graphics.circle("fill",513,87,7)
        love.graphics.circle("fill",536,104,9); love.graphics.circle("fill",528,111,6)
        color(91,190,190); rect(494,54,18,2)
    elseif sky == "peak" then
        -- Pole : Terre basse sur l'horizon et soleil qui ne se couche jamais
        color(18,48,85);   love.graphics.circle("fill",560,128,24)
        color(37,103,157); love.graphics.circle("fill",560,128,20)
        color(31,119,126); love.graphics.circle("fill",554,122,6)
        color(255,236,170); love.graphics.circle("fill",96,230,18)
        color(255,248,214); love.graphics.circle("fill",96,230,10)
    else
        for i = 0, 27 do
            colorT(i % 3 == 0 and {24,20,58} or {17,14,44})
            rect(i*24, 150 - i*4 + (i%2)*3, 52, 20)
        end
    end
    -- Etoiles lointaines fixes, plus fines que les etoiles animees au premier plan.
    for i = 0, 28 do
        local sx = (i*137 + 19) % W
        local sy = (i*71 + 13) % 278
        if i % 4 == 0 then color(73,133,166) else color(39,77,111) end
        rect(sx, sy, (i%5==0) and 3 or 2, 2)
        if i % 7 == 0 then
            color(105,197,210); rect(sx-2, sy+1, 7, 1); rect(sx+1, sy-2, 1, 7)
        end
    end
    for _,st in ipairs(stars) do
        local pulse = math.floor((time*2 + st.phase)*2) % 5
        if pulse == 0 then color(92,157,190) elseif pulse == 1 then color(140,203,222) else color(193,222,235) end
        rect(st.x, st.y, st.s, st.s)
    end
end

local function drawRidges()
    local p = pal()
    colorT(p.r1)
    for i = 0, 31 do rect(i*20, ridge1[i], 20, H - ridge1[i]) end
    colorT(p.r2)
    for i = 0, 31 do rect(i*20, ridge2[i], 20, H - ridge2[i]) end
    -- Quelques facettes anguleuses donnent du relief sans texture couteuse.
    for i = 0, 15 do
        local x = i*41 + 7
        local y = ridge2[(i*2)%32] + 10 + (i%3)*7
        color(i%2==0 and {26,43,62} or {30,45,64})
        if y < H-12 then
            love.graphics.polygon("fill",x,y,x+13,y-8,x+27,y,x+20,y+5)
            color(47,64,81); rect(x+8,y-3,8,2)
        end
    end
end

local function drawStation(cx, base, big)
    local w = big and 120 or 84
    local n = big and 7 or 5
    local dist = math.abs(ship.x - cx) + math.abs(ship.y - base) * 0.5
    local lit = clamp(math.floor((1 - clamp(dist/450, 0, 1)) * n) + 1, 0, n)
    color(20,32,46); rect(cx - w/2, base - 28, w, 28)
    color(30,46,64); rect(cx - 16, base - 74, 32, 48); rect(cx - 24, base - 80, 48, 8)
    color(44,64,84); rect(cx - 1, base - 100, 2, 20); rect(cx - 6, base - 102, 12, 2)
    for i = 0, n - 1 do
        local wx = cx - w/2 + 8 + i * ((w - 24) / math.max(1, n-1))
        if i < lit then color(61,241,225) else color(18,40,52) end
        rect(wx, base - 20, 8, 8)
    end
    if lit >= n then color(255,190,79); rect(cx - 4, base - 66, 8, 6) end
end

local function drawMast(cx, base)
    color(28,40,56); rect(cx - 5, base - 150, 10, 150)
    color(44,64,84)
    rect(cx - 22, base - 120, 44, 4); rect(cx - 16, base - 90, 32, 4); rect(cx - 10, base - 60, 20, 4)
    color(60,84,104); rect(cx - 1, base - 170, 2, 20)
    local lit = ship.landed
    if lit then
        color(255,250,220); rect(cx - 2, 0, 4, base - 158)
        color(255,255,255)
    elseif math.floor(time*2) % 2 == 0 then color(255,90,80) else color(90,30,30) end
    rect(cx - 4, base - 158, 8, 8)
end

local function drawTerrain()
    local p = pal()
    colorT(p.ground); rect(0, maxG, W, H - maxG)
    for _,r in ipairs(runs) do
        if r.y < maxG then colorT(p.ground); rect(r.x, r.y + 2, r.w, maxG - r.y) end
        colorT(p.top); rect(r.x, r.y, r.w, 2)
    end
    -- Strates sombres et petites inclusions minerales, deterministes pour rester legers.
    for i = 1, 24 do
        local x = (i*53 + 17) % W
        local gy = groundAt(x)
        local y = gy + 10 + (i*19)%54
        if y < H-3 then
            color(i%3==0 and {27,39,51} or {39,51,63})
            rect(x,y,5+(i%4)*3,2)
            colorT(p.speck); rect(x+2,y+3,2,1)
        end
    end
    -- Crateres stylises sur les zones visibles du sol.
    for i = 1, 8 do
        local x = (i*79 + 31) % W
        local gy = groundAt(x)
        if gy < H-12 then
            color(30,42,54); rect(x-7,gy+4,15,3)
            color(68,82,94); rect(x-5,gy+4,9,1)
        end
    end
    colorT(p.speck)
    for i = 1, 16 do
        local x = (i*59) % W
        local y = maxG + 8 + (i*29) % 60
        if y < H then rect(x, y, 2 + (i%4), 1 + (i%2)) end
    end
end

local function padStatus(i)
    if padDone[i] then return 2 end
    if i == padIndex then return 1 end
    return 0
end

local function drawBeacon(x, y, st)
    color(10,20,31); rect(x-15, y-5, 30, 5)
    color(67,86,99); rect(x-7, y-28, 14, 24)
    color(119,147,157); rect(x-4, y-26, 3, 20)
    color(22,44,56); rect(x-10, y-31, 20, 7)
    color(32,119,130); rect(x-7, y-33, 14, 3)
    color(28,91,104); rect(x-5, y-39, 10, 8)
    if st == 2 then color(80,240,150)
    elseif st == 1 then
        if math.floor(time*3) % 2 == 0 then color(61,241,225) else color(39,172,190) end
    else color(45,85,95) end
    rect(x-3, y-37, 6, 4)
    color(255,190,79); rect(x-2, y-29, 4, 2)
end

local function drawPads()
    local m = mission()
    for i,p in ipairs(pads) do
        local st = padStatus(i)
        local x0 = p.x - PAD_HALF
        local plate, light
        if st == 2 then plate = {22,100,80}; light = {80,240,150}
        elseif st == 1 then plate = {16,57,70}; light = {53,215,211}
        else plate = {24,38,48}; light = {44,92,104} end
        colorT(plate); rect(x0, p.y, 2*PAD_HALF, 4)
        colorT(light); rect(x0 + 4, p.y, 2*PAD_HALF - 8, 2)
        rect(x0, p.y - 8, 3, 10); rect(x0 + 2*PAD_HALF - 3, p.y - 8, 3, 10)
        for j = -2, 2 do rect(p.x + j*13 - 3, p.y + 2, 6, 1) end
        drawBeacon(p.x + PAD_HALF + 14, p.y, st)
        if st == 1 and ((not m.cell) or cargo == 1) and math.floor(time*3) % 2 == 0 then
            color(255,190,79)
            love.graphics.polygon("fill", p.x-9, p.y-64, p.x+9, p.y-64, p.x, p.y-50)
        end
    end
end

local function drawCell(x, y)
    y = y + math.floor(math.sin(time*3)*2)
    color(104,64,27);   rect(x-10, y-13, 20, 26)
    color(245,163,52);  rect(x-8, y-12, 16, 24)
    color(255,211,103); rect(x-5, y-10, 3, 5)
    color(29,44,58);    rect(x-5, y-3, 10, 11)
    color(35,222,211);  rect(x-2, y-1, 4, 7)
    color(255,230,164); rect(x-3, y-15, 6, 3)
    color(124,86,45);   rect(x-6, y+10, 12, 2)
end

local function drawRock(x, y)
    color(17,25,36);    love.graphics.polygon("fill", x-15,y+7, x-13,y-3, x-7,y-11, x+2,y-13, x+11,y-6, x+15,y+5, x+7,y+10, x-5,y+11)
    color(62,76,89);    love.graphics.polygon("fill", x-12,y-2, x-6,y-9, x+2,y-10, x-4,y-1)
    color(95,111,122);  love.graphics.line(x-8,y-5, x-3,y-8, x+1,y-5)
    color(38,50,63);    love.graphics.line(x+4,y-2, x+9,y+2, x+7,y+6)
end

local function drawDebris(d)
    local x, y = debrisPos(d)
    if d.kind == "drone" then
        color(30,60,80);    rect(x-9, y-4, 18, 8)
        color(120,235,225); rect(x-7, y-2, 14, 4)
        if math.floor(time*4 + (d.phase or 0)*3) % 2 == 0 then color(255,230,150) else color(255,150,60) end
        rect(x-1, y-8, 2, 4)
        color(80,130,150);  rect(x-14, y-1, 5, 2); rect(x+9, y-1, 5, 2)
        return
    end
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(missionTime * (d.spin or 1))
    drawRock(0, 0)
    love.graphics.pop()
end

local function drawBeams()
    for _,b in ipairs(mission().beams or EMPTY) do
        local gy = groundAt(b.x)
        local st = beamState(b)
        color(90,62,24); rect(b.x - 10, 0, 20, 6)
        if st == "on" then
            color(255,214,110); rect(b.x - 9, 6, 18, gy - 6)
            color(255,250,220); rect(b.x - 3, 6, 6, gy - 6)
        elseif st == "warn" and math.floor(time*8) % 2 == 0 then
            color(255,150,60); rect(b.x - 1, 6, 2, gy - 6)
        end
    end
end

local function drawWindStreaks()
    if math.abs(windCur) < 1 then return end
    local dir = windCur > 0 and 1 or -1
    local spd = 30 + math.abs(windCur) * 5
    color(70,100,125)
    for i = 1, 10 do
        local x = (i*83 + time*dir*(spd + (i%4)*14)) % W
        local y = 80 + (i*47) % 280
        rect(x, y, 12, 1)
    end
end

local function drawShip()
    love.graphics.push()
    love.graphics.translate(ship.x, ship.y); love.graphics.rotate(ship.angle); love.graphics.scale(0.78, 0.78)
    if ship.thrust and not ship.landed then
        color(255,133,42);  love.graphics.polygon("fill", -7,12, -4,23, 0,34, 4,23, 7,12)
        color(255,210,91);  love.graphics.polygon("fill", -4,12, -2,22, 0,28, 2,22, 4,12)
        color(48,225,230);  love.graphics.polygon("fill", -2,12, 0,22, 2,12)
    end
    color(57,83,100);   love.graphics.polygon("fill", -8,5, -17,14, -12,16, -4,10)
    love.graphics.polygon("fill", 8,5, 17,14, 12,16, 4,10)
    color(122,158,177); love.graphics.line(-8,7,-14,16); love.graphics.line(8,7,14,16)
    color(91,119,139);  love.graphics.polygon("fill", 0,-17, -9,-8, -13,7, -6,14, 6,14, 13,7, 9,-8)
    color(199,216,225); love.graphics.polygon("fill", 0,-18, -6,-7, -9,6, -4,11, 4,11, 9,6, 6,-7)
    color(237,244,244); love.graphics.polygon("fill", 0,-17, -3,-6, -3,7, 0,10, 3,7, 3,-6)
    color(19,56,76);    love.graphics.polygon("fill", -5,-7, -2,-12, 3,-12, 6,-7, 4,-1, -4,-1)
    color(44,222,226);  love.graphics.polygon("fill", -3,-7, -1,-10, 2,-10, 4,-7, 3,-3, -3,-3)
    color(255,179,64);  rect(-2,3,4,5)
    color(255,219,129); rect(-1,4,1,2)
    color(79,111,129);  love.graphics.line(-5,12,5,12)
    love.graphics.pop()
end

local function drawParticles()
    for _,p in ipairs(particles) do
        if p.kind == "flame" then color(255,151,61)
        elseif p.kind == "spark" then color(255,194,78)
        elseif p.kind == "pickup" then color(63,239,221)
        else color(153,190,201) end
        rect(p.x, p.y, p.size, p.size)
    end
end

-- ---------------------------------------------------------------------------
-- HUD (largeur de texte prudente : 16 px par caractere)
-- ---------------------------------------------------------------------------
local function drawHUD()
    local m = mission()
    panel(10, 8, 316, 58)
    love.graphics.setFont(fonts.f16.obj)
    color(145,229,231); love.graphics.print(string.format("M%02d", missionIndex), 18, 14)
    color(201,215,225); love.graphics.print("F", 76, 14)
    color(28,45,60); rect(96, 18, 96, 8)
    if fuel < 25 then color(255,87,72) else color(36,213,193) end
    rect(96, 18, 96 * fuel/100, 8)
    color(201,215,225); love.graphics.print("H", 204, 14)
    color(28,45,60); rect(224, 18, 84, 8)
    if hull < 35 then color(255,87,72) else color(120,200,120) end
    rect(224, 18, 84 * hull/100, 8)

    local spd = math.floor(math.sqrt(ship.vx^2 + ship.vy^2))
    if math.abs(ship.vx) >= SAFE_VX or math.abs(ship.vy) >= SAFE_VY then color(255,188,73) else color(120,235,225) end
    if m.blackout and math.floor(time*4) % 2 == 0 then
        love.graphics.print("V---", 18, 38)
    else
        love.graphics.print(string.format("V%03d", spd), 18, 38)
    end
    if m.cell then
        if cargo == 1 then color(245,163,52); rect(100, 39, 10, 14)
        else
            color(245,163,52)
            if love.graphics.setLineWidth then love.graphics.setLineWidth(1) end
            love.graphics.rectangle("line", 100, 39, 10, 14)
        end
    end
    color(201,215,225)
    local done = 0
    for i = 1, #pads do if padDone[i] then done = done + 1 end end
    love.graphics.print("B"..done.."/"..#pads, 124, 38)
    if math.abs(windCur) >= 1 then
        local n = clamp(math.ceil(math.abs(windCur)/6), 1, 3)
        color(255,188,73)
        love.graphics.print("W", 204, 38)
        for k = 0, n-1 do
            local x = 228 + k*16
            if windCur > 0 then love.graphics.polygon("fill", x,41, x,51, x+8,46)
            else love.graphics.polygon("fill", x+8,41, x+8,51, x,46) end
        end
    end
end

local function drawMessage()
    if messageTimer <= 0 or message == "" then return end
    local lines = wrap(message, 520, 16)
    local h = #lines * 20 + 16
    local y = H - 18 - h
    panel(42, y, 556, h)
    drawLines(lines, 52, y + 8, 536, fonts.f16, {202,222,231}, 20)
end

local function drawBanner()
    if missionTime >= 3.5 or paused then return end
    local m = mission()
    panel(60, 76, 520, 70)
    local f = fit(m.name, 490, {fonts.f24, fonts.f16})
    centered(m.name, 86, f, {255,190,83}, 60, 520)
    centered("OBJ: "..m.objective, 118, fonts.f16, {194,211,224}, 60, 520)
end

-- ---------------------------------------------------------------------------
-- Ecrans
-- ---------------------------------------------------------------------------
local function drawTitle()
    -- La surface logique fait 640x480, affichee en 320x240 sur l AKA :
    -- les contours importants font donc au moins 2 px logiques (= 1 px physiques).
    local t = titleAnim
    local function easeOut(u)
        u = clamp(u, 0, 1)
        return 1 - (1-u)*(1-u)*(1-u)
    end
    local land = easeOut(t / 2.55)
    local shipY = -32 + (226 + 32) * land
    local flameOn = t < 2.48
    local titleProgress = easeOut((t - 1.85) / 1.12)
    local titleY = -62 + 168 * titleProgress

    -- En-tete : le titre reste cache en haut puis descend apres l arrivee du vaisseau.
    color(32,196,207); rect(W/2-118, 31, 236, 2)
    color(255,190,79); rect(W/2-42, 35, 84, 2)
    centered("UNE AVENTURE LUNAIRE", 44, fonts.f24, {90,224,227})
    centered("LUNAR COURIER", titleY, fonts.f48, {235,244,248})

    -- Halo orbital compact, garde derriere le vaisseau pour ne pas brouiller le titre.
    color(7,20,36)
    love.graphics.circle("fill", W/2, 235, 57)
    color(16,48,68)
    love.graphics.circle("line", W/2, 235, 53)
    color(29,89,109)
    love.graphics.circle("line", W/2, 235, 44)
    color(45,118,132)
    love.graphics.circle("line", W/2, 235, 34)

    -- Plateforme d arrivee : silhouettes epaisses pour survivre a la reduction 2:1.
    color(24,47,62); rect(W/2-77, 260, 154, 7)
    color(48,197,207); rect(W/2-65, 259, 130, 2)
    color(255,190,79); rect(W/2-17, 257, 34, 3)
    color(32,78,96); rect(W/2-92, 267, 184, 2)
    color(50,114,131); rect(W/2-52, 270, 104, 2)

    -- Faisceaux de guidage et balises laterales.
    color(29,72,91); rect(W/2-125, 242, 38, 3)
    color(52,151,166); rect(W/2-113, 224, 3, 18)
    color(255,190,79); rect(W/2-117, 219, 11, 5)
    color(29,72,91); rect(W/2+87, 242, 38, 3)
    color(52,151,166); rect(W/2+109, 224, 3, 18)
    color(58,220,216); rect(W/2+106, 219, 11, 5)

    -- Le moteur s anime pendant la descente, puis s eteint juste avant le contact.
    love.graphics.push()
    love.graphics.translate(W/2, shipY)
    love.graphics.scale(1.85, 1.85)
    local save = {x=ship.x, y=ship.y, angle=ship.angle, thrust=ship.thrust, landed=ship.landed}
    ship.x, ship.y, ship.angle, ship.thrust, ship.landed = 0, 0, 0, flameOn, false
    drawShip()
    ship.x, ship.y, ship.angle, ship.thrust, ship.landed = save.x, save.y, save.angle, save.thrust, save.landed
    love.graphics.pop()

    -- Petites poussieres au contact : pulse bref, sans surcharge visuelle.
    if t >= 2.42 and t < 2.92 then
        local pulse = math.floor(t * 22) % 2
        color(pulse == 0 and 255 or 120, pulse == 0 and 190 or 220, pulse == 0 and 105 or 220)
        rect(W/2-39, 263, 9, 2); rect(W/2+30, 263, 9, 2)
        color(114,157,174)
        rect(W/2-48, 256, 4, 2); rect(W/2+44, 256, 4, 2)
    end

    -- Sous-titre discret mais lisible sur l ecran physique.
    if t >= 2.65 then
        centered("LIVREZ LA DERNIERE LUMIERE", 164, fonts.f16, {255,198,111})
    end

    -- Menu en zone basse, avec separation suffisamment epaisse a l echelle AKA.
    color(39,88,110); rect(92, 286, 456, 2)
    local y = 306
    for i,it in ipairs(menu) do
        if i == menuSel then
            color(255,190,79); rect(170, y+10, 18, 2); rect(452, y+10, 18, 2)
            centered("> "..it.label.." <", y, fonts.f24, {255,190,83})
        else centered(it.label, y, fonts.f24, {82,229,218}) end
        y = y + 34
    end
    centered("HAUT/BAS + A    B : MUSIQUE "..(Audio.musicOn and "OUI" or "NON"), 448, fonts.f16, {158,184,202})
end

local function drawInstructions()
    panel(38, 30, 564, 420)
    centered("COMMANDES", 44, fonts.f32, {235,244,248})
    local amber, white = {255,188,83}, {198,216,227}
    local rows = {
        {"GAUCHE / DROITE : tourner", white},
        {"HAUT : propulseur  (PC: Z W Q D)", white},
        {"A : valider    C : pause", white},
        {"D : recommencer    MENU : titre", white},
        {"B : musique oui / non", white},
        {"MISSION", amber},
        {"1. Prenez la capsule orange", white},
        {"2. Posez-vous sur la balise cyan", white},
        {"   doucement, vaisseau droit", white},
        {"F carburant   H coque", white},
        {"V orange = trop vite pour se poser", white},
    }
    local y = 96
    for _,r in ipairs(rows) do
        centered(r[1], y, fonts.f16, r[2])
        y = y + 24
    end
    centered("A : CONTINUER", 400, fonts.f24, {65,226,219})
end

local SPEAKERS = {
    {"LUNA :",     {120,235,225}},
    {"VARGA :",    {255,188,83}},
    {"CONTROLE :", {140,225,150}},
}
local NARRATION = {179,205,219}

local function drawCard()
    local c = cardList[cardIdx]
    panel(42, 40, 556, 400)
    local f = fit(c[1], 520, {fonts.f24, fonts.f16})
    centered(c[1], 58, f, {236,245,248})
    color(43,205,211); rect(W/2-60, 94, 120, 2)
    local lines = wrap(c[2], 500, 16)
    local cols, cur, newPara = {}, NARRATION, true
    for i,l in ipairs(lines) do
        if l == "" then newPara = true; cols[i] = NARRATION
        else
            if newPara then
                cur = NARRATION
                for _,sp in ipairs(SPEAKERS) do
                    if l:sub(1, #sp[1]) == sp[1] then cur = sp[2] end
                end
                newPara = false
            end
            cols[i] = cur
        end
    end
    drawLines(lines, 70, 108, 500, fonts.f16, cols, 22)
    local prompt = (cardIdx == #cardList) and cardLast or "A : CONTINUER"
    centered(prompt, 408, fonts.f16, {255,190,81})
    centered(cardIdx.."/"..#cardList, 420, fonts.f16, {90,110,130})
end

local function drawOverlays()
    if paused then
        panel(160, 150, 320, 180)
        centered("PAUSE", 166, fonts.f32, {236,244,248})
        centered("C : reprendre", 222, fonts.f16, {82,226,218})
        centered("MENU : titre", 248, fonts.f16, {82,226,218})
        centered("B : musique "..(Audio.musicOn and "OUI" or "NON"), 274, fonts.f16, {82,226,218})
    elseif state == "debrief" then
        local m = mission()
        panel(95, 100, 450, 280)
        centered("MISSION ACCOMPLIE", 116, fonts.f24, {76,233,216})
        local f = fit(m.name, 420, {fonts.f24, fonts.f16})
        centered(m.name, 152, f, {255,190,81})
        centered("Carburant : "..math.floor(fuel).."%", 202, fonts.f16, {198,216,227})
        centered("Coque : "..math.floor(hull).."%", 228, fonts.f16, {198,216,227})
        centered("Temps : "..string.format("%d:%02d", math.floor(missionTime/60), math.floor(missionTime%60)), 254, fonts.f16, {198,216,227})
        if Save.ok then centered("Progression sauvegardee", 290, fonts.f16, {120,200,120}) end
        centered("A : CONTINUER", 336, fonts.f16, {78,227,218})
    end
end

function Game.draw()
    if state == "card" then
        drawSky(); drawRidges(); drawTerrain(); drawCard(); return
    end
    drawSky()
    if state == "title" then drawRidges(); drawTerrain(); drawTitle(); return end
    if state == "instructions" then drawRidges(); drawTerrain(); drawInstructions(); return end

    drawRidges()
    local m = mission()
    if m.decor and m.decor.kind == "station" then
        drawStation(m.decor.x, groundAt(m.decor.x), m.decor.big)
    elseif m.decor and m.decor.kind == "mast" then
        drawMast(m.decor.x, groundAt(m.decor.x))
    end
    drawTerrain()
    drawPads()
    drawBeams()
    if m.cell and cargo == 0 then drawCell(m.cell.x, m.cell.y) end
    for _,r in ipairs(m.rocks or EMPTY) do drawRock(r.x, groundAt(r.x) - 9) end
    for _,d in ipairs(m.debris or EMPTY) do drawDebris(d) end
    drawWindStreaks()
    drawParticles(); drawShip(); drawHUD()
    drawBanner(); drawMessage(); drawOverlays()
end

-- ---------------------------------------------------------------------------
-- Entrees
-- ---------------------------------------------------------------------------
local function showCards(list, done, sky, lastPrompt)
    if #list == 0 then done(); return end
    cardList, cardIdx, cardDone = list, 1, done
    cardLast = lastPrompt or "A : CONTINUER"
    skyOverride = sky
    state = "card"
end

local function beginMission(i)
    local m = Data.missions[i]
    showCards(m.pre or EMPTY, function() startMission(i) end, m.sky, "A : DECOLLER")
end

local function backToTitle()
    skyOverride = nil
    titleAnim = 0
    missionIndex = 1
    resetMission()
    buildMenu()
    state = "title"
end

local function afterDebrief()
    local m = mission()
    local nextI = missionIndex + 1
    if nextI > #Data.missions then
        showCards(m.post or EMPTY, backToTitle, m.sky, "A : TITRE")
    else
        showCards(m.post or EMPTY, function() beginMission(nextI) end, m.sky, "A : MISSION SUIVANTE")
    end
end

local function toggleMusic()
    Audio.toggleMusic()
    Save.music = Audio.musicOn and 1 or 0
    Save.save()
end

local function confirm(k) return k == "return" or k == "space" end

local function doMenu(it)
    Audio.play("menu")
    if it.act == "continue" then beginMission(Save.next)
    elseif it.act == "new" then state = "instructions"
    elseif it.act == "chapter" then beginMission(it.mission) end
end

function Game.keypressed(key)
    if key == "escape" then
        if state == "game" and paused then paused = false
        elseif state ~= "title" then
            Audio.thrust(false)
            backToTitle()
        end
        return
    end
    if key == "x" or key == "b" or key == "m" then toggleMusic(); return end
    if (key == "p" or key == "c") and state == "game" then
        paused = not paused
        Audio.thrust(false)
        return
    end
    if (key == "r" or key == "v") and (state == "game" or state == "debrief") then
        state = "game"; resetMission(); return
    end

    if state == "title" then
        if key == "up" or key == "z" or key == "w" then
            menuSel = menuSel - 1; if menuSel < 1 then menuSel = #menu end; Audio.play("menu")
        elseif key == "down" or key == "s" then
            menuSel = menuSel + 1; if menuSel > #menu then menuSel = 1 end; Audio.play("menu")
        elseif key == "u" then
            Save.unlockAll = true; buildMenu()
        elseif confirm(key) then
            doMenu(menu[menuSel])
        end
    elseif state == "instructions" then
        if confirm(key) then Audio.play("menu"); beginMission(1) end
    elseif state == "card" then
        if confirm(key) then
            Audio.play("card")
            cardIdx = cardIdx + 1
            if cardIdx > #cardList then
                local d = cardDone
                cardList, cardDone = nil, nil
                d()
            end
        end
    elseif state == "game" then
        if ship.landed and confirm(key) then
            Save.next = missionIndex + 1
            if Save.next > Save.best then Save.best = Save.next end
            Save.save()
            state = "debrief"
        end
    elseif state == "debrief" then
        if confirm(key) then afterDebrief() end
    end
end

function Game.keyreleased(key) end
function Game.focus(focused)
    if not focused and state == "game" then paused = true; Audio.thrust(false) end
end

return Game
