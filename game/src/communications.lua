-- M9 - exploration du relais de communications avant l'accord du signal.
-- Trois salles connectees, interactions contextuelles et retour explicite au mini-jeu.
local C = {}
local st
local I = require("src.i18n")
local TX = require("src.communications_text")
local Gen = require("src.interiors")   -- interieurs de M10, M11 et M12 (meme moteur, autres donnees)
local function T(k)
  local t = TX[I.lang] or TX.fr
  return I.expand(t[k] or TX.fr[k] or "")
end
local function say(s, d) st.msg, st.msgD = s, d or 4 end
local LAY = Gen.layout            -- {1,0,2,0,3} : etape de chaque salle (0 = salle de fouille)
local NR = #LAY
C.count = NR
local function K() return st.kind or "relay" end
-- kind : nil = relais de M9 ; "wreck" / "argo2" / "caisson" = interieurs generiques (interiors.lua)
function C.reset(kind)
  st = {room=1, doors={}, t=0, mode="walk", visited={}, msg=nil, msgD=0,
        checked=false, repaired=false, aligned=false, kind=kind, step={false,false,false}}
  for r = 1, NR - 1 do st.doors[r] = (LAY[r] == 0) end   -- les salles de fouille s'ouvrent d'emblee
  C.s = st
  C.enter(1)
end
function C.enter(r)
  st.room=r
  if not st.visited[r] then
    st.visited[r]=true
    local p = LAY[r]
    if p == 0 then say(Gen.T(K(), "f"..r.."_intro"), 5)
    else say(st.kind and Gen.T(st.kind,"intro"..p) or T("intro"..p),5) end
  end
end
function C.takeMsg()
  local m,d=st.msg,st.msgD; st.msg=nil; return m,d
end
function C.minX() return st.room==1 and 42 or 36 end
function C.maxX() return st.room<NR and st.doors[st.room] and 570 or 500 end
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
  if st.room<NR and st.doors[st.room] and ex.x>=565 then
    st.mode,st.tt,st.switched,st.to,st.dir="transit",0,false,st.room+1,1
  elseif st.room>1 and ex.x<=44 then
    st.mode,st.tt,st.switched,st.to,st.dir="transit",0,false,st.room-1,-1
  end
end
function C.title() return st.kind and Gen.T(st.kind,"header") or T("header") end
function C.actionHint() return I.t("explore_keys") end
function C.objective()
  local p=LAY[st.room]
  if p==0 then return Gen.T(K(),"f"..st.room.."_obj") end
  if st.kind then return Gen.T(st.kind,"obj"..p..(st.step[p] and "done" or "")) end
  if p==1 then return st.doors[st.room] and T("obj1done") or T("obj1")
  elseif p==2 then return st.repaired and T("obj2done") or T("obj2")
  else return st.aligned and T("obj3done") or T("obj3") end
end
function C.hint()
  local p=LAY[st.room]
  if p==0 then return Gen.G("hintfree") end
  if st.kind then return Gen.G(st.step[p] and "hintdone" or "hint") end
  if p==1 then return st.doors[st.room] and T("hint1done") or T("hint1")
  elseif p==2 then return st.repaired and T("hint2done") or T("hint2")
  else return st.repaired and T("hint3done") or T("hint3") end
end
-- Action sur l'etape de la salle (p = 1..3). Renvoie message, evenement, proche(bool).
local function puzzleAct(x,p)
  if st.kind then
    if math.abs(x-Gen.kinds[st.kind].marker[p])>46 then return nil,nil,false end
    if st.step[p] then return Gen.G("done"),nil,true end
    st.step[p]=true
    if p<3 then st.doors[st.room]=true end
    if p==3 then st.aligned=true; return Gen.T(st.kind,"act3"), "done", true end
    return Gen.T(st.kind,"act"..p), "ok", true
  end
  if p==1 then
    if math.abs(x-470)>42 then return nil,nil,false end
    if not st.checked then st.checked=true; return T("panelcheck"), "ok", true end
    if not st.doors[st.room] then st.doors[st.room]=true; return T("panelrepair"), "ok", true end
    return T("paneldone"),nil,true
  elseif p==2 then
    if math.abs(x-310)>48 then return nil,nil,false end
    if not st.doors[1] then return T("boxlocked"),nil,true end
    if not st.repaired then st.repaired=true; st.doors[st.room]=true; return T("boxrepair"), "ok", true end
    return T("boxdone"),nil,true
  else
    if math.abs(x-470)>50 then return nil,nil,false end
    if not st.repaired then return T("receiverlocked"),nil,true end
    st.aligned=true
    return T("signal"), "signal", true
  end
