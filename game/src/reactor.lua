-- M5 - Le Coeur silencieux : insertion du module et synchronisation de phase.
local R = {}
local function T(...) return require("src.i18n").t(...) end
local st
local TARGET = {1, 3, 2}
local LETTERS = {"A", "B", "C"}
function R.reset()
    st = {x=58, facing=1, inserted=false, console=false, phase={0,0,0},
          selected=1, solved=false, t=0, message=T("r_msg0"),
          msgT=8, flash=0}
end
function R.update(dt, left, right)
    if not st then R.reset() end
    -- Marche continue tant que la touche est maintenue ; l'animation ne tourne qu'en mouvement.
    local moving=false
    if not st.console and not st.solved then
        local old=st.x
        if left and not right then st.x=math.max(42,st.x-145*dt); st.facing=-1
        elseif right and not left then st.x=math.min(598,st.x+145*dt); st.facing=1 end
        moving=st.x~=old
    end
    st.walkT=moving and ((st.walkT or 0)+dt*10) or 0
    st.t=st.t+dt; st.msgT=math.max(0,st.msgT-dt); st.flash=math.max(0,st.flash-dt)
    if st.solved then st.doneT=(st.doneT or 0)+dt end
    return st.solved and st.doneT>2.8
end
local function say(s,d) st.message,st.msgT=s,d or 3 end
function R.keypressed(key,isrepeat)
    if not st then R.reset() end
    if st.solved then return nil end
    if st.console then
        if key=="left" or key=="q" then st.selected=st.selected-1; if st.selected<1 then st.selected=3 end
        elseif key=="right" or key=="d" then st.selected=st.selected+1; if st.selected>3 then st.selected=1 end
        elseif key=="up" or key=="z" then st.phase[st.selected]=(st.phase[st.selected]+1)%4
        elseif key=="down" or key=="s" then st.phase[st.selected]=(st.phase[st.selected]+3)%4
        elseif key=="e" or key=="a" or key=="return" or key=="space" then
            if st.phase[1]==TARGET[1] and st.phase[2]==TARGET[2] and st.phase[3]==TARGET[3] then
                st.solved=true; st.console=false; st.message=T("r_lock"); st.msgT=4; st.doneT=0
            else say(T("r_bad"),3.5); st.flash=0.6 end
        elseif key=="x" then st.console=false; say(T("r_standby"),3) end
        return
    end
    if key=="e" or key=="a" or key=="return" or key=="space" then
        if not st.inserted and math.abs(st.x-286)<58 then
            st.inserted=true; say(T("r_ins"),5)
        elseif not st.inserted then say(T("r_home"),3)
        elseif math.abs(st.x-520)<72 then st.console=true; st.selected=1; say(T("r_help", require("src.i18n").keyName("A"), require("src.i18n").keyName("B")),5)
        else say(T("r_inplace"),3) end
    end
