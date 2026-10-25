-- Cinematiques de fin de chapitre : animation procedurale, sans images ni alpha.
-- Surface logique 640x480, reduite en 320x240 sur Gamebuino AKA.
local C = {}
local function T(...) return require("src.i18n").t(...) end
local S = {active=false, chapter=1, t=0, nextI=1}
C.s = S

local CH = {
    [1] = {mission=6, sky={4,12,28}, accent={53,215,211}},
    [2] = {mission=12, sky={5,9,24}, accent={255,190,79}},
    [3] = {mission=18, sky={3,8,22}, accent={120,240,225}},
}
function C.start(chapter, nextI)
    S.active, S.chapter, S.t, S.nextI = true, chapter, 0, nextI
end
function C.update(dt)
    if not S.active then return false end
    S.t = S.t + dt
    return S.t >= 18
end
function C.finish()
    S.active = false
    return S.nextI
end
local function rect(g,x,y,w,h) g.rectangle("fill",x,y,w,h) end
local function col(g,r,gc,b) g.setColor(r/255,gc/255,b/255) end

-- Chapitre 1 : un chemin de balises serpente vers l'horizon ; elles s'allument une a une,
-- jusqu'aux grands relais qui se reveillent au pied des montagnes.
local N1 = 20
local HOR = 232
local function pathPt(s)
    local d = (1 - s) ^ 1.8
    local y = HOR + 6 + 148 * d
    local x = 300 + math.sin(s * 6.2 + 0.4) * (150 * d + 10) + 30 * (1 - d) * 0.5
    local w = 6 + 84 * d
    return x, y, w, d
end
local function ell(g, x, y, rx, ry)
    g.polygon("fill", x - rx, y, x - rx*0.7, y - ry*0.7, x, y - ry, x + rx*0.7, y - ry*0.7,
        x + rx, y, x + rx*0.7, y + ry*0.7, x, y + ry, x - rx*0.7, y + ry*0.7)
end
-- pic a deux faces (clair a gauche, ombre a droite) : deux triangles convexes
local function peak(g, x, base, wd, h, lean, c1, c2)
    local px = x + wd * 0.5 + lean
    col(g, c1[1], c1[2], c1[3]); g.polygon("fill", x, base, px, base - h, px, base)
    col(g, c2[1], c2[2], c2[3]); g.polygon("fill", px, base - h, x + wd, base, px, base)