end
function C.interact(x)
  if st.mode~="walk" then return nil end
  local p=LAY[st.room]
  if p>0 then
    local m,ev,near=puzzleAct(x,p)
    if near then return m,ev end
  end
  local n=Gen.noteAt(K(),st.room,x)
  if n then return Gen.T(K(),"n"..st.room..n),"ok" end
  if p==0 then return Gen.G("farf"),nil end
  if st.kind then return Gen.G("far"),nil end
  return T(p==1 and "panelfar" or (p==2 and "boxfar" or "receiverfar")),nil
end
local tint=nil
local function col(r,g,b)
  if tint then r,g,b=tint(r,g,b) end
  love.graphics.setColor(r/255,g/255,b/255)
end
local function rect(x,y,w,h) love.graphics.rectangle("fill",x,y,w,h) end
function C.draw(ex)
  local g=love.graphics; local r=st.room
  tint=st.kind and Gen.kinds[st.kind].tint or nil
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
  -- porte de droite et verrou
  if r<NR then
    local x=565
    col(28,48,63); rect(x-24,152,48,299)
    col(st.doors[r] and 50 or 74,st.doors[r] and 185 or 63,st.doors[r] and 177 or 57)
    rect(x-18,160,4,286); rect(x+14,160,4,286)
    col(9,21,34); rect(x-12,174,24,268)
    col(st.doors[r] and 64 or 255,st.doors[r] and 220 or 177,st.doors[r] and 210 or 79)
    rect(x-4,198,8,4); rect(x-4,218,8,4)
  end
  local p=LAY[r]
  Gen.deco(K(),r,st,col,rect)
  if p==0 then
    -- salle de fouille : rien a reparer
  elseif st.kind then
    local mx=Gen.kinds[st.kind].marker[p]
    Gen.console(col,rect,mx,st.step[p])
    Gen.props(st.kind,p,st,col,rect)
  elseif p==1 then
    -- panneau de securite
    col(30,54,70); rect(426,308,88,112); col(8,21,35); rect(435,318,70,88)
    col(255,179,78); rect(444,330,52,4); col(st.checked and 66 or 110,st.checked and 222 or 95,st.checked and 204 or 86)
    rect(446,345,12,12); rect(465,345,12,12); rect(484,345,12,12)
    col(st.doors[r] and 75 or 255,st.doors[r] and 230 or 179,st.doors[r] and 170 or 75); rect(451,372,38,6)
  elseif p==2 then
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
  -- feuillets muraux
  Gen.drawNotes(K(),r,col,rect)
  -- marqueur d'interaction : petit chevron ambre au-dessus du terminal actif ou du feuillet a portee
  local tx,active=470,false
  if p>0 then
    tx=(st.kind or "relay") and Gen.kinds[K()].marker[p]
    if st.kind then active=not st.step[p]
    else active=(p==1 and not st.doors[r]) or (p==2 and not st.repaired) or (p==3 and st.repaired and not st.aligned) end
  end
  if active then col(255,190,79); rect(tx-5,285,10,3); rect(tx-2,280,4,5) end
  if st.mode=="walk" and ex then
    local n,nx=Gen.noteAt(K(),r,ex.x)
    if n and math.floor(st.t*4)%2==0 then col(255,190,79); rect(nx-4,300,8,6); rect(nx-2,306,4,3) end
  end
  tint=nil
end
return C
