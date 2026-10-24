-- M9 - exploration du relais de communications avant l'accord du signal.
-- Trois salles connectees, interactions contextuelles et retour explicite au mini-jeu.
local C = {}
local st
local I = require("src.i18n")
local TX = require("src.communications_text")
local function T(k)
  local t = TX[I.lang] or TX.fr
  return t[k] or TX.fr[k] or ""
end
local function say(s, d) st.msg, st.msgD = s, d or 4 end
function C.reset()
  st = {room=1, doors={false,false}, t=0, mode="walk", visited={}, msg=nil, msgD=0,
        checked=false, repaired=false, aligned=false}
  C.s = st
  C.enter(1)
end
function C.enter(r)
  st.room=r
  if not st.visited[r] then
    st.visited[r]=true
    say(T("intro"..r),5)
  end
end
function C.takeMsg()
  local m,d=st.msg,st.msgD; st.msg=nil; return m,d
end
function C.minX() return st.room==1 and 42 or 36 end
function C.maxX() return st.room<3 and st.doors[st.room] and 570 or 500 end
function C.update(dt, ex)
  st.t=st.t+dt
  if st.mode=="transit" then
    st.tt=st.tt+dt
    if not st.switched and st.tt>=0.3 then
      st.switched=true; C.enter(st.to); ex.x=st.dir>0 and 56 or 540; ex.facing=st.dir
    end
    if st.tt>=0.6 then st.mode="walk" end
    return
  end
  if st.mode~="walk" then return end
  if st.room<3 and st.doors[st.room] and ex.x>=565 then
    st.mode,st.tt,st.switched,st.to,st.dir="transit",0,false,st.room+1,1
  elseif st.room>1 and ex.x<=44 then
    st.mode,st.tt,st.switched,st.to,st.dir="transit",0,false,st.room-1,-1
  end
end
function C.title() return T("header") end
function C.actionHint() return I.aka and T("actionsAKA") or T("actions") end
function C.objective()
  if st.room==1 then return st.doors[1] and T("obj1done") or T("obj1")
  elseif st.room==2 then return st.repaired and T("obj2done") or T("obj2")
  else return st.aligned and T("obj3done") or T("obj3") end
end
function C.hint()
  if st.room==1 then return st.doors[1] and T("hint1done") or (I.aka and T("hint1aka") or T("hint1"))
  elseif st.room==2 then return st.repaired and T("hint2done") or T("hint2")
  else return st.repaired and T("hint3done") or T("hint3") end
end
function C.interact(x)
  if st.mode~="walk" then return nil end
  if st.room==1 then
    if math.abs(x-470)>42 then return T("panelfar"),nil end
    if not st.checked then st.checked=true; return T("panelcheck"), "ok" end
    if not st.doors[1] then st.doors[1]=true; return T("panelrepair"), "ok" end
    return T("paneldone"),nil
  elseif st.room==2 then
    if math.abs(x-310)>48 then return T("boxfar"),nil end
    if not st.doors[1] then return T("boxlocked"),nil end
    if not st.repaired then st.repaired=true; st.doors[2]=true; return T("boxrepair"), "ok" end
    return T("boxdone"),nil
  else
    if math.abs(x-470)>50 then return T("receiverfar"),nil end
    if not st.repaired then return T("receiverlocked"),nil end
    st.aligned=true
    return T("signal"), "signal"
  end