end
local function scene1(g, t, ch)
    local W = 640
    -- ciel en bandes fines, du zenith a l'horizon
    local bands = {{3,6,16},{4,8,20},{5,11,25},{7,14,31},{9,19,39},{12,25,50},{16,33,62},{22,44,78}}
    for i = 1, #bands do col(g, bands[i][1], bands[i][2], bands[i][3]); rect(g, 0, (i-1)*30, W, 30) end
    -- la Terre se leve : halo, globe, continents, croissant d'ombre
    col(g,18,40,74); g.circle("fill",540,184,58)
    col(g,26,62,104); g.circle("fill",540,184,44)
    col(g,34,92,140); g.circle("fill",540,184,36)
    col(g,52,150,200); g.circle("fill",538,182,30)
    col(g,38,128,120); g.polygon("fill",522,168,540,162,546,178,530,186,520,180)
    col(g,38,128,120); g.polygon("fill",544,190,560,186,564,202,552,208)
    col(g,30,70,112); g.polygon("fill",554,162,570,184,552,208)
    -- chaine lointaine, tres haute et pale
    local o1 = math.floor(t * 1.5)
    local far = {{-20,70,38},{40,90,60},{120,80,52},{190,96,72},{280,70,44},{340,110,84},{440,90,56},{520,100,70},{600,80,48}}
    for i = 1, #far do
        peak(g, far[i][1] - o1, HOR - 2, far[i][2] + 30, far[i][3], (i % 2 == 0) and 8 or -6, {26,44,74}, {16,28,52})
    end
    -- chaine moyenne : aretes plus nettes, sommets enneiges
    local o2 = math.floor(t * 3)
    local mid = {{-40,110,44},{50,90,64},{120,130,40},{230,100,58},{310,140,48},{430,110,70},{520,120,42},{590,100,60}}
    for i = 1, #mid do
        local x, wd, h = mid[i][1] - o2, mid[i][2], mid[i][3]
        peak(g, x, HOR + 6, wd, h, (i % 2 == 0) and -10 or 12, {38,62,96}, {22,38,64})
        col(g,150,185,210); g.polygon("fill", x + wd*0.5 + ((i % 2 == 0) and -10 or 12) - 7, HOR + 6 - h + 10, x + wd*0.5 + ((i % 2 == 0) and -10 or 12), HOR + 6 - h, x + wd*0.5 + ((i % 2 == 0) and -10 or 12) + 5, HOR + 6 - h + 7)
    end
    -- collines basses devant les montagnes
    col(g,18,32,54); g.polygon("fill",0,HOR+14,70,HOR-4,150,HOR+14); g.polygon("fill",120,HOR+14,180,HOR+10,260,HOR+14)
    col(g,16,29,50); g.polygon("fill",300,HOR+14,420,HOR-2,520,HOR+14); g.polygon("fill",480,HOR+14,540,HOR+8,600,HOR+14); g.polygon("fill",560,HOR+14,640,HOR-6,640,HOR+14)
    -- sol lunaire en bandes, craters et regolithe
    col(g,17,30,50); rect(g,0,HOR+8,W,62)
    col(g,14,25,43); rect(g,0,HOR+70,W,76)
    col(g,11,20,36); rect(g,0,HOR+146,W,104)
    col(g,9,17,31)
    local cr = {{70,262,34,6},{560,276,40,7},{150,330,56,10},{500,350,64,12},{40,420,70,14},{610,430,60,13}}
    for i = 1, #cr do
        col(g,10,19,34); ell(g, cr[i][1], cr[i][2], cr[i][3], cr[i][4])
        col(g,22,38,60); rect(g, cr[i][1] - cr[i][3], cr[i][2] - 1, math.floor(cr[i][3] * 0.9), 2)
    end
    -- allumage progressif, de la balise proche vers l'horizon
    local travel = math.min(1, math.max(0, (t - 1) / 10))
    -- piste de petites marques au sol entre les balises (suggere le chemin)
    for k = 0, N1 * 2 - 1 do
        local s = (k + 0.5) / (N1 * 2)
        local x, y, w, d = pathPt(s)
        local lit = s < travel
        if lit then col(g,40,150,150) else col(g,38,56,74) end
        rect(g, math.floor(x) - 1, math.floor(y), math.max(1, math.floor(2 + 6 * d)), math.max(1, math.floor(1 + 2 * d)))
    end
    -- balises par paires, de la plus lointaine a la plus proche
    for k = N1 - 1, 0, -1 do
        local s = (k + 0.5) / N1
        local x, y, w, d = pathPt(s)
        local lit = s < travel
        local hh = math.floor(5 + 40 * d)
        local pw = math.max(1, math.floor(1 + 3 * d))
        for side = -1, 1, 2 do
            local bx = math.floor(x + side * (w / 2 + 2 + 8 * d))
            if lit then col(g,22,76,86) else col(g,12,24,38) end
            ell(g, bx + pw / 2, y + 1, 3 + 12 * d, 1 + 3 * d)
            col(g,52,72,90); rect(g, bx, math.floor(y - hh), pw, hh)
            if lit then col(g,255,190,79) else col(g,74,92,108) end
            rect(g, bx - 1, math.floor(y - hh) - pw - 2, pw + 2, pw + 2)
            if lit and d > 0.12 then col(g,255,222,150); rect(g, bx, math.floor(y - hh) - pw - 1, pw, math.max(1, math.floor(pw / 2))) end
        end
    end
    -- grands relais au pied des montagnes : mat, antenne, balise clignotante
    for i = 0, 3 do
        local tx = 70 + i * 150 + ((i * 53) % 40)
        local th = 40 + (i % 2) * 14
        local on = t > 3 + i * 1.6
        local bk = on and (math.floor(t * 3 + i) % 2 == 0)
        col(g,50,70,88); rect(g, tx, HOR - th + 8, 3, th)
        col(g,64,88,106); rect(g, tx - 6, HOR - th + 14, 15, 2)
        col(g,64,88,106); rect(g, tx - 3, HOR - th + 22, 9, 2)
        if on then col(g,80,235,205) else col(g,26,65,83) end
        rect(g, tx - 4, HOR - th + 4, 11, 5)
        if bk then col(g,255,120,90) else col(g,90,50,50) end
        rect(g, tx, HOR - th, 3, 3)
    end
    -- le Courier suit le chemin en s'eloignant ; ombre portee sur le sol
    local u = math.min(1, math.max(0, (t - 0.5) / 9))
    local ss = 0.05 + u * 0.72
    local sx, sy, _, sd = pathPt(ss)
    local sc = 0.7 + 1.5 * sd
    col(g,7,13,24); ell(g, sx, sy + 2, 24 * sc, 4 * sc)
    sy = sy - (50 + 24 * sd) * sc / 1.8 + math.sin(t * 1.7) * 3
    g.push(); g.translate(sx, sy); g.scale(sc, sc)
    col(g,54,81,100); g.polygon("fill",-22,2,-13,-8,13,-8,22,2,13,9,-13,9)
    col(g,175,205,220); g.polygon("fill",-15,-8,-7,-18,7,-18,15,-8,10,7,-10,7)
    col(g,44,222,226); rect(g,-5,-14,10,6)
    if u < 1 then col(g,255,158,58); g.polygon("fill",-5,9,0,18 + math.floor(math.sin(t*20)*3),5,9) end
    g.pop()
    -- avant-plan : rochers sombres et grosse balise a gauche
    col(g,5,10,20); g.polygon("fill",0,480,0,418,34,398,92,424,128,480)
    col(g,5,10,20); g.polygon("fill",640,480,640,408,602,388,548,424,512,480)
    col(g,28,44,60); rect(g,46,300,8,112)
    col(g,40,60,78); rect(g,48,300,2,112)
    local fl = travel > 0.02
    if fl then col(g,255,190,79) else col(g,74,92,108) end
    rect(g,42,286,16,16)
    if fl then col(g,255,224,150); rect(g,46,290,8,5) end
    -- lucioles de balise
    for i = 0, 5 do
        local fx = (i * 103 + math.floor(t * (8 + i * 3))) % W
        local fy = 270 + ((i * 41) % 110) + math.floor(math.sin(t * 2 + i) * 6)
        col(g,255,210,110); rect(g, fx, fy, 2, 2)
    end
