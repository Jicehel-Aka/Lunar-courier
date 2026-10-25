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
    if S.chapter==1 then scene1(g,t,ch) else
    col(g,12,23,45); rect(g,0,270,W,210)
    for i=0,10 do
        local x=i*72-20
        local h=42+((i*37+S.chapter*23)%90)
        col(g,18+(i%3)*4,31+(i%3)*4,52+(i%3)*5)
        g.polygon("fill",x,320,x+34,320-h,x+72,320,x+72,480,x,480)
        col(g,34,58,78); rect(g,x+34,320-h,3,h)
    end
    -- Route de balises : le trait se prolonge pendant le travelling.
    local travel=math.min(1,t/9)
    col(g,ch.accent[1],ch.accent[2],ch.accent[3])
    rect(g,0,340,math.floor(W*travel),3)
    for i=0,5 do
        local x=(i*116+math.floor(t*26))%W
        col(g,255,190,79); rect(g,x,333,4,14)
        col(g, ch.accent[1],ch.accent[2],ch.accent[3]); rect(g,x-4,337,12,3)
    end
    -- Le Courier traverse le cadre, puis ralentit et s'immobilise.
    local u=math.min(1,t/7)
    local sx=-60+u*500
    local sy=215+math.sin(t*1.5)*5
    if S.chapter==3 then sx=120+math.min(1,t/8)*310; sy=220-math.min(1,t/8)*100 end
    g.push(); g.translate(sx,sy); g.scale(1.5,1.5)
    col(g,54,81,100); g.polygon("fill",-22,2,-13,-8,13,-8,22,2,13,9,-13,9)
    col(g,175,205,220); g.polygon("fill",-15,-8,-7,-18,7,-18,15,-8,10,7,-10,7)
    col(g,44,222,226); rect(g,-5,-14,10,6)
    if t<5 then col(g,255,158,58); g.polygon("fill",-5,9,0,24,5,9) end
    g.pop()
    -- Le relais s'eveille ; au chapitre final, le Phare projette sa colonne vers la Terre.
    if S.chapter==2 then
        col(g,36,77,108); rect(g,470,205,12,130); rect(g,440,230,72,5); rect(g,450,258,52,4)
        if t>4 then col(g,255,190,79); rect(g,474,105,4,100); rect(g,462,104,28,3) end
    else
        local beam=math.min(1,math.max(0,(t-5)/4))
        col(g,70,215,225); rect(g,502,28,4,math.floor(270*beam))
        col(g,255,247,213); rect(g,503,28,2,math.floor(270*beam))
        col(g,20,47,70); rect(g,470,300,68,35); rect(g,488,250,32,50)
        col(g,255,190,79); rect(g,498,245,12,8)
        if t>8 then
            col(g,30,90,135); g.circle("fill",125,115,48)
            col(g,50,155,205); g.circle("fill",125,115,40)
            col(g,32,130,130); rect(g,105,93,18,8); rect(g,132,119,22,11); rect(g,95,128,14,8)
        end
    end
    end
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
