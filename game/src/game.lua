-- LUNAR COURIER - moteur de jeu (AKA-Love / LOVE 11.x, Lua 5.1)
-- Regles de compatibilite : pas d'alpha sur les primitives, pas de canvas, pas de polygone concave,
-- pas de love.graphics.clear, texte ASCII, 1 seul argument par isDown(),
-- audio, images et sauvegarde protegees par pcall (le jeu tourne meme sans).
local Data  = require("src.data")
local Audio = require("src.audio")
local Save  = require("src.save")
local Art   = require("src.art")
local I     = require("src.i18n")
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
local LONG_PRESS = 0.7     -- MENU maintenu plus de 0,7 s = capture d'ecran
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
local worldW, ncol, camX = 640, 160, 0
local terrPts = {}
local pads = {}
local details = {strata = {}, craters = {}, specks = {}}
local cardMission, cardKind, cardIdx, cardDone, cardLastKey = 1, "pre", 1, nil, "card_next"
local cardArt, cardT = nil, 0   -- illustrations des cartes, temps ecoule sur la carte courante
local menu, menuSel = {}, 1
local skyOverride = nil
local titleAnim = 0 -- chronometre de la sequence d arrivee du vaisseau
local explore = {x=100, y=0, fixedY=0, repaired=false, t=0, phase=1}
local sysOpen, sysPage, sysSel = false, "main", 1   -- menu systeme (MENU court)
local escDown = nil                                  -- instant d'appui sur MENU (appui long = capture)
local toast, toastT, shotPending = "", 0, 0
local wipeT, lastKey, shakeT = 0, "", 0     -- transition en volet, cle de l'ecran precedent, secousse
local lastRank = 0
local RANKS = {"C", "B", "A", "S"}

local PAL = {
    earth = {bg={4,9,22},  band1={7,17,37},  band2={9,23,43},  r1={9,20,38},  r2={16,30,48},
             top={77,91,101}, ground={49,61,72}, speck={63,75,86}},
    far   = {bg={3,5,16},  band1={12,10,32}, band2={18,14,44}, r1={14,14,32}, r2={22,22,44},
             top={104,110,132}, ground={58,62,82}, speck={74,78,100}},
    peak  = {bg={6,14,30}, band1={10,26,50}, band2={14,34,62}, r1={12,30,54}, r2={20,42,70},
             top={150,172,192}, ground={72,88,106}, speck={96,112,130}},
}