end
-- Chapitre 2 : le Courier approche d'un complexe lunaire imposant, dans le noir ; ses lumieres cyan
-- et dorees se rallument peu a peu, et la camera revele son ampleur (il n'est pas abandonne).
-- Chapitre 3 : le Courier rejoint le Phare ; une colonne cyan traverse le ciel, la Terre apparait,
-- et le faisceau relie la Lune a la Terre.
local function smooth(x) x = math.min(1, math.max(0, x)); return x * x * (3 - 2 * x) end
local function ship(g, sx, sy, sc, flame, t)
    g.push(); g.translate(sx, sy); g.scale(sc, sc)
    col(g,54,81,100); g.polygon("fill",-22,2,-13,-8,13,-8,22,2,13,9,-13,9)
    col(g,175,205,220); g.polygon("fill",-15,-8,-7,-18,7,-18,15,-8,10,7,-10,7)
    col(g,44,222,226); rect(g,-5,-14,10,6)
    if flame then col(g,255,158,58); g.polygon("fill",-5,9,0,18 + math.floor(math.sin(t*20)*3),5,9) end
    g.pop()
end
local function stars(g, n, maxy, lift)
    for i = 0, n do
        local x = (i * 137 + 23) % 640; local y = (i * 53 + 9) % maxy
        local br = ((i % 3 == 0) and 200 or 110) + (lift or 0)
        col(g, math.min(255, br), math.min(255, br + 20), math.min(255, br + 30))
        rect(g, x, y, (i % 7 == 0) and 3 or 2, (i % 7 == 0) and 3 or 2)
    end
end
local function ridge(g, t, far1, far2, mid1, mid2, snow, shift, between)
    local far = {{-20,70,38},{40,90,60},{120,80,52},{190,96,72},{280,70,44},{340,110,84},{440,90,56},{520,100,70},{600,80,48}}
    for i = 1, #far do
        local f = far[i]
        peak(g, f[1] + shift, HOR - 2, f[2] + 30, f[3], (i % 2 == 0) and 8 or -6, far1, far2)
    end
    if between then between() end
    local mid = {{-40,110,44},{50,90,64},{120,130,40},{230,100,58},{310,140,48},{430,110,70},{520,120,42},{590,100,60}}
    for i = 1, #mid do
        local x, wd, h = mid[i][1] + shift, mid[i][2], mid[i][3]
        local ln = (i % 2 == 0) and -10 or 12
        peak(g, x, HOR + 6, wd, h, ln, mid1, mid2)
        if snow then
            col(g, snow[1], snow[2], snow[3])
            g.polygon("fill", x + wd*0.5 + ln - 7, HOR + 6 - h + 10, x + wd*0.5 + ln, HOR + 6 - h, x + wd*0.5 + ln + 5, HOR + 6 - h + 7)
        end
    end
end
local function groundBands(g, c1, c2, c3, hill)
    col(g,hill[1],hill[2],hill[3])
    g.polygon("fill",0,HOR+14,80,HOR-2,160,HOR+14); g.polygon("fill",110,HOR+14,190,HOR+8,270,HOR+14)
    g.polygon("fill",330,HOR+14,430,HOR-4,520,HOR+14); g.polygon("fill",560,HOR+14,620,HOR+2,640,HOR+14)
    col(g,c1[1],c1[2],c1[3]); rect(g,0,HOR+8,640,62)
    col(g,c2[1],c2[2],c2[3]); rect(g,0,HOR+70,640,76)
    col(g,c3[1],c3[2],c3[3]); rect(g,0,HOR+146,640,104)
end
local function foreground(g)
    col(g,4,8,16); g.polygon("fill",0,480,0,418,34,398,92,424,128,480)
    col(g,4,8,16); g.polygon("fill",640,480,640,408,602,388,548,424,512,480)
end

local function scene2(g, t, ch)
    local lift = smooth((t - 2) / 12)                 -- la camera se leve : le complexe grandit
    local z = 0.7 + 0.55 * lift
    local bands = {{2,3,9},{3,5,13},{4,7,17},{5,9,21},{6,11,25},{8,14,30},{10,18,36},{12,22,42}}
    for i = 1, #bands do col(g, bands[i][1], bands[i][2], bands[i][3]); rect(g, 0, (i-1)*30, 640, 30) end
    stars(g, 40, HOR - 30, 0)
    -- petite Terre lointaine
    col(g,20,30,60); g.circle("fill",96,176,30); col(g,36,80,124); g.circle("fill",96,176,22)
    ridge(g, t, {20,26,44}, {12,16,30}, {26,34,56}, {14,20,36}, nil, 0)
    groundBands(g, {16,20,32}, {12,16,27}, {9,12,22}, {18,24,38})
    -- le complexe : dessine en coordonnees locales (origine au pied, y vers le haut = negatif)
    local ox, oy = 320, 352
    local on = function(i) return t > 2.5 + i * 0.16 end
    g.push(); g.translate(ox, oy); g.scale(z, z)
    -- lueur au sol
    if t > 7 then col(g,10,40,52); ell(g, 0, 4, 190, 12) end
    -- ailes et tours laterales
    col(g,22,32,52); rect(g,-134,-40,100,40); rect(g,34,-40,100,40)
    col(g,28,40,62); rect(g,-164,-72,20,72); rect(g,144,-72,20,72)
    col(g,34,48,72); rect(g,-158,-90,8,18); rect(g,150,-90,8,18)
    -- paraboles sur les ailes
    col(g,38,54,80); g.polygon("fill",-110,-40,-100,-62,-70,-62,-60,-40)
    g.polygon("fill",60,-40,70,-56,100,-56,110,-40)
    -- tour centrale massive
    col(g,18,28,48); g.polygon("fill",-36,0,-24,-112,24,-112,36,0)
    col(g,26,40,64); g.polygon("fill",-36,0,-24,-112,-8,-112,-8,0)
    col(g,24,36,58); rect(g,-30,-134,60,22)
    col(g,34,50,76); rect(g,-34,-136,68,4)
    -- fenetres : tour (3 par rangee) puis ailes, qui s'allument de bas en haut et du centre vers les cotes
    local idx = 0
    for r = 0, 6 do
        for c = -1, 1 do
            idx = idx + 1
            local lit = on(r * 3 + math.abs(c))
            if lit then if (r + c) % 2 == 0 then col(g,70,235,225) else col(g,255,200,100) end else col(g,28,40,60) end
            rect(g, c * 14 - 3, -104 + r * 14, 6, 6)
        end
    end
    for side = -1, 1, 2 do
        for r = 0, 1 do
            for c = 0, 6 do
                local lit = on(8 + c * 2 + r)
                if lit then if (c + r) % 2 == 0 then col(g,255,200,100) else col(g,70,235,225) end else col(g,28,40,60) end
                rect(g, side * (44 + c * 13) - 3, -32 + r * 14, 6, 6)
            end
        end
        for r = 0, 3 do
            local lit = on(22 + r)
            if lit then col(g,70,235,225) else col(g,28,40,60) end
            rect(g, side * 154 - 3, -64 + r * 14, 6, 5)
        end
    end
    -- arêtes lumineuses
    if t > 6 then col(g,50,170,175); rect(g,-36,-137,72,2); rect(g,-166,-73,24,2); rect(g,142,-73,24,2) end
    -- noyau : l'oeil du complexe, qui s'eveille en dernier
    local core = smooth((t - 9) / 3)
    col(g,28,44,66); g.polygon("fill",-16,-146,-10,-160,10,-160,16,-146,10,-132,-10,-132)
    if core > 0 then
        local pul = 1 + 0.12 * math.sin(t * 4)
        col(g,20,90,110); g.circle("fill",0,-146,math.floor(22 * core * pul))
        col(g,60,215,225); g.circle("fill",0,-146,math.floor(14 * core * pul))
        col(g,235,252,255); g.circle("fill",0,-146,math.floor(5 * core))
        col(g,255,190,79); rect(g,-2,-160 - 30 * core, 4, 30 * core)
    end
    g.pop()
    -- chemin de balises dorees jusqu'au pied du complexe (premier plan -> fond)
    local travel = math.min(1, math.max(0, (t - 1) / 9))
    for k = 11, 0, -1 do
        local s = (k + 0.5) / 12
        local d = (1 - s) ^ 1.6
        local y = 356 + 110 * d
        local x = 320 + math.sin(s * 5 + 0.6) * (50 * d + 4)
        local w = 6 + 120 * d
        local hh = math.floor(5 + 36 * d)
        local pw = math.max(1, math.floor(1 + 3 * d))
        local lit = s < travel
        for side = -1, 1, 2 do
            local bx = math.floor(x + side * (w / 2))
            col(g,48,60,78); rect(g, bx, math.floor(y - hh), pw, hh)
            if lit then col(g,255,190,79) else col(g,70,84,100) end
            rect(g, bx - 1, math.floor(y - hh) - pw - 2, pw + 2, pw + 2)
        end
    end
    -- le Courier approche, de plus en plus petit face a la structure
    local u = smooth((t - 0.5) / 12)
    local sc = 1.6 - 0.7 * u
    ship(g, 230 + 90 * u, 440 - 80 * u + math.sin(t * 1.7) * 3, sc, u < 1, t)
    foreground(g)
end

local function scene3(g, t, ch)
    local f = smooth((t - 5) / 6) * 0.55             -- le ciel s'eclaire quand la colonne s'allume
    local bands = {{2,4,12},{3,7,18},{4,10,24},{6,14,32},{8,20,42},{10,28,54},{14,38,70},{20,52,88}}
    local tg = {{14,40,60},{18,56,80},{22,70,96},{28,86,112},{34,100,126},{40,112,138},{46,124,150},{52,136,162}}
    for i = 1, #bands do
        local b, tt = bands[i], tg[i]
        col(g, b[1] + (tt[1] - b[1]) * f, b[2] + (tt[2] - b[2]) * f, b[3] + (tt[3] - b[3]) * f)
        rect(g, 0, (i-1)*30, 640, 30)
    end
    stars(g, 34, HOR - 30, 0)
    local e = smooth((t - 2) / 7)
    local ex, ey = 500, 292 - 100 * e
    local rr = 8 + 40 * e
    local function earth()
    if e > 0 then
        if t > 11 then local a = smooth((t - 11) / 3); col(g,30,100,130); g.circle("fill",ex,ey,math.floor(rr * (1.3 + 0.35 * a))); col(g,24,76,112); g.circle("fill",ex,ey,math.floor(rr * (1.2 + 0.15 * a))) end
        col(g,14,34,66); g.circle("fill",ex,ey,math.floor(rr * 1.12))
        col(g,22,56,98); g.circle("fill",ex,ey,math.floor(rr * 1.06))
        col(g,52,150,200); g.circle("fill",ex,ey,math.floor(rr))
        col(g,38,128,120); g.polygon("fill",ex - rr * 0.6,ey - rr * 0.3,ex - rr * 0.1,ey - rr * 0.6,ex + rr * 0.1,ey - rr * 0.1,ex - rr * 0.4,ey + rr * 0.2)
        col(g,38,128,120); g.polygon("fill",ex + rr * 0.1,ey + rr * 0.2,ex + rr * 0.5,ey + rr * 0.1,ex + rr * 0.4,ey + rr * 0.6,ex + rr * 0.1,ey + rr * 0.5)
        if t > 11 then
            -- la Terre repond : lumieres de villes
            col(g,255,214,120)
            for i = 0, 6 do rect(g, ex - rr * 0.5 + (i * 29) % math.floor(rr * 1.1), ey - rr * 0.5 + (i * 17) % math.floor(rr * 1.1), 2, 2) end
        end
    end
    end
    ridge(g, t, {24,42,72}, {14,26,50}, {34,60,96}, {18,34,62}, {170,210,235}, 0, earth)
    groundBands(g, {14,26,46}, {11,21,38}, {8,16,30}, {14,26,46})
    -- chemin de balises turquoise vers le Phare
    local px, ph, amp = 250, 3.4, 130
    local function P(s)
        local d = (1 - s) ^ 1.8
        return px + math.sin(s * 5.6 + ph) * (amp * d + 8), HOR + 6 + 148 * d, 6 + 80 * d, d
    end
    local travel = math.min(1, math.max(0, (t - 1) / 9))
    for k = 19, 0, -1 do
        local s = (k + 0.5) / 20
        local x, y, w, d = P(s)
        local hh = math.floor(5 + 40 * d)
        local pw = math.max(1, math.floor(1 + 3 * d))
        local lit = s < travel
        for side = -1, 1, 2 do
            local bx = math.floor(x + side * (w / 2 + 2 + 8 * d))
            if lit then col(g,20,70,76) else col(g,12,20,32) end
            ell(g, bx + pw / 2, y + 1, 3 + 12 * d, 1 + 3 * d)
            col(g,52,66,84); rect(g, bx, math.floor(y - hh), pw, hh)
            if lit then col(g,70,235,225) else col(g,74,88,104) end
            rect(g, bx - 1, math.floor(y - hh) - pw - 2, pw + 2, pw + 2)
        end
    end
    -- le Phare : socle, fut raye, lanterne
    local tx, ty = P(1)
    local top = HOR - 82
    col(g,18,34,54); rect(g, tx - 34, HOR - 4, 68, 16)
    col(g,26,46,70); g.polygon("fill", tx - 20, HOR - 4, tx - 9, top, tx + 9, top, tx + 20, HOR - 4)
    col(g,60,90,116); rect(g, tx - 17, HOR - 26, 34, 5); rect(g, tx - 13, HOR - 52, 26, 5)
    col(g,40,66,92); rect(g, tx - 13, top - 4, 26, 5)
    local col_on = t > 4
    if col_on then col(g,255,247,213) else col(g,255,190,79) end
    rect(g, tx - 8, top - 16, 16, 12)
    -- la colonne lumineuse monte, large, avec des impulsions
    local cg = smooth((t - 4) / 4)
    if cg > 0 then
        local h = math.floor((top - 16) * cg)
        col(g,40,150,170); rect(g, tx - 11, top - 16 - h, 22, h)
        col(g,70,215,225); rect(g, tx - 7, top - 16 - h, 14, h)
        col(g,255,247,213); rect(g, tx - 3, top - 16 - h, 6, h)
        for i = 0, 3 do
            local yy = top - 16 - ((t * 90 + i * 60) % math.max(1, h))
            col(g,235,252,255); rect(g, tx - 13, yy, 26, 3)
        end
    end
    -- faisceau vers la Terre : quadrilatere convexe + impulsions qui voyagent
    local bm = smooth((t - 8) / 3)
    if bm > 0 then
        local ax, ay = tx, top - 10
        local bx, by = ax + (ex - ax) * bm, ay + (ey - ay) * bm
        col(g,70,215,225); g.polygon("fill", ax - 6, ay, ax + 6, ay, bx + 3, by, bx - 3, by)
        col(g,255,247,213); g.polygon("fill", ax - 2, ay, ax + 2, ay, bx + 1, by, bx - 1, by)
        for i = 0, 4 do
            local p = ((t * 0.5 + i * 0.2) % 1) * bm
            col(g,255,255,255); rect(g, ax + (ex - ax) * p - 3, ay + (ey - ay) * p - 3, 6, 6)
        end
    end
    -- le Courier rejoint la zone du Phare et se pose a son pied
    local u = smooth((t - 0.5) / 9)
    local sx, sy, _, sd = P(0.05 + u * 0.85)
    local sc = 0.7 + 1.5 * sd
    col(g,6,10,20); ell(g, sx, sy + 2, 24 * sc, 4 * sc)
    sy = sy - (50 + 24 * sd) * sc / 1.8 + math.sin(t * 1.7) * 3
    ship(g, sx, sy, sc, u < 1, t)
    foreground(g)
end
local function scene23(g, t, ch, which)
    if which == 2 then scene2(g, t, ch) else scene3(g, t, ch) end
end
function C.draw(ui, lang, prompt)
    local g, t, ch = love.graphics, S.t, CH[S.chapter] or CH[1]
    local W,H=640,480
    col(g,3,7,18); rect(g,0,0,W,H)
    -- Horizon lumineux, etoiles et montagnes a facettes.
    for i=0,27 do
        local x=(i*137+19)%W; local y=(i*71+11)%330
        col(g, i%4==0 and 95 or 30, i%4==0 and 190 or 70, i%4==0 and 210 or 110)
        rect(g,x,y, i%5==0 and 4 or 2, i%5==0 and 4 or 2)
    end
    if S.chapter==1 then scene1(g,t,ch) else scene23(g,t,ch,S.chapter) end
    -- Cartouche et progression en trois temps.
    col(g,3,12,27); rect(g,36,34,568,104)
    col(g,ch.accent[1],ch.accent[2],ch.accent[3]); rect(g,36,34,568,3); rect(g,36,135,568,2)
    g.setFont(ui.f32); col(g,235,244,248); g.printf(T("ci_chap", S.chapter),52,47,536,"center")
    g.setFont(ui.f24); col(g,ch.accent[1],ch.accent[2],ch.accent[3]); g.printf(T("ci_s"..S.chapter),52,91,536,"center")
    if t>3 then
        col(g,3,12,27); rect(g,84,386,472,46)
        col(g,ch.accent[1],ch.accent[2],ch.accent[3]); rect(g,84,386,math.floor(472*math.min(1,t/18)),2)
        g.setFont(ui.f16); col(g,205,222,231); g.printf(T(t<7 and "ci_p1" or (t<13 and "ci_p2" or "ci_p3")),96,402,448,"center")
    end
    if t>=5 then
        g.setFont(ui.f16); col(g,255,190,79); g.printf(prompt,40,448,560,"center")
    end
end
return C
