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

-- Chapitre 1 : route de balises sinueuse en perspective, qui s'allume peu a peu, relais a l'horizon.
local N1 = 22
local function roadPt(s)
    local d = (1 - s) ^ 1.6
    local y = 210 + 172 * d
    local x = 330 + math.sin(s * 5.4 + 0.5) * (170 * d + 14) - 40 * s
    local w = 8 + 100 * d
    return x, y, w, d
end
local function scene1(g, t, ch)
    local W = 640
    local ar, ag, ab = ch.accent[1], ch.accent[2], ch.accent[3]
    -- ciel en bandes, du zenith a l'horizon
    local bands = {{3,7,18},{4,10,24},{6,14,31},{8,19,40},{11,25,50},{15,33,62}}
    for i = 1, #bands do col(g, bands[i][1], bands[i][2], bands[i][3]); rect(g, 0, (i-1)*35, W, 35) end
    -- la Terre se leve a droite
    col(g,30,90,135); g.circle("fill",560,170,28)
    col(g,50,155,205); g.circle("fill",560,170,22)
    col(g,32,130,130); rect(g,550,162,10,5); rect(g,563,172,12,7)
    -- montagnes lointaines (defilement lent), puis plus proches
    local off = (t * 5) % 160
    for i = -1, 5 do
        local x = i * 160 - off
        local h = 22 + ((i + 3) * 29) % 28
        col(g,17,30,52); g.polygon("fill",x,210,x+80,210-h,x+160,210)
    end
    local off2 = (t * 11) % 120
    for i = -1, 6 do
        local x = i * 120 - off2
        local h = 14 + ((i + 5) * 37) % 24
        col(g,22,38,62); g.polygon("fill",x,214,x+60,214-h,x+120,214)
        col(g,36,60,82); rect(g,x+60,214-h,2,h)
    end
    -- sol lunaire
    col(g,14,25,44); rect(g,0,210,W,90)
    col(g,11,20,37); rect(g,0,300,W,90)
    col(g,8,15,29); rect(g,0,390,W,90)
    -- la route : trapezes successifs (bords horizontaux, donc convexes)
    local travel = math.min(1, math.max(0, (t - 1) / 9))
    for k = N1 - 1, 0, -1 do
        local x0, y0, w0 = roadPt(k / N1)
        local x1, y1, w1 = roadPt((k + 1) / N1)
        if k % 2 == 0 then col(g,26,41,58) else col(g,31,48,68) end
        g.polygon("fill", x0 - w0/2, y0, x0 + w0/2, y0, x1 + w1/2, y1, x1 - w1/2, y1)
        if k % 2 == 0 then
            local lit = (k / N1) < travel
            if lit then col(g,ar,ag,ab) else col(g,60,86,104) end
            local dw = math.max(1, w0 * 0.05)
            g.polygon("fill", x0 - dw, y0, x0 + dw, y0, x1 + dw*0.6, y1, x1 - dw*0.6, y1)
        end
    end
    -- balises de bord : s'allument de la plus proche a la plus lointaine
    for k = 0, N1 - 1 do
        local x, y, w, d = roadPt((k + 0.5) / N1)
        local lit = ((k + 0.5) / N1) < travel
        local hh = math.max(2, math.floor(4 + 34 * d))
        local pw = math.max(1, math.floor(1 + 3 * d))
        for side = -1, 1, 2 do
            local bx = x + side * (w / 2 + 3 + 6 * d)
            col(g,40,60,76); rect(g, math.floor(bx), math.floor(y - hh), pw, hh)
            if lit then col(g,255,190,79) else col(g,70,90,104) end
            rect(g, math.floor(bx) - 1, math.floor(y - hh) - pw - 1, pw + 2, pw + 2)
        end
    end
    -- relais de l'horizon : un par balise principale, qui s'allume a son tour
    for i = 0, 5 do
        local s = 0.14 + i * 0.13
        local x, y, w, d = roadPt(s)
        local side = (i % 2 == 0) and -1 or 1
        local tx = x + side * (w / 2 + 40 + 60 * d)
        local th = math.floor(16 + 70 * d)
        local on = t > 2 + i * 1.2
        if on then col(g,80,235,205) else col(g,26,65,83) end
        rect(g, math.floor(tx), math.floor(y - th), math.max(3, math.floor(10 * d + 3)), th)
        rect(g, math.floor(tx) - 3, math.floor(y - th) - 4, math.max(8, math.floor(18 * d + 8)), 4)
    end
    -- le Courier suit la route en s'eloignant, puis se pose au loin en vol stationnaire
    local u = math.min(1, math.max(0, (t - 0.5) / 8))
    local ss = 0.04 + u * 0.7
    local sx, sy, _, sd = roadPt(ss)
    local sc = 0.8 + 1.3 * sd
    sy = sy - (60 + 20 * sd) * sc / 1.8 + math.sin(t * 1.7) * 3
    g.push(); g.translate(sx, sy); g.scale(sc, sc)
    col(g,54,81,100); g.polygon("fill",-22,2,-13,-8,13,-8,22,2,13,9,-13,9)
    col(g,175,205,220); g.polygon("fill",-15,-8,-7,-18,7,-18,15,-8,10,7,-10,7)
    col(g,44,222,226); rect(g,-5,-14,10,6)
    if u < 1 then col(g,255,158,58); g.polygon("fill",-5,9,0,18 + math.floor(math.sin(t*20)*3),5,9) end
    g.pop()
    -- avant-plan : rochers sombres de chaque cote
    col(g,5,10,20); g.polygon("fill",0,480,0,410,38,392,86,420,120,480)
    col(g,5,10,20); g.polygon("fill",640,480,640,400,598,380,540,418,508,480)
    col(g,12,22,38); rect(g,38,392,2,10)
    -- lucioles de balise : de petits points qui flottent au-dessus de la route
    for i = 0, 7 do
        local fx = (i * 83 + math.floor(t * (10 + i * 3))) % W
        local fy = 250 + ((i * 37) % 110) + math.floor(math.sin(t * 2 + i) * 6)
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
