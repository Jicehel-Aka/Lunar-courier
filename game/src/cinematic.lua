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
-- Chapitres 2 et 3 : meme principe que le chapitre 1 (chemin de balises, montagnes a facettes),
-- mais un decor propre : base de Varga au crepuscule (2), Phare face a la Terre dans la nuit (3).
local function pathPt2(s, ph, endx, amp)
    local d = (1 - s) ^ 1.8
    local y = HOR + 6 + 148 * d
    local x = endx + math.sin(s * 5.6 + ph) * (amp * d + 8)
    local w = 6 + 80 * d
    return x, y, w, d
end
local function ship(g, sx, sy, sc, flame, t)
    g.push(); g.translate(sx, sy); g.scale(sc, sc)
    col(g,54,81,100); g.polygon("fill",-22,2,-13,-8,13,-8,22,2,13,9,-13,9)
    col(g,175,205,220); g.polygon("fill",-15,-8,-7,-18,7,-18,15,-8,10,7,-10,7)
    col(g,44,222,226); rect(g,-5,-14,10,6)
    if flame then col(g,255,158,58); g.polygon("fill",-5,9,0,18 + math.floor(math.sin(t*20)*3),5,9) end
    g.pop()
end
local function scene23(g, t, ch, which)
    local W = 640
    local ar, ag, ab = ch.accent[1], ch.accent[2], ch.accent[3]
    local bands, pal
    if which == 2 then
        bands = {{4,7,18},{8,10,26},{16,14,34},{30,20,40},{52,30,44},{84,48,50},{124,72,56},{168,102,64}}
        pal = {far={{52,44,70},{34,30,52}}, mid={{70,52,80},{40,32,60}}, snow={230,170,150}, ground={{36,28,44},{28,22,36},{21,17,29}}, hill={34,26,42}}
    else
        bands = {{2,4,12},{3,7,18},{4,10,24},{6,14,32},{8,20,42},{10,28,54},{14,38,70},{20,52,88}}
        pal = {far={{24,42,72},{14,26,50}}, mid={{34,60,96},{18,34,62}}, snow={170,210,235}, ground={{14,26,46},{11,21,38},{8,16,30}}, hill={14,26,46}}
    end
    for i = 1, #bands do col(g, bands[i][1], bands[i][2], bands[i][3]); rect(g, 0, (i-1)*30, W, 30) end
    -- etoiles
    for i = 0, 34 do
        local x = (i * 137 + 23) % W; local y = (i * 53 + 9) % (HOR - 30)
        local br = (i % 3 == 0) and 200 or 110
        col(g, br, br + 20, br + 30); rect(g, x, y, (i % 7 == 0) and 3 or 2, (i % 7 == 0) and 3 or 2)
    end
    -- la Terre : petite et haute au chapitre 2, grande et basse a gauche au chapitre 3
    if which == 2 then
        col(g,30,40,80); g.circle("fill",96,176,36)
        col(g,52,110,170); g.circle("fill",96,176,27)
        col(g,34,110,110); g.polygon("fill",84,164,98,158,104,172,90,178)
        col(g,22,50,100); g.polygon("fill",108,162,118,176,106,194,98,190)
    else
        col(g,14,34,66); g.circle("fill",112,214,74)
        col(g,22,56,98); g.circle("fill",112,214,60)
        col(g,34,92,140); g.circle("fill",112,214,50)
        col(g,52,150,200); g.circle("fill",110,212,42)
        col(g,38,128,120); g.polygon("fill",90,192,112,184,122,206,100,216,88,206)
        col(g,38,128,120); g.polygon("fill",122,224,142,218,146,238,130,244)
        col(g,30,70,112); g.polygon("fill",138,184,154,214,138,252)
    end
    -- montagnes : chaine lointaine puis chaine moyenne a sommets clairs
    local far = {{-20,70,38},{40,90,60},{120,80,52},{190,96,72},{280,70,44},{340,110,84},{440,90,56},{520,100,70},{600,80,48}}
    local o1 = math.floor(t * 1.5)
    for i = 1, #far do
        local f = far[i]
        local h = (which == 3) and f[3] + 14 or f[3]
        peak(g, f[1] - o1 + ((which == 3) and 20 or 0), HOR - 2, f[2] + 30, h, (i % 2 == 0) and 8 or -6, pal.far[1], pal.far[2])
    end
    local mid = {{-40,110,44},{50,90,64},{120,130,40},{230,100,58},{310,140,48},{430,110,70},{520,120,42},{590,100,60}}
    local o2 = math.floor(t * 3)
    for i = 1, #mid do
        local x, wd, h = mid[i][1] - o2 + ((which == 3) and 30 or 0), mid[i][2], mid[i][3]
        local ln = (i % 2 == 0) and -10 or 12
        peak(g, x, HOR + 6, wd, h, ln, pal.mid[1], pal.mid[2])
        col(g, pal.snow[1], pal.snow[2], pal.snow[3])
        g.polygon("fill", x + wd*0.5 + ln - 7, HOR + 6 - h + 10, x + wd*0.5 + ln, HOR + 6 - h, x + wd*0.5 + ln + 5, HOR + 6 - h + 7)
    end
    col(g,pal.hill[1],pal.hill[2],pal.hill[3])
    g.polygon("fill",0,HOR+14,80,HOR-2,160,HOR+14); g.polygon("fill",110,HOR+14,190,HOR+8,270,HOR+14)
    g.polygon("fill",330,HOR+14,430,HOR-4,520,HOR+14); g.polygon("fill",560,HOR+14,620,HOR+2,640,HOR+14)
    -- sol
    col(g,pal.ground[1][1],pal.ground[1][2],pal.ground[1][3]); rect(g,0,HOR+8,W,62)
    col(g,pal.ground[2][1],pal.ground[2][2],pal.ground[2][3]); rect(g,0,HOR+70,W,76)
    col(g,pal.ground[3][1],pal.ground[3][2],pal.ground[3][3]); rect(g,0,HOR+146,W,104)
    local cr = {{70,262,34,6},{570,278,40,7},{150,334,56,10},{520,352,64,12},{44,420,70,14},{600,432,60,13}}
    for i = 1, #cr do
        col(g,pal.ground[3][1] + 2,pal.ground[3][2] + 3,pal.ground[3][3] + 4); ell(g, cr[i][1], cr[i][2], cr[i][3], cr[i][4])
    end
    -- chemin : tracé different par chapitre
    local ph, endx, amp = 1.2, 440, 150
    if which == 3 then ph, endx, amp = 3.4, 380, 140 end
    local travel = math.min(1, math.max(0, (t - 1) / 10))
    for k = 0, 2 * 20 - 1 do
        local s = (k + 0.5) / 40
        local x, y, w, d = pathPt2(s, ph, endx, amp)
        if s < travel then col(g,ar * 0.4,ag * 0.4,ab * 0.4) else col(g,40,50,66) end
        rect(g, math.floor(x) - 1, math.floor(y), math.max(1, math.floor(2 + 6 * d)), math.max(1, math.floor(1 + 2 * d)))
    end
    for k = 19, 0, -1 do
        local s = (k + 0.5) / 20
        local x, y, w, d = pathPt2(s, ph, endx, amp)
        local lit = s < travel
        local hh = math.floor(5 + 40 * d)
        local pw = math.max(1, math.floor(1 + 3 * d))
        for side = -1, 1, 2 do
            local bx = math.floor(x + side * (w / 2 + 2 + 8 * d))
            if lit then col(g,ar * 0.3,ag * 0.3,ab * 0.3) else col(g,12,20,32) end
            ell(g, bx + pw / 2, y + 1, 3 + 12 * d, 1 + 3 * d)
            col(g,52,66,84); rect(g, bx, math.floor(y - hh), pw, hh)
            if lit then col(g,ar,ag,ab) else col(g,74,88,104) end
            rect(g, bx - 1, math.floor(y - hh) - pw - 2, pw + 2, pw + 2)
        end
    end
    -- point d'arrivee : base de Varga (2) ou Phare (3), au bout du chemin
    local ex, ey = pathPt2(1, ph, endx, amp)
    local lit = t > 6
    if which == 2 then
        col(g,40,36,60); rect(g, ex + 40, HOR - 70, 6, 80)
        col(g,56,52,80); rect(g, ex + 30, HOR - 50, 26, 3); rect(g, ex + 34, HOR - 32, 18, 3)
        col(g,52,46,74); g.polygon("fill", ex - 40, HOR + 8, ex - 32, HOR - 6, ex - 8, HOR - 12, ex + 8, HOR - 6, ex + 16, HOR + 8)
        col(g,44,38,64); g.polygon("fill", ex + 60, HOR + 8, ex + 66, HOR - 2, ex + 84, HOR - 6, ex + 96, HOR + 8)
        col(g,40,36,60); rect(g, ex - 52, HOR - 2, 12, 10); rect(g, ex + 16, HOR + 2, 22, 6)
        for i = 0, 4 do
            if lit and (i + math.floor(t * 2)) % 5 ~= 0 then col(g,255,200,100) else col(g,70,60,70) end
            rect(g, ex - 32 + i * 9, HOR - 4, 4, 4)
        end
        if lit then col(g,255,190,79) else col(g,90,70,70) end
        rect(g, ex + 38, HOR - 76, 10, 6)
        if lit then
            local bm = math.min(1, (t - 6) / 3)
            col(g,255,170,70); rect(g, ex + 41, HOR - 76 - math.floor(70 * bm), 4, math.floor(70 * bm))
            col(g,255,236,180); rect(g, ex + 42, HOR - 76 - math.floor(70 * bm), 2, math.floor(70 * bm))
        end
    else
        col(g,20,38,60); rect(g, ex - 26, HOR - 6, 52, 14)
        col(g,28,50,76); g.polygon("fill", ex - 14, HOR - 6, ex - 8, HOR - 70, ex + 8, HOR - 70, ex + 14, HOR - 6)
        col(g,40,66,92); rect(g, ex - 12, HOR - 36, 24, 3); rect(g, ex - 10, HOR - 56, 20, 3)
        col(g,255,190,79); rect(g, ex - 8, HOR - 80, 16, 10)
        local bm = math.min(1, math.max(0, (t - 5) / 4))
        if bm > 0 then
            -- faisceau vers la Terre : quadrilatere convexe qui s'etire
            local tx, ty = ex, HOR - 76
            local ex2, ey2 = tx + (150 - tx) * bm, ty + (200 - ty) * bm
            col(g,70,215,225); g.polygon("fill", tx - 5, ty, tx + 5, ty, ex2 + 2, ey2, ex2 - 2, ey2)
            col(g,255,247,213); g.polygon("fill", tx - 2, ty, tx + 2, ty, ex2 + 1, ey2, ex2 - 1, ey2)
        end
    end
    -- le Courier suit le chemin
    local u = math.min(1, math.max(0, (t - 0.5) / 9))
    local ss = 0.05 + u * 0.8
    local sx, sy, _, sd = pathPt2(ss, ph, endx, amp)
    local sc = 0.7 + 1.5 * sd
    col(g,6,10,20); ell(g, sx, sy + 2, 24 * sc, 4 * sc)
    sy = sy - (50 + 24 * sd) * sc / 1.8 + math.sin(t * 1.7) * 3
    ship(g, sx, sy, sc, u < 1, t)
    -- avant-plan : rochers et grosse balise
    col(g,4,8,16); g.polygon("fill",0,480,0,418,34,398,92,424,128,480)
    col(g,4,8,16); g.polygon("fill",640,480,640,408,602,388,548,424,512,480)
    col(g,28,40,58); rect(g,596,300,8,112)
    if travel > 0.02 then col(g,ar,ag,ab) else col(g,74,88,104) end
    rect(g,592,286,16,16)
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