end
local function rect(x,y,w,h) love.graphics.rectangle("fill",x,y,w,h) end
local function color(r,g,b) love.graphics.setColor(r/255,g/255,b/255) end
function R.draw(ui, sprites)
    if not st then R.reset() end
    local g=love.graphics
    color(3,8,20); rect(0,0,640,82); rect(0,362,640,118); color(10,22,39); rect(0,82,640,280)
    color(20,39,57); rect(0,95,640,18); rect(0,340,640,20); color(40,63,79); rect(0,111,640,4); rect(0,340,640,4)
    for i=0,9 do local x=i*72; color(25,45,62); rect(x,118,5,220); rect(x+8,128,2,194); color(37,61,76); rect(x+12,152,45,3); rect(x+12,258,45,3); color(9,20,34); rect(x+16,160,36,92) end
    color(29,st.inserted and 211 or 67,st.inserted and 216 or 84); rect(24,142,592,5); rect(24,294,592,5)
    color(14,29,45); rect(218,174,140,152); color(48,76,92); rect(232,184,112,132); rect(240,194,96,112)
    color(st.inserted and 65 or 255,st.inserted and 226 or 177,st.inserted and 218 or 78); rect(260,207,56,5); rect(260,288,56,5)
    color(8,17,29); rect(267,220,42,58)
    if st.inserted then color(73,228,220); rect(273,225,30,48); color(255,190,79); rect(279,235,18,4); rect(279,247,18,4); rect(279,259,18,4)
    else color(255,190,79); rect(276,229,24,38); color(74,35,24); rect(281,235,14,25) end
    color(22,42,60); rect(454,196,112,112); rect(464,206,92,82); color(52,85,103); rect(472,214,76,66)
    color(st.inserted and 72 or 105,st.inserted and 226 or 118,st.inserted and 218 or 128)
    for i=0,2 do rect(480+i*22,226,14,5); rect(480+i*22,240,14,25) end
    color(60,86,101); rect(0,363,640,7); color(30,52,70); rect(0,370,640,110)
    for i=0,15 do color(37,57,71); rect(i*44+8,390,2,72) end
    for i=0,11 do local on=st.inserted and math.floor(st.t*4+i)%3~=0; color(on and 68 or 40,on and 214 or 75,on and 211 or 89); rect(22+i*51,356,28,3) end
    local frames = sprites and (sprites[st.console and "interaction" or (st.facing < 0 and "walk_left" or "walk_right")]) or nil
    local sprite = frames and frames[st.console and 1 or (1 + math.floor(st.walkT or 0)%4)] or nil
    if sprite and sprite.getDimensions then
        local sw, sh = sprite:getDimensions()
        local targetH = 76
        local scale = targetH / math.max(1, sh)
        color(255,255,255)
        love.graphics.draw(sprite, st.x-sw*scale*0.5, 357-targetH, 0, scale, scale)
    else
        color(2,7,14); rect(st.x-12,357,24,4); color(27,49,66); rect(st.x-9,326,18,27); rect(st.x-st.facing*12,331,7,18)
        color(183,199,208); rect(st.x-8,350,7,5); rect(st.x+1,350,7,5); color(218,229,230); rect(st.x-9,306,18,20)
        color(15,43,61); rect(st.x-7,310,14,10); color(68,201,215); rect(st.x-st.facing*3,312,6,5); color(255,190,79); rect(st.x-10,322,20,4)
    end
    ui.panel(22,14,596,66); ui.centered(T("r_title"),24,ui.f24,{133,239,231})
    local obj=T(not st.inserted and "r_o1" or (st.solved and "r_o2" or (st.console and "r_o3" or "r_o4")))
    ui.centered(obj,55,ui.f16,{255,190,79})
    if st.console then
        ui.panel(105,115,430,250); ui.centered(T("r_cal"),130,ui.f16,{133,239,231})
        for i=1,3 do local y=174+(i-1)*43; color(i==st.selected and 255 or 164,i==st.selected and 190 or 205,i==st.selected and 79 or 219); g.setFont(ui.f16.obj); g.printf(T("r_coil").." "..LETTERS[i],132,y,150,"left")
            for p=0,3 do color(p==st.phase[i] and 73 or 29,p==st.phase[i] and 225 or 56,p==st.phase[i] and 216 or 76); rect(292+p*35,y-2,25,22); if p==st.phase[i] then color(255,255,230); rect(300+p*35,y+5,9,7) end end
            color(st.phase[i]==TARGET[i] and 96 or 110,st.phase[i]==TARGET[i] and 230 or 130,st.phase[i]==TARGET[i] and 177 or 145); g.setFont(ui.f16.obj); g.printf(st.phase[i]==TARGET[i] and "OK" or "?",448,y,52,"left")
        end
        color(207,222,230); g.setFont(ui.f16.obj); g.printf(T("r_tgt"),132,303,370,"left"); color(255,190,79); g.printf(T("r_k1"),132,326,380,"left"); g.printf(T("r_k2"),132,346,380,"left")
    end
    if st.msgT>0 and st.message then
        local lines,cur={},""
        for word in st.message:gmatch("%S+") do
            if #cur>0 and #cur+1+#word>31 then lines[#lines+1]=cur; cur=word else cur=(#cur>0) and (cur.." "..word) or word end
        end
        if #cur>0 then lines[#lines+1]=cur end
        local n=math.min(3,#lines)
        ui.panel(54,376,532,14+n*20)
        for i=1,n do ui.centered(lines[i],386+(i-1)*20,ui.f16,{222,235,240}) end
    end
    if not ui.aka then ui.centered(require("src.i18n").t("explore_foot"),463,ui.f8,{151,177,190}) end
end
return R