end
local function col(r,g,b) love.graphics.setColor(r/255,g/255,b/255) end
local function rect(x,y,w,h) love.graphics.rectangle("fill",x,y,w,h) end
function C.draw(ex)
  local g=love.graphics; local r=st.room
  col(3,8,19); rect(0,0,640,480)
  -- murs industriels, conduites et nervures; chaque salle a sa signature lumineuse.
  col(13,28,43); rect(0,0,640,116); rect(0,280,640,200)
  col(31,53,69); rect(0,94,640,24); rect(0,275,640,8)
  col(69,94,108); rect(0,96,640,3); rect(0,279,640,3)
  for i=0,10 do
    local x=i*64
    col(23,43,58); rect(x,0,4,116); rect(x+7,8,2,83)
    col(10,21,34); rect(x+5,290,54,112)
    col(31,51,66); rect(x+9,294,46,3)
  end
  -- Fenetre d'observation, structure et lune lointaine.
  col(5,15,29); rect(80,124,180,132); col(17,40,59); rect(88,132,164,116)
  col(8,19,35); rect(96,140,148,100); col(37,83,112); rect(96,214,148,2)
  col(174,202,211); rect(195,172,3,3); rect(215,192,2,2); rect(155,202,2,2)
  col(25,47,62); rect(0,451,640,29); col(68,91,105); rect(0,451,640,4)
  for i=0,15 do col(36,56,70); rect(i*44,465,2,12) end
  -- portes et verrous
  for i=1,2 do
    local x=565
    col(28,48,63); rect(x-24,152,48,299)
    col(st.doors[i] and 50 or 74,st.doors[i] and 185 or 63,st.doors[i] and 177 or 57)
    rect(x-18,160,4,286); rect(x+14,160,4,286)
    col(9,21,34); rect(x-12,174,24,268)
    col(st.doors[i] and 64 or 255,st.doors[i] and 220 or 177,st.doors[i] and 210 or 79)
    rect(x-4,198,8,4); rect(x-4,218,8,4)
  end
  if r==1 then
    -- panneau de securite
    col(30,54,70); rect(426,308,88,112); col(8,21,35); rect(435,318,70,88)
    col(255,179,78); rect(444,330,52,4); col(st.checked and 66 or 110,st.checked and 222 or 95,st.checked and 204 or 86)
    rect(446,345,12,12); rect(465,345,12,12); rect(484,345,12,12)
    col(st.doors[1] and 75 or 255,st.doors[1] and 230 or 179,st.doors[1] and 170 or 75); rect(451,372,38,6)
  elseif r==2 then
    -- cables et boitier de jonction a reparer
    col(42,63,78); rect(110,374,420,12); col(255,179,78); rect(160,376,90,4); rect(278,376,74,4); rect(386,376,82,4)
    col(20,38,54); rect(268,306,92,98); col(54,82,99); rect(276,314,76,82)
    col(st.repaired and 73 or 255,st.repaired and 225 or 179,st.repaired and 212 or 78); rect(287,330,54,5)
    for i=0,2 do col(st.repaired and 74 or 115,st.repaired and 220 or 100,st.repaired and 130 or 74); rect(289+i*18,348,12,20) end
  else
    -- grand recepteur avec indicateurs de tension
    col(25,47,63); rect(424,292,124,128); col(7,19,32); rect(434,302,104,108)
    col(41,74,91); rect(442,312,88,46); col(55,195,190); rect(450,322,72,3)
    col(st.repaired and 70 or 255,st.repaired and 220 or 179,st.repaired and 170 or 75)
    for i=0,3 do rect(451+i*18,336,12,10) end
    col(255,179,78); rect(454,374,64,4)
  end
  -- lumiere d'alerte discrete et ambiance dynamique
  if math.floor(st.t*2)%2==0 then col(255,94,78) else col(95,35,34) end
  rect(38,102,18,5); rect(584,102,18,5)
  -- Le HUD et le journal LUNA sont rendus par game.lua, comme dans M3/M5.
  -- marqueur d'interaction : petit chevron ambre au-dessus du terminal actif
  local tx=(r==1 and 470) or (r==2 and 310) or 470
  local active=(r==1 and not st.doors[1]) or (r==2 and not st.repaired) or (r==3 and st.repaired and not st.aligned)
  if active then col(255,190,79); rect(tx-5,285,10,3); rect(tx-2,280,4,5) end
end
return C
