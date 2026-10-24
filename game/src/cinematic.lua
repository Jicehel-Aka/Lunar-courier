-- Cinematiques de fin de chapitre : animation procedurale, sans images ni alpha.
-- Surface logique 640x480, reduite en 320x240 sur Gamebuino AKA.
local C = {}
local S = {active=false, chapter=1, t=0, nextI=1}
C.s = S

local CH = {
    [1] = {mission=6, title="CHAPITRE 1", sub="LA LUNE SE REVEILLE", sky={4,12,28}, accent={53,215,211}},
    [2] = {mission=12, title="CHAPITRE 2", sub="LE RETOUR DE VARGA", sky={5,9,24}, accent={255,190,79}},
    [3] = {mission=18, title="CHAPITRE 3", sub="LA DERNIERE LUMIERE", sky={3,8,22}, accent={120,240,225}},
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
    if S.chapter==1 then
        for i=0,5 do
            local x=90+i*88; local on=t>2+i*1.2
            col(g,on and 80 or 26,on and 235 or 65,on and 205 or 83)
            rect(g,x,303,12,24); rect(g,x-5,299,22,4)
        end
    elseif S.chapter==2 then
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
    -- Cartouche et progression en trois temps.
    col(g,3,12,27); rect(g,36,34,568,104)
    col(g,ch.accent[1],ch.accent[2],ch.accent[3]); rect(g,36,34,568,3); rect(g,36,135,568,2)
    g.setFont(ui.f32); col(g,235,244,248); g.printf(ch.title,52,47,536,"center")
    g.setFont(ui.f24); col(g,ch.accent[1],ch.accent[2],ch.accent[3]); g.printf(ch.sub,52,91,536,"center")
    if t>3 then
        col(g,3,12,27); rect(g,84,386,472,46)
        col(g,ch.accent[1],ch.accent[2],ch.accent[3]); rect(g,84,386,math.floor(472*math.min(1,t/18)),2)
        g.setFont(ui.f16); col(g,205,222,231); g.printf(t<7 and "LA ROUTE S'ALLUME..." or (t<13 and "LE VOYAGE CONTINUE" or "UNE NOUVELLE AUBE"),96,402,448,"center")
    end
    if t>=5 then
        g.setFont(ui.f16); col(g,255,190,79); g.printf(prompt,40,448,560,"center")
    end
end
return C