-- Forme des reliefs lointains selon le theme de la mission : {base, amp1, freq1, amp2, freq2}
local THEMES = {
    plain  = {r1={292,28,0.040,16,0.11}, r2={350,14,0.070, 8,0.20}},
    crater = {r1={300,40,0.025,10,0.14}, r2={352,18,0.050, 6,0.20}},
    canyon = {r1={280,45,0.030,25,0.09}, r2={350,22,0.045,10,0.18}},
    ruins  = {r1={296,24,0.060,18,0.15}, r2={350,12,0.080,10,0.23}},
    far    = {r1={290,34,0.035,20,0.12}, r2={352,16,0.065, 9,0.19}},
    wreck  = {r1={300,20,0.050,14,0.16}, r2={356,10,0.090, 6,0.25}},
    peak   = {r1={270,50,0.028,30,0.10}, r2={340,26,0.050,12,0.17}},
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
local function setToast(text, dur) toast, toastT = text, dur or 3 end

-- ---------------------------------------------------------------------------
-- Terrain (monde large : worldW px, colonnes de COL px)
-- ---------------------------------------------------------------------------
local function groundAt(x)
    local i = math.floor(x / COL)
    if i < 0 then i = 0 elseif i > ncol-1 then i = ncol-1 end
    return tg[i]
end

local function buildTerrain(pts, w)
    worldW = w or 640
    terrPts = pts
    ncol = math.floor(worldW / COL)
    maxG = 0
    for i = 0, ncol-1 do
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
    for i = 1, ncol do
        if i == ncol or tg[i] ~= tg[s] then
            runs[#runs+1] = {x=s*COL, w=(i-s)*COL, y=tg[s]}
            s = i
        end
    end
    -- Details du sol (strates, crateres, grains) : positions deterministes, ancrees au monde.
    details = {strata = {}, craters = {}, specks = {}}
    local per = math.max(1, worldW / 640)
    for i = 1, math.floor(24 * per) do
        local x = (i*53 + 17) % worldW
        details.strata[#details.strata+1] = {x=x, dy=10 + (i*19)%54, w=5+(i%4)*3, alt=(i%3==0)}
    end
    for i = 1, math.floor(8 * per) do
        details.craters[#details.craters+1] = {x=(i*79 + 31) % worldW}
    end
    for i = 1, math.floor(16 * per) do
        details.specks[#details.specks+1] = {x=(i*59) % worldW, dy=8 + (i*29) % 60, w=2+(i%4), h=1+(i%2)}
    end
end

-- ---------------------------------------------------------------------------
-- Mission
-- ---------------------------------------------------------------------------
local function resetMission()
    local m = mission()
    buildTerrain(m.terrain, m.w)
    pads = {}
    for i,p in ipairs(m.pads) do pads[i] = {x=p.x, y=groundAt(p.x)} end
    padIndex, padDone = 1, {}
    ship = {x=80, y=175, vx=0, vy=0, angle=0, thrust=false, landed=false, resting=false, hitCooldown=0}
    camX = clamp(ship.x - W/2, 0, math.max(0, worldW - W))
    fuel, hull, cargo, missionTime = 100, 100, 0, 0
    failed, fuelWarned, lowWarned, paused = false, false, false, false
    particles, noteTimers, windCur, radioShown = {}, {}, 0, {}
    message, messageTimer = "", 0
    thrustTimer = 0
    Audio.thrust(false)
    explore.x, explore.y, explore.t, explore.phase = 100, 0, 0, 1
    explore.repaired = false
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
        menu[#menu+1] = {label=I.t("menu_continue", Save.next), act="continue"}
    end
    menu[#menu+1] = {label=I.t("menu_new"), act="new"}
    for ch = 2, 3 do
        local start = Data.chapterStart[ch]
        if Save.unlockAll or Save.best >= start then
            menu[#menu+1] = {label=I.t("menu_chapter", ch), act="chapter", mission=start}
        end
    end
    menuSel = clamp(menuSel, 1, #menu)
end

local function saveSettings()
    Save.lang = I.lang
    Save.kb = I.kb
    Save.music = Audio.musicOn and 1 or 0
    Save.save()
end

function Game.load()
    titleAnim = 0
    if os and os.time then math.randomseed(os.time())
    elseif love.timer and love.timer.getTime then math.randomseed(math.floor(love.timer.getTime()*100000))
    else math.randomseed(12345) end
    fonts.f16, fonts.f24, fonts.f32, fonts.f48 = mkfont(16), mkfont(24), mkfont(32), mkfont(48)
    for i = 1, 22 do
        stars[#stars+1] = {x=math.random(0,W), y=math.random(0,330), s=math.random(2,3), phase=math.random()*6.28}
    end
    Save.load()
    if Save.lang then I.setLang(Save.lang) end
    if Save.kb then I.setKb(Save.kb, true) end
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
    shakeT = 0.3
    ship.hitCooldown = 1.2
    ship.vx = ship.vx + (dx >= 0 and 45 or -45)
    ship.vy = -math.abs(ship.vy)*0.45 - 22
    hull = math.max(0, hull - 20)
    addParticles(ship.x, ship.y, 12, "spark")
    Audio.play("hit")
    if hull <= 0 then failMission(I.t("hull_broken"))
    else setMessage(text, 2.2) end
end

local function activatePad()
    padDone[padIndex] = true
    if padIndex >= #pads then
        ship.landed = true
        addParticles(ship.x, ship.y + FEET, 22, "dust")
        setMessage(I.t("landed"), 99)
        Audio.thrust(false)
        Audio.play("land")
    else
        padIndex = padIndex + 1
        fuel = math.min(100, fuel + 25)
        addParticles(ship.x, ship.y + FEET, 14, "pickup")
        setMessage(I.t("pad_on", padIndex-1, #pads), 3)
        Audio.play("pad")
    end
end

-- ---------------------------------------------------------------------------
-- Entrees : touches de pilotage selon la disposition choisie
-- ---------------------------------------------------------------------------
local function down(k) return love.keyboard.isDown(k) end
local function anyDown(list)
    for _,k in ipairs(list) do if love.keyboard.isDown(k) then return true end end
    return false
end

local function syncMusic()
    if state == "game" or state == "debrief" then Audio.setMusic("mus_ch"..chapterOf(missionIndex))
    else Audio.setMusic("mus_story") end
end

-- ---------------------------------------------------------------------------
-- Mise a jour
-- ---------------------------------------------------------------------------
function Game.update(dt)
    dt = math.min(dt, 1/30)
    time = time + dt
    if state == "title" then titleAnim = math.min(titleAnim + dt, 4.2) end
    if state == "card" then cardT = cardT + dt end
    if toastT > 0 then toastT = math.max(0, toastT - dt) end
    if shakeT > 0 then shakeT = math.max(0, shakeT - dt) end
    local sk = state..(state == "card" and cardIdx or "")..(state == "game" and missionIndex or "")
    if sk ~= lastKey then lastKey = sk; wipeT = 0.35 end
    if wipeT > 0 then wipeT = math.max(0, wipeT - dt) end
    syncMusic()
    if sysOpen then Audio.thrust(false); return end
    if messageTimer > 0 then messageTimer = math.max(0, messageTimer - dt) end
    for k,v in pairs(noteTimers) do noteTimers[k] = v - dt end
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx*dt; p.y = p.y + p.vy*dt
        p.vx = p.vx*0.98; p.vy = p.vy + 16*dt
        p.life = p.life - dt
        if p.life <= 0 then table.remove(particles, i) end
    end
    if state == "explore" then
        explore.t = explore.t + dt
        local keys = I.moveKeys()
        if anyDown(keys.left) then explore.x = math.max(42, explore.x - 115*dt) end
        if anyDown(keys.right) then explore.x = math.min(598, explore.x + 115*dt) end
        Audio.thrust(false)
        return
    end
    if state ~= "game" or paused or ship.landed or failed then Audio.thrust(false); return end

    local m = mission()
    missionTime = missionTime + dt

    -- Repliques radio en vol (texte dans la langue courante)
    local rt = I.mission(missionIndex).radio or EMPTY
    for i,t in ipairs(m.radioT or EMPTY) do
        if not radioShown[i] and rt[i] and missionTime >= t then
            radioShown[i] = true
            setMessage(rt[i], 4.5)
        end
    end

    -- Commandes (un seul argument par appel : compatible runtime AKA)
    local keys = I.moveKeys()
    if anyDown(keys.left) then ship.angle = ship.angle - TURN*dt end
    if anyDown(keys.right) then ship.angle = ship.angle + TURN*dt end
    local thrusting = anyDown(keys.up) and fuel > 0
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
        setMessage(I.t("fuel_out"), 99)
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
    if ship.x > worldW-16 then ship.x = worldW-16; ship.vx = -math.abs(ship.vx)*0.35 end
    if ship.y < TOP_LIMIT then ship.y = TOP_LIMIT; ship.vy = math.abs(ship.vy)*0.25 end

    -- Camera : suit le vaisseau avec un peu d'avance sur sa vitesse
    local target = clamp(ship.x - W/2 + ship.vx*0.4, 0, math.max(0, worldW - W))
    camX = camX + (target - camX) * math.min(1, 5*dt)

    -- Capsule energetique
    if m.cell and cargo == 0 and math.abs(ship.x - m.cell.x) < 24 and math.abs(ship.y - m.cell.y) < 26 then
        cargo = 1
        fuel = math.min(100, fuel + 22)
        addParticles(m.cell.x, m.cell.y, 18, "pickup")
        setMessage(I.t("cell_got"), 3)
        Audio.play("pickup")
    end

    -- Obstacles
    ship.hitCooldown = math.max(0, ship.hitCooldown - dt)
    if ship.hitCooldown <= 0 and not failed then
        for _,r in ipairs(m.rocks or EMPTY) do
            local ry = groundAt(r.x) - 9
            if math.abs(ship.x - r.x) < 20 and math.abs(ship.y - ry) < 22 then
                hit(ship.x - r.x, I.t("hit_rock")); break
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
                    note("drone", I.t("drone"), 1.5, 2)
                else
                    hit(ship.x - dx0, I.t("hit_wreck"))
                end
                break
            end
        end
    end
    if ship.hitCooldown <= 0 and not failed then
        for _,b in ipairs(m.beams or EMPTY) do
            if beamState(b) == "on" and math.abs(ship.x - b.x) < 17 then
                hit(ship.x - b.x, I.t("hit_beam")); break
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
                note("nocargo", I.t("no_cargo"), 2.5, 4)
            end
        elseif math.abs(ship.vy) < 60 and math.abs(ship.angle) < 0.5 then
            ship.vy = 0
            ship.vx = ship.vx * 0.8
            ship.resting = true
            if math.abs(impact) > 12 then
                if onLive then note("rough", I.t("too_fast"), 2.2, 3)
                else note("off", I.t("off_pad"), 2.5, 4) end
            elseif onLive and math.abs(ship.angle) >= SAFE_ANGLE then
                note("tilt", I.t("tilt"), 2, 5)
            end
        else
            if math.abs(impact) > CRASH_VY then
                hull = math.max(0, hull - 12)
                if hull <= 0 then failMission(I.t("hull_broken")) end
            end
            ship.vy = -math.min(math.abs(ship.vy)*0.38 + 10, 65)
            ship.vx = ship.vx * 0.62
            ship.angle = ship.angle * 0.72
            addParticles(ship.x, ship.y + FEET, 7, "dust")
            if not failed and note("bounce", I.t("bounce"), 2, 3) then
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
    for i = 0, 15 do
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

local function ridgeH(r, xw) return r[1] + r[2]*math.sin(xw*r[3]) + r[4]*math.sin(xw*r[5] + 1) end

-- Reliefs lointains en parallaxe (defilent plus lentement que le sol) : trapezes convexes tous les 64 px.
local function drawRidges()
    local p = pal()
    local th = THEMES[mission().theme or "plain"] or THEMES.plain
    for layer = 1, 2 do
        local r, par = th["r"..layer], (layer == 1) and 0.18 or 0.35
        local off = camX * par
        local c0 = math.floor(off / 64)
        colorT(layer == 1 and p.r1 or p.r2)
        for c = c0, c0 + 10 do
            local x0, x1 = c*64 - off, (c+1)*64 - off
            local h0, h1 = math.floor(ridgeH(r, c*64)), math.floor(ridgeH(r, (c+1)*64))
            love.graphics.polygon("fill", x0, h0, x1, h1, x1, H, x0, H)
        end
    end
    -- Quelques facettes anguleuses donnent du relief sans texture couteuse.
    local off = camX * 0.35
    local c0 = math.floor(off / 97)
    for i = c0, c0 + 7 do
        local x = i*97 + 7 - off
        local y = math.floor(ridgeH(th.r2, i*97)) + 10 + (i%3)*7
        colorT(i%2==0 and {26,43,62} or {30,45,64})
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

-- Decors varies (sans collision). x = centre, b = sol sous l'objet. Polygones convexes uniquement.
local DECOR = {}
DECOR.dome = function(x, b)
    color(24,38,54); rect(x-42, b-20, 84, 20)
    color(36,60,82); love.graphics.polygon("fill", x-38,b-20, x-27,b-46, x-9,b-60, x+9,b-60, x+27,b-46, x+38,b-20)
    color(61,241,225); rect(x-6, b-44, 12, 6)
    color(255,190,79); rect(x-28, b-13, 6, 6); rect(x+22, b-13, 6, 6)
    color(18,30,44); rect(x-6, b-16, 12, 16)
end
DECOR.dish = function(x, b)
    color(28,40,56); rect(x-3, b-40, 6, 40); rect(x-14, b-6, 28, 6)
    color(70,96,116); love.graphics.polygon("fill", x-24,b-52, x+6,b-48, x+14,b-62, x-16,b-66)
    color(110,140,160); love.graphics.line(x-22,b-54, x+12,b-62)
    if math.floor(time*2) % 2 == 0 then color(255,90,80) else color(90,30,30) end
    rect(x+11, b-66, 4, 4)
end
DECOR.tower = function(x, b)
    color(28,40,56); rect(x-4, b-124, 8, 124)
    color(44,64,84); rect(x-16, b-92, 32, 3); rect(x-11, b-62, 22, 3); rect(x-7, b-34, 14, 3)
    color(60,84,104); rect(x-1, b-140, 2, 16)
    if math.floor(time*2 + x) % 2 == 0 then color(255,90,80) else color(90,30,30) end
    rect(x-3, b-130, 6, 6)
end
DECOR.crane = function(x, b)
    color(36,48,62); rect(x-20, b-10, 40, 10)
    color(60,80,98); rect(x-3, b-74, 6, 66)
    color(48,66,84); love.graphics.polygon("fill", x-3,b-74, x+50,b-66, x+50,b-60, x-3,b-66)
    color(110,140,160); love.graphics.line(x+46,b-62, x+46,b-34)
    color(255,190,79); rect(x+41, b-34, 10, 7)
end
DECOR.panels = function(x, b)
    for k = 0, 3 do
        local px = x + (k-1.5)*30
        color(40,56,72); rect(px-2, b-14, 4, 14)
        color(26,66,116); love.graphics.polygon("fill", px-12,b-14, px+12,b-14, px+8,b-30, px-16,b-30)
        color(80,150,210); love.graphics.line(px-12,b-14, px-16,b-30)
        color(120,190,235); rect(px-6, b-24, 8, 2)
    end
end
DECOR.pylon = function(x, b)
    color(30,44,60); rect(x-3, b-64, 6, 64)
    color(48,68,88); rect(x-14, b-64, 28, 4); rect(x-9, b-44, 18, 3)
    if math.floor(time*3 + x) % 2 == 0 then color(61,241,225) else color(30,100,110) end
    rect(x-2, b-72, 4, 6)
end
DECOR.crystals = function(x, b)
    color(30,120,160); love.graphics.polygon("fill", x-18,b, x-10,b-46, x-2,b)
    color(60,200,235); love.graphics.polygon("fill", x-6,b, x+4,b-70, x+14,b)
    color(150,235,250); love.graphics.polygon("fill", x+1,b-10, x+4,b-62, x+8,b-10)
    color(40,150,190); love.graphics.polygon("fill", x+10,b, x+20,b-36, x+30,b)
end
DECOR.arch = function(x, b)
    color(40,52,68); rect(x-32, b-62, 14, 62); rect(x+18, b-62, 14, 62)
    color(52,66,84); love.graphics.polygon("fill", x-34,b-62, x-22,b-86, x+22,b-86, x+34,b-62)
    color(28,38,52); rect(x-18, b-60, 36, 4)
    color(255,190,79); rect(x-2, b-82, 4, 6)
end
DECOR.wreck = function(x, b)
    color(30,38,50); love.graphics.polygon("fill", x-62,b, x-50,b-26, x-12,b-38, x+30,b-30, x+56,b-8, x+62,b)
    color(46,58,74); love.graphics.polygon("fill", x-12,b-38, x-2,b-72, x+8,b-36)
    color(255,190,79); rect(x-30, b-18, 6, 5); rect(x-14, b-22, 6, 5)
    color(18,24,34); rect(x+20, b-14, 14, 8)
end
DECOR.camp = function(x, b)
    color(150,100,40); love.graphics.polygon("fill", x-26,b, x,b-36, x+26,b)
    color(255,190,79); love.graphics.polygon("fill", x-8,b, x,b-22, x+8,b)
    color(70,50,30); rect(x-30, b-2, 60, 2)
    if math.floor(time*6) % 2 == 0 then color(255,150,50) else color(255,210,90) end
    rect(x+38, b-10, 7, 10)
    color(255,240,160); rect(x+40, b-14, 3, 4)
end

local function drawDecor()
    local m = mission()
    for _,d in ipairs(m.decor or EMPTY) do
        local kind, x = d[1], d[2]
        if x - camX > -160 and x - camX < W + 160 then
            local b = math.max(groundAt(x - 30), groundAt(x), groundAt(x + 30))
            if kind == "station" then drawStation(x, b, d[3])
            elseif kind == "mast" then drawMast(x, b)
            elseif DECOR[kind] then DECOR[kind](x, b) end
        end
    end
end

local function drawTerrain()
    local p = pal()
    local cx = math.floor(camX)
    -- Relief : un trapeze convexe par segment du profil (au lieu d'un rectangle par colonne de 4 px),
    -- ce qui garde quelques dizaines de primitives par image sur la console.
    colorT(p.ground)
    for k = 1, #terrPts - 1 do
        local a, b = terrPts[k], terrPts[k+1]
        if b[1] - cx > -4 and a[1] - cx < W + 4 and b[1] > a[1] then
            love.graphics.polygon("fill", a[1]-cx, a[2], b[1]-cx, b[2], b[1]-cx, H, a[1]-cx, H)
        end
    end
    colorT(p.top)
    if love.graphics.setLineWidth then love.graphics.setLineWidth(2) end
    for k = 1, #terrPts - 1 do
        local a, b = terrPts[k], terrPts[k+1]
        if b[1] - cx > -4 and a[1] - cx < W + 4 and b[1] > a[1] then
            love.graphics.line(a[1]-cx, a[2]+1, b[1]-cx, b[2]+1)
        end
    end
    if love.graphics.setLineWidth then love.graphics.setLineWidth(1) end
    -- Strates sombres et petites inclusions minerales, deterministes pour rester legers.
    for _,s in ipairs(details.strata) do
        local sx = s.x - cx
        if sx > -20 and sx < W then
            local y = groundAt(s.x) + s.dy
            if y < H-3 then
                colorT(s.alt and {27,39,51} or {39,51,63})
                rect(sx, y, s.w, 2)
                colorT(p.speck); rect(sx+2, y+3, 2, 1)
            end
        end
    end
    -- Crateres stylises sur les zones visibles du sol.
    for _,c in ipairs(details.craters) do
        local sx = c.x - cx
        if sx > -20 and sx < W then
            local gy = groundAt(c.x)
            if gy < H-12 then
                color(30,42,54); rect(sx-7,gy+4,15,3)
                color(68,82,94); rect(sx-5,gy+4,9,1)
            end
        end
    end
    colorT(p.speck)
    for _,s in ipairs(details.specks) do
        local sx = s.x - cx
        local y = maxG + s.dy
        if sx > -8 and sx < W and y < H then rect(sx, y, s.w, s.h) end
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
        if p.x - camX > -120 and p.x - camX < W + 120 then
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
    if x - camX < -40 or x - camX > W + 40 then return end
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
        if b.x - camX > -30 and b.x - camX < W + 30 then
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

-- Objet a rejoindre : la capsule d'abord, puis la balise active.
local function targetPos()
    local m = mission()
    if m.cell and cargo == 0 then return m.cell.x, m.cell.y, "cell" end
    local p = pads[padIndex]
    if p then return p.x, p.y - 40, "pad" end
end

-- Fleche au bord de l'ecran quand la cible est hors champ, avec la distance (unites de 10 px).
local function drawArrows()
    local tx, ty, kind = targetPos()
    if not tx then return end
    local sx = tx - camX
    if sx >= 30 and sx <= W - 30 then return end
    local y = clamp(ty, 110, 400)
    if kind == "cell" then color(245,163,52) else color(53,215,211) end
    local dist = tostring(math.floor(math.abs(tx - ship.x) / 10))
    love.graphics.setFont(fonts.f16.obj)
    if sx < 30 then
        love.graphics.polygon("fill", 8, y, 34, y-14, 34, y+14)
        love.graphics.print(dist, 40, y-8)
    else
        love.graphics.polygon("fill", W-8, y, W-34, y-14, W-34, y+14)
        love.graphics.print(dist, W-44-#dist*16, y-8)
    end
end

-- ---------------------------------------------------------------------------
-- HUD (largeur de texte prudente : 16 px par caractere)
-- ---------------------------------------------------------------------------
local function drawMiniMap()
    if worldW <= W + 1 then return end
    local x0, y0, mw = 346, 14, 276
    panel(336, 8, 294, 58)
    -- profil du terrain (70 colonnes) puis marqueurs
    color(28,64,78)
    for k = 0, 33 do
        local gy = tg[math.floor(k * (ncol-1) / 33)] or 390
        local h = clamp(math.floor((480 - gy) * 30 / 300), 2, 34)
        rect(x0 + k*8, 60 - h, 8, h)
    end
    for i,p in ipairs(pads) do
        if padDone[i] then color(80,240,150) elseif i == padIndex then color(53,215,211) else color(60,110,120) end
        rect(x0 + p.x / worldW * mw - 2, 40, 5, 12)
    end
    local m = mission()
    if m.cell and cargo == 0 then color(245,163,52); rect(x0 + m.cell.x / worldW * mw - 2, 28, 5, 8) end
    color(255,255,255); rect(x0 + ship.x / worldW * mw - 2, 20, 5, 6)
    color(255,190,79)
    love.graphics.rectangle("line", x0 + camX / worldW * mw, 14, W / worldW * mw, 46)
end

local function drawHUD()
    local m = mission()
    panel(10, 8, 316, 58)
    love.graphics.setFont(fonts.f16.obj)
    color(145,229,231); love.graphics.print(string.format("M%02d", missionIndex), 18, 14)
    color(201,215,225); love.graphics.print("F", 76, 14)
    color(28,45,60); rect(96, 18, 96, 8)
    if fuel < 25 then
        if math.floor(time*4) % 2 == 0 then color(255,87,72) else color(150,40,34) end
    else color(36,213,193) end
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
    drawMiniMap()
end

local msgCache, msgLines = nil, nil
local function drawMessage()
    if messageTimer <= 0 or message == "" then return end
    if msgCache ~= message then msgCache, msgLines = message, wrap(message, 520, 16) end
    local lines = msgLines
    local h = #lines * 20 + 16
    local y = H - 18 - h
    panel(42, y, 556, h)
    drawLines(lines, 52, y + 8, 536, fonts.f16, {202,222,231}, 20)
end

local function drawBanner()
    if missionTime >= 3.5 or paused then return end
    local t = I.mission(missionIndex)
    panel(60, 76, 520, 70)
    local f = fit(t.name, 490, {fonts.f24, fonts.f16})
    centered(t.name, 86, f, {255,190,83}, 60, 520)
    centered(I.t("obj")..t.objective, 118, fonts.f16, {194,211,224}, 60, 520)
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
    centered(I.t("title_sub"), 44, fonts.f24, {90,224,227})
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
        centered(I.t("title_tag"), 164, fonts.f24, {255,198,111})
    end

    -- Menu compact, puis commandes reparties sur plusieurs lignes pour l AKA.
    color(39,88,110); rect(92, 280, 456, 2)
    local y = 288
    for i,it in ipairs(menu) do
        if i == menuSel then
            color(255,190,79); rect(170, y+10, 18, 2); rect(452, y+10, 18, 2)
            centered("> "..it.label.." <", y, fonts.f24, {255,190,83})
        else centered(it.label, y, fonts.f24, {82,229,218}) end
        y = y + 26
    end
    centered(I.t("hint1"), 402, fonts.f24, {158,184,202})
    centered(I.t("hint2"), 426, fonts.f24, {158,184,202})
    centered(I.t("hint3"), 452, fonts.f16, {120,151,170})
end

-- Aide : libelles de touches selon la plateforme / le clavier / la langue.
local function drawHelp(promptKey)
    panel(38, 30, 564, 420)
    centered(I.t("help_title"), 44, fonts.f32, {235,244,248})
    local amber, white = {255,188,83}, {198,216,227}
    local k = (I.kb == "qwertz") and "qwerty" or I.kb
    local rows = {
        {I.t("help_turn_"..k), white}, {I.t("help_thrust_"..k), white},
        {I.t("help_ok"), white}, {I.t("help_restart"), white}, {I.t("help_music"), white},
        {I.t("help_mission"), amber},
        {I.t("help_m1"), white}, {I.t("help_m2"), white}, {I.t("help_m3"), white},
        {I.t("help_m4"), white}, {I.t("help_m5"), white}, {I.t("help_m6"), white},
    }
    local y = 96
    for _,r in ipairs(rows) do
        centered(r[1], y, fonts.f16, r[2])
        y = y + 24
    end
    local pr = I.t(promptKey)
    centered(pr, 400, fit(pr, 600, {fonts.f24, fonts.f16}), {65,226,219})
end

local function drawCredits()
    panel(120, 70, 400, 340)
    centered(I.t("credits_title"), 86, fonts.f32, {235,244,248})
    centered(I.t("credits_1"), 150, fonts.f32, {255,188,83})
    centered(I.t("credits_2"), 214, fonts.f24, {198,216,227})
    centered(I.t("credits_3"), 250, fonts.f24, {198,216,227})
    centered(I.t("credits_4"), 280, fonts.f24, {198,216,227})
    centered(I.t("credits_5"), 336, fonts.f16, {82,226,218})
    centered(I.t("menu_foot"), 372, fonts.f16, {120,151,170})
end

local NARRATION = {179,205,219}

-- Portrait vectoriel de LUNA : dessin de secours quand l'illustration est absente.
local function drawLunaPortrait(x, y)
    color(3,14,28); rect(x, y, 60, 60)
    color(28,100,119); rect(x, y, 60, 2); rect(x, y, 2, 60)
    color(48,197,207); rect(x+58, y+2, 2, 56); rect(x+2, y+58, 56, 2)
    -- Epaules et col du module de bord.
    color(20,45,68)
    love.graphics.polygon("fill", x+7,y+56, x+12,y+43, x+23,y+38, x+37,y+38, x+48,y+43, x+53,y+56)
    color(50,121,145)
    love.graphics.polygon("fill", x+20,y+56, x+23,y+43, x+37,y+43, x+40,y+56)
    color(255,190,79); rect(x+27,y+43,6,2)
    -- Chevelure, visage et meches.
    color(24,38,76); love.graphics.circle("fill", x+30, y+25, 21)
    color(151,219,225); love.graphics.circle("fill", x+30, y+27, 15)
    color(34,65,106)
    love.graphics.polygon("fill", x+10,y+23, x+13,y+9, x+25,y+5, x+43,y+9, x+50,y+22)
    -- Yeux cyan et expression calme.
    color(22,62,91); rect(x+20,y+27,5,2); rect(x+35,y+27,5,2)
    color(48,225,220); rect(x+21,y+27,2,2); rect(x+36,y+27,2,2)
    color(77,128,151); rect(x+28,y+31,4,2)
    color(255,190,120); rect(x+27,y+35,6,2)
    -- Petite signature lumineuse sur la tempe.
    color(48,225,220); rect(x+42,y+24,3,5)
end

local function cardsOf() return I.mission(cardMission)[cardKind] or EMPTY end

-- Interlocuteur d'un paragraphe : identifie par son prefixe ("LUNA :", ...), selon la langue.
local function speakerOf(line)
    for _,sp in ipairs(I.speakers()) do
        if line:sub(1, #sp[1]) == sp[1] then return sp end
    end
    return nil
end

local function drawCard()
    local list = cardsOf()
    local c = list[cardIdx]
    if not c then return end
    -- Bandeau illustre en haut (640x150 virtuels = 320x75 ecran) ; decor de secours si l'image manque.
    color(3,14,28); rect(0, 0, W, 150)
    if not Art.scene(cardArt and cardArt[cardIdx], cardT) then
        drawLunaPortrait(14, 20)
        color(28,100,119); rect(90, 74, 500, 2)
    end
    -- Mise en forme du texte : couleur par interlocuteur, portrait du premier interlocuteur.
    local lines = wrap(c[2], 500, 16)
    local cols, cur, newPara, first = {}, NARRATION, true, nil
    for i,l in ipairs(lines) do
        if l == "" then newPara = true; cols[i] = NARRATION
        else
            if newPara then
                cur = NARRATION
                local sp = speakerOf(l)
                if sp then cur = sp[2]; first = first or sp end
                newPara = false
            end
            cols[i] = cur
        end
    end
    -- Portrait de l'interlocuteur (cadre 104x104 sur le bandeau).
    if first then
        color(3,14,28); rect(10, 10, 108, 108)
        color(43,205,211); rect(10, 10, 108, 2); rect(10, 116, 108, 2); rect(10, 10, 2, 108); rect(116, 10, 2, 108)
        color(255,190,79); rect(10, 10, 14, 2); rect(10, 10, 2, 12)
        if not Art.portrait(first[3], 14, 14) then
            color(20,45,68); rect(14, 14, 96, 96)
            centered(first[1]:sub(1, 1), 46, fonts.f32, first[2], 14, 96)
        end
    end
    -- Bandeau de titre sur le bas de l'illustration.
    color(3,14,28); rect(0, 120, W, 32)
    color(43,205,211); rect(0, 118, W, 2); rect(0, 152, W, 2)
    color(255,190,79); rect(0, 118, 40, 2); rect(W-40, 152, 40, 2)
    local f = fit(c[1], 600, {fonts.f24, fonts.f16})
    centered(c[1], f.size == 24 and 124 or 128, f, {236,245,248})
    panel(30, 160, 580, 314)
    local shown = math.floor(cardT * 70)
    local rem, vis = shown, {}
    for i,l in ipairs(lines) do
        vis[i] = l:sub(1, math.max(0, rem))
        rem = rem - #l - 1
    end
    drawLines(vis, 70, 174, 500, fonts.f16, cols, 20)
    if shown >= #c[2] then
        local prompt = (cardIdx == #list) and I.t(cardLastKey) or I.t("card_next")
        centered(prompt, 436, fonts.f16, {255,190,81})
    end
    centered(cardIdx.."/"..#list, 454, fonts.f16, {90,110,130})
end

-- ---------------------------------------------------------------------------
-- Menu systeme (MENU court) et capture d'ecran
-- ---------------------------------------------------------------------------
local function sysItems()
    local it = {}
    it[#it+1] = {id="resume",   label=I.t("m_resume")}
    it[#it+1] = {id="controls", label=I.t("m_controls")}
    it[#it+1] = {id="lang",     label=I.t("m_lang", I.langNames[I.lang])}
    it[#it+1] = {id="kb",       label=I.t("m_kb", I.kbLabel())}
    it[#it+1] = {id="music",    label=I.t("m_music", I.onoff(Audio.musicOn))}
    it[#it+1] = {id="shot",     label=I.t("m_shot")}
    it[#it+1] = {id="credits",  label=I.t("m_credits")}
    if state ~= "title" then it[#it+1] = {id="title", label=I.t("m_totitle")} end
    it[#it+1] = {id="quit",     label=I.t(I.aka and "m_quit_aka" or "m_quit_pc")}
    return it
end

local function drawSysMenu()
    if sysPage == "help" then drawHelp("menu_foot"); return end
    if sysPage == "credits" then drawCredits(); return end
    local items = sysItems()
    local h = 96 + #items * 30
    local y0 = math.floor((H - h) / 2)
    panel(80, y0, 480, h)
    centered(I.t("menu_title"), y0 + 14, fonts.f32, {235,244,248})
    color(43,205,211); rect(W/2-60, y0 + 54, 120, 2)
    local y = y0 + 68
    for i,it in ipairs(items) do
        if i == sysSel then
            color(255,190,79); rect(100, y+8, 14, 2); rect(526, y+8, 14, 2)
            centered(it.label, y, fonts.f16, {255,190,83})
        else centered(it.label, y, fonts.f16, {82,229,218}) end
        y = y + 30
    end
    centered(I.t("menu_foot"), y0 + h - 24, fonts.f16, {120,151,170})
end

local function takeShot()
    if not (love.graphics and love.graphics.captureScreenshot) then
        setToast(I.t("shot_na"), 3); return
    end
    local name = string.format("lunar_%04d.png", Save.shot + 1)
    local ok = pcall(love.graphics.captureScreenshot, name)
    if ok then
        Save.shot = Save.shot + 1
        Save.save()
        setToast(I.t("shot_ok", name), 3)
    else
        setToast(I.t("shot_fail"), 3)
    end
end

local function drawToast()
    if toastT <= 0 or toast == "" then return end
    local w = math.min(560, #toast * 16 + 40)
    panel(W/2 - w/2, 74, w, 36)
    centered(toast, 83, fonts.f16, {236,245,248})
end

local function drawOverlays()
    if paused then
        panel(160, 150, 320, 180)
        centered(I.t("pause"), 166, fonts.f32, {236,244,248})
        centered(I.t("pause_resume"), 222, fonts.f16, {82,226,218})
        centered(I.t("pause_menu"), 248, fonts.f16, {82,226,218})
        centered(I.t("pause_music", I.onoff(Audio.musicOn)), 274, fonts.f16, {82,226,218})
    elseif state == "debrief" then
        local t = I.mission(missionIndex)
        panel(95, 100, 450, 290)
        centered(I.t("debrief_title"), 116, fonts.f24, {76,233,216})
        local f = fit(t.name, 420, {fonts.f24, fonts.f16})
        centered(t.name, 152, f, {255,190,81})
        centered(I.t("fuel", math.floor(fuel)), 202, fonts.f16, {198,216,227})
        centered(I.t("hull", math.floor(hull)), 228, fonts.f16, {198,216,227})
        centered(I.t("time", string.format("%d:%02d", math.floor(missionTime/60), math.floor(missionTime%60))), 254, fonts.f16, {198,216,227})
        local best = tonumber(Save.ranks:sub(missionIndex, missionIndex)) or lastRank
        centered(I.t("rank", RANKS[lastRank]), 282, fonts.f24, {255,190,81})
        centered(I.t("rank_best", RANKS[math.max(1, best)]), 314, fonts.f16, {145,229,231})
        if Save.ok then centered(I.t("saved"), 340, fonts.f16, {120,200,120}) end
        centered(I.t("card_next"), 356, fonts.f16, {78,227,218})
    end
end

local function drawWorld()
    local m = mission()
    love.graphics.push()
    love.graphics.translate(-math.floor(camX), 0)
    drawDecor()
    love.graphics.pop()
    drawTerrain()
    love.graphics.push()
    love.graphics.translate(-math.floor(camX), 0)
    drawPads()
    drawBeams()
    if m.cell and cargo == 0 then drawCell(m.cell.x, m.cell.y) end
    for _,r in ipairs(m.rocks or EMPTY) do drawRock(r.x, groundAt(r.x) - 9) end
    for _,d in ipairs(m.debris or EMPTY) do drawDebris(d) end
    drawParticles(); drawShip()
    love.graphics.pop()
end

function Game.draw()
    -- Capture d'ecran demandee depuis le menu : prise sur une image propre (sans menu ni message).
    local doShot = false
    if shotPending > 0 then
        shotPending = shotPending - 1
        if shotPending == 0 then doShot = true end
    end

    if state == "card" then
        drawSky(); drawRidges(); drawTerrain(); drawCard()
    elseif state == "title" then
        drawSky(); drawRidges(); drawTerrain(); drawTitle()
    elseif state == "explore" then
        color(7,17,34); rect(0,0,W,H)
        color(13,35,54); rect(0,110,W,250)
        color(27,61,76); rect(0,360,W,120)
        color(74,111,123); rect(0,356,W,5)
        color(20,48,67); rect(28,145,584,210)
        color(43,81,96); rect(36,153,568,194)
        color(9,22,39); rect(54,170,130,170); rect(456,170,130,170)
        color(82,229,218); rect(270,198,100,4); rect(270,198,4,92); rect(366,198,4,92); rect(270,286,100,4)
        color(255,190,83); rect(303,222,34,40); rect(309,214,22,8)
        color(13,35,54); rect(310,230,20,20)
        color(4,10,22); rect(explore.x-9,322,18,34)
        color(82,229,218); rect(explore.x-8,300,16,20); rect(explore.x-11,305,22,9)
        color(255,190,83); rect(explore.x-5,306,10,5)
        color(82,229,218); rect(explore.x-8,350,5,12); rect(explore.x+3,350,5,12)
        panel(50,34,540,74)
        centered(explore.repaired and I.t("explore_restored") or I.t("explore_abandoned"), 43, fonts.f24, {82,229,218})
        centered(explore.repaired and I.t("explore_confirmed") or I.t("explore_prompt"), 78, fonts.f16, {225,237,242})
        centered(I.t("explore_move"), 400, fonts.f16, {180,207,219})
        centered(explore.repaired and I.t("explore_back") or I.t("explore_repair"), 428, fonts.f16, {255,190,83})
        if not I.aka then centered(I.t("explore_pc_hint"), 452, fonts.f16, {120,151,170}) end
    elseif state == "instructions" then
        drawSky(); drawRidges(); drawTerrain(); drawHelp("card_next")
    else
        love.graphics.push()
        if shakeT > 0 then love.graphics.translate(math.floor((math.random()-0.5)*shakeT*30), math.floor((math.random()-0.5)*shakeT*30)) end
        drawSky()
        drawRidges()
        drawWorld()
        drawWindStreaks()
        love.graphics.pop()
        drawArrows(); drawHUD()
        drawBanner(); drawMessage(); drawOverlays()
    end
    if wipeT > 0 then
        local h = math.floor(H / 2 * (wipeT / 0.35))
        color(2,6,14); rect(0, 0, W, h); rect(0, H - h, W, h)
    end
    if doShot then takeShot() end
    if sysOpen and shotPending == 0 then drawSysMenu() end
    drawToast()
end

-- ---------------------------------------------------------------------------
-- Entrees
-- ---------------------------------------------------------------------------
local function showCards(mi, kind, done, sky, lastKey)
    cardMission, cardKind = mi, kind
    if #cardsOf() == 0 then done(); return end
    cardIdx, cardDone = 1, done
    cardLastKey = lastKey or "card_next"
    cardArt = Data.art and Data.art[mi] and Data.art[mi][kind]
    cardT = 0
    skyOverride = sky
    state = "card"
end

local function beginMission(i)
    local m = Data.missions[i]
    showCards(i, "pre", function() startMission(i) end, m.sky, "card_launch")
end

local function backToTitle()
    skyOverride = nil
    titleAnim = 0
    missionIndex = 1
    paused = false
    resetMission()
    buildMenu()
    state = "title"
end

local function afterDebrief()
    local m = mission()
    local nextI = missionIndex + 1
    if nextI > #Data.missions then
        showCards(missionIndex, "post", backToTitle, m.sky, "card_title")
    else
        showCards(missionIndex, "post", function() beginMission(nextI) end, m.sky, "card_nextm")
    end
end

local function toggleMusic()
    Audio.toggleMusic()
    saveSettings()
end

local function confirm(k) return k == "return" or k == "space" end

local function doMenu(it)
    Audio.play("menu")
    if it.act == "continue" then beginMission(Save.next)
    elseif it.act == "new" then state = "instructions"
    elseif it.act == "chapter" then beginMission(it.mission) end
end

local function openSys()
    sysOpen, sysPage, sysSel = true, "main", 1
    Audio.thrust(false)
    Audio.play("menu")
end

local function closeSys() sysOpen = false end

-- Action d'un element du menu systeme.
local function sysAct(id)
    Audio.play("menu")
    if id == "resume" then closeSys()
    elseif id == "controls" then sysPage = "help"
    elseif id == "credits" then sysPage = "credits"
    elseif id == "lang" then I.nextLang(); buildMenu(); saveSettings()
    elseif id == "kb" then I.nextKb(); saveSettings()
    elseif id == "music" then toggleMusic()
    elseif id == "shot" then closeSys(); shotPending = 2
    elseif id == "title" then closeSys(); Audio.thrust(false); backToTitle()
    elseif id == "quit" then
        closeSys()
        if love.event and love.event.quit then pcall(love.event.quit) end
    end
end

local function sysKey(key)
    if sysPage ~= "main" then
        if confirm(key) or key == "x" then sysPage = "main" end
        return
    end
    local items = sysItems()
    if key == "up" then sysSel = sysSel - 1; if sysSel < 1 then sysSel = #items end; Audio.play("menu")
    elseif key == "down" then sysSel = sysSel + 1; if sysSel > #items then sysSel = 1 end; Audio.play("menu")
    elseif key == "left" or key == "right" then
        local it = items[sysSel]
        if it and (it.id == "lang" or it.id == "kb" or it.id == "music") then sysAct(it.id) end
    elseif confirm(key) then
        local it = items[sysSel]; if it then sysAct(it.id) end
    elseif key == "x" then closeSys()
    end
end

function Game.keypressed(key, scancode, isrepeat)
    if key == "f12" then
        if not isrepeat then takeShot() end
        return
    end
    if key == "escape" then
        if not isrepeat and not escDown then escDown = time end
        return
    end
    if sysOpen then sysKey(key); return end
    if key == "x" or key == "m" then toggleMusic(); return end
    if (key == "p" or key == "c") and state == "game" then
        paused = not paused
        Audio.thrust(false)
        return
    end
    if (key == "r" or key == "v") and (state == "game" or state == "debrief") then
        state = "game"; resetMission(); return
    end

    if state == "title" then
        if key == "up" then
            menuSel = menuSel - 1; if menuSel < 1 then menuSel = #menu end; Audio.play("menu")
        elseif key == "down" then
            menuSel = menuSel + 1; if menuSel > #menu then menuSel = 1 end; Audio.play("menu")
        elseif key == "e" and not isrepeat then
            explore.x, explore.t, explore.repaired = 100, 0, false
            state = "explore"
            Audio.play("menu")
        elseif key == "u" then
            Save.unlockAll = true; buildMenu()
        elseif confirm(key) then
            doMenu(menu[menuSel])
        end
    elseif state == "instructions" then
        if confirm(key) then Audio.play("menu"); beginMission(1) end
    elseif state == "card" then
        local cur = cardsOf()[cardIdx]
        if confirm(key) and cur and math.floor(cardT * 70) < #cur[2] then
            cardT = 1000   -- premier appui : affiche tout le texte
        elseif confirm(key) then
            Audio.play("card")
            cardIdx = cardIdx + 1; cardT = 0
            if cardIdx > #cardsOf() then
                local d = cardDone
                cardDone = nil
                d()
            end
        end
    elseif state == "game" then
        if ship.landed and confirm(key) then
            local pts = fuel * 0.5 + hull * 0.5
            lastRank = (pts >= 85 and 4) or (pts >= 70 and 3) or (pts >= 50 and 2) or 1
            local old = tonumber(Save.ranks:sub(missionIndex, missionIndex)) or 0
            if lastRank > old then Save.ranks = Save.ranks:sub(1, missionIndex-1)..lastRank..Save.ranks:sub(missionIndex+1) end
            Save.next = missionIndex + 1
            if Save.next > Save.best then Save.best = Save.next end
            Save.save()
            state = "debrief"
        end
    elseif state == "explore" then
        if confirm(key) then
            if not explore.repaired and explore.x >= 245 and explore.x <= 395 then
                explore.repaired = true
                Audio.play("menu")
            elseif explore.repaired then
                state = "title"
                buildMenu()
            end
        end
    elseif state == "debrief" then
        if confirm(key) then afterDebrief() end
    end
end

-- MENU (Echap) : appui court = menu ; appui long (>= 0,7 s) = capture d'ecran, detecte au relachement.
function Game.keyreleased(key)
    if key ~= "escape" then return end
    local held = escDown and (time - escDown) or 0
    escDown = nil
    if held >= LONG_PRESS then takeShot(); return end
    if sysOpen then
        if sysPage ~= "main" then sysPage = "main" else closeSys() end
    else
        openSys()
    end
end

function Game.focus(focused)
    if not focused and state == "game" then paused = true; Audio.thrust(false) end
end

return Game
