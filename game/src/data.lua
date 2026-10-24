-- LUNAR COURIER - donnees des 18 missions (mondes larges a defilement horizontal).
-- Les TEXTES (noms, objectifs, cartes d'histoire, radio) sont dans text_fr.lua / text_en.lua, meme ordre.
--
-- w        : largeur du monde en px virtuels (l'ecran en voit 640)
-- spec     : profil du terrain, points {x, y} tries par x ; {x, y, "pad"} = plateau plat de 124 px (atterrissage)
--            centre sur x : les balises (pads) sont deduites de ces points, de gauche a droite
-- cell     : capsule energetique {x, y} a recuperer avant le 1er atterrissage
-- rocks    : {x} rochers poses au sol ; debris : {x,y,amp,speed,phase,axis,spin[,soft,kind]} epaves/drones mobiles
-- beams    : rayons solaires {x,period,on,warn,phase} ; wind : acceleration laterale max (rafales)
-- decor    : liste {kind, x[, big]} dessinee dans le monde (sans collision) ; theme : forme des reliefs lointains
-- Contraintes de texte (police AKA pire cas : 1 caractere = 16 px) : voir text_fr.lua.
local D = {}
D.chapterStart = {1, 7, 13}

local function terrain(spec)
    local pts = {}
    for _, s in ipairs(spec) do
        if s[3] then
            pts[#pts+1] = {s[1] - 62, s[2]}
            pts[#pts+1] = {s[1] + 62, s[2]}
        else
            pts[#pts+1] = {s[1], s[2]}
        end
    end
    return pts
end

local function padsOf(spec)
    local p = {}
    for _, s in ipairs(spec) do if s[3] then p[#p+1] = {x = s[1]} end end
    return p
end

local function M(t)
    t.terrain = terrain(t.spec)
    t.pads = padsOf(t.spec)
    t.rocks = t.rocks or {}
    t.debris = t.debris or {}
    t.decor = t.decor or {}
    return t
end

D.missions = {
-- ======================================================================
--                    CHAPITRE 1 : LA COLONIE SILENCIEUSE
-- ======================================================================
 M{radioT={10}, w=1280, sky="earth", theme="plain", gravity=25, fuelUse=5.5, wind=0,
   spec={{0,392},{260,388},{400,370},{560,396},{760,388},{900,402},{1020,392,"pad"},{1180,382},{1280,392}},
   cell={x=410,y=298},
   decor={{"dome",200},{"dish",700},{"tower",1190}}},

 M{radioT={12}, w=1600, sky="earth", theme="crater", gravity=28, fuelUse=5.5, wind=0,
   spec={{0,392},{220,386},{300,380},{480,400},{640,392},{720,380},{900,404},{1000,396},{1160,408},{1300,392},{1400,386,"pad"},{1520,394},{1600,392}},
   cell={x=300,y=300}, rocks={{x=600},{x=1100}},
   decor={{"dish",520},{"crane",950},{"dome",1500}}},

 M{radioT={14}, w=1600, sky="earth", theme="plain", gravity=23, fuelUse=5.5, wind=0,
   spec={{0,390},{200,392},{360,376},{520,394},{700,402},{860,384},{1000,392},{1160,388},{1280,380,"pad"},{1480,390},{1600,392}},
   cell={x=360,y=292},
   decor={{"panels",300},{"dome",800},{"station",1430,false}}},

 M{radioT={12}, w=1920, sky="earth", theme="canyon", gravity=31, fuelUse=5.5, wind=0,
   spec={{0,386},{200,384},{300,380},{420,382,"pad"},{640,404},{720,444},{800,468},{1100,470},{1180,452},{1260,420},{1340,384},{1560,380},{1700,384,"pad"},{1800,382},{1920,386}},
   cell={x=250,y=300},
   decor={{"pylon",150},{"crystals",560},{"crystals",1290},{"crystals",1860}}},

 M{radioT={}, w=1440, sky="earth", theme="ruins", gravity=26, fuelUse=5.5, wind=0,
   spec={{0,396},{240,392},{380,388},{440,344},{620,342},{680,300},{900,298,"pad"},{1010,340},{1100,380},{1300,392},{1440,396}},
   cell={x=300,y=300},
   decor={{"arch",260},{"arch",1180},{"pylon",780}}},

 M{radioT={10}, w=2240, sky="earth", theme="plain", gravity=25, fuelUse=5.0, wind=0,
   spec={{0,392},{200,388},{340,372},{500,398},{700,390},{900,386,"pad"},{1100,380},{1250,360},{1400,396},{1580,404},{1740,392},{1880,384},{2000,380,"pad"},{2140,388},{2240,392}},
   cell={x=340,y=290}, rocks={{x=1560}},
   decor={{"dish",600},{"dome",1500},{"tower",2160}}},

-- ======================================================================
--                    CHAPITRE 2 : LA FACE CACHEE
-- ======================================================================
 M{radioT={10}, w=1920, sky="far", theme="far", gravity=24, fuelUse=5.5, wind=0,
   spec={{0,390},{240,386},{400,376},{560,394},{760,400},{960,388},{1100,372},{1300,392},{1500,398},{1640,388,"pad"},{1780,386},{1920,390}},
   cell={x=420,y=300},
   decor={{"dish",700},{"panels",1250},{"tower",1810}}},

 M{radioT={8,28}, w=2240, sky="far", theme="far", gravity=26, fuelUse=5.5, wind=8, blackout=true,
   spec={{0,388},{220,384},{360,396},{520,402},{700,388},{860,372},{1000,370,"pad"},{1200,392},{1400,404},{1600,390},{1760,376},{1900,380},{2020,378,"pad"},{2160,386},{2240,390}},
   cell={x=360,y=300}, rocks={{x=1400}},
   decor={{"camp",400},{"dish",1500},{"crystals",2180}}},

 M{radioT={12}, w=2560, sky="far", theme="far", gravity=26, fuelUse=5.5, wind=0,
   spec={{0,392},{220,388},{380,382},{500,396},{600,350},{720,348,"pad"},{860,352},{960,396},{1140,402},{1280,360},{1400,330,"pad"},{1540,336},{1640,380},{1840,398},{2000,390},{2200,364,"pad"},{2380,372},{2560,392}},
   cell={x=300,y=310},
   decor={{"panels",420},{"camp",1000},{"dish",1800}}},

 M{radioT={10}, w=2240, sky="far", theme="wreck", gravity=28, fuelUse=5.5, wind=0,
   spec={{0,392},{240,390},{400,380},{560,396},{760,404},{880,392},{1000,384,"pad"},{1160,392},{1360,402},{1560,394},{1720,386},{1900,382,"pad"},{2060,388},{2240,392}},
   cell={x=400,y=300},
   debris={
     {x=660,  y=250, amp=60, speed=1.0, phase=0,   axis="x", spin=1.2},
     {x=1280, y=235, amp=50, speed=1.1, phase=1.5, axis="y", spin=1.0},
     {x=1520, y=270, amp=70, speed=1.0, phase=3.0, axis="x", spin=1.4},
     {x=1820, y=250, amp=50, speed=1.2, phase=2.0, axis="y", spin=1.1}},
   decor={{"wreck",900},{"wreck",1700},{"crane",300}}},

 M{radioT={10}, w=1920, sky="far", theme="far", gravity=30, fuelUse=5.5, wind=-8,
   spec={{0,392},{260,388},{440,372},{600,398},{800,404},{980,388},{1140,360},{1260,322},{1400,318},{1480,330},{1620,300,"pad"},{1800,302},{1920,310}},
   cell={x=420,y=300}, rocks={{x=800}},
   decor={{"panels",300},{"station",1720,true}}},

 M{radioT={8}, w=2560, sky="far", theme="far", gravity=30, fuelUse=5.0, wind=10,
   spec={{0,392},{240,388},{400,376},{560,396},{760,402},{960,390},{1120,372},{1250,350,"pad"},{1420,360},{1600,396},{1780,404},{1960,380},{2100,340},{2300,310,"pad"},{2480,318},{2560,326}},
   cell={x=400,y=300},
   debris={
     {x=800,  y=240, amp=70, speed=1.2, phase=0,   axis="x", spin=1.2},
     {x=1560, y=230, amp=60, speed=1.0, phase=1.5, axis="y", spin=1.0},
     {x=1900, y=240, amp=70, speed=1.3, phase=3.0, axis="x", spin=1.4}},
   decor={{"dome",700},{"station",2420,true}}},

-- ======================================================================
--                    CHAPITRE 3 : LE PHARE
-- ======================================================================
 M{radioT={8}, w=1280, sky="peak", theme="peak", gravity=25, fuelUse=5.5, wind=0,
   spec={{0,392},{260,390},{420,382},{600,396},{780,390},{940,386,"pad"},{1120,390},{1280,392}},
   cell={x=420,y=300},
   decor={{"panels",600},{"station",1160,true}}},

 M{radioT={10}, w=2560, sky="peak", theme="peak", gravity=25, fuelUse=5.5, wind=6,
   spec={{0,390},{220,388},{360,380},{520,394},{700,388},{900,396},{1060,386,"pad"},{1240,392},{1440,402},{1620,394},{1800,388},{2000,384},{2200,380,"pad"},{2360,388},{2560,392}},
   cell={x=360,y=300},
   beams={{x=650, period=4.0, on=1.2, warn=1.0, phase=0.0},
          {x=800, period=4.0, on=1.2, warn=1.0, phase=1.5},
          {x=1500,period=5.0, on=1.2, warn=1.2, phase=3.0},
          {x=1700,period=4.0, on=1.2, warn=1.0, phase=0.7},
          {x=1900,period=4.5, on=1.2, warn=1.0, phase=2.4}},
   decor={{"tower",400},{"pylon",1300},{"dome",2400}}},

 M{radioT={10}, w=2560, sky="peak", theme="peak", gravity=24, fuelUse=5.5, wind=-6,
   spec={{0,390},{240,388},{400,374},{560,354},{700,350,"pad"},{860,356},{1000,390},{1180,398},{1340,340},{1500,332,"pad"},{1660,338},{1800,390},{1980,400},{2140,372},{2300,364,"pad"},{2440,370},{2560,380}},
   debris={
     {x=900,  y=250, amp=70, speed=1.2, phase=0, axis="x", spin=0, soft=true, kind="drone"},
     {x=1100, y=270, amp=50, speed=1.6, phase=1, axis="y", spin=0, soft=true, kind="drone"},
     {x=1700, y=260, amp=70, speed=1.0, phase=2, axis="x", spin=0, soft=true, kind="drone"},
     {x=1900, y=280, amp=60, speed=1.4, phase=3, axis="y", spin=0, soft=true, kind="drone"},
     {x=2100, y=250, amp=60, speed=1.1, phase=4, axis="x", spin=0, soft=true, kind="drone"}},
   decor={{"camp",500},{"crystals",1200},{"tower",2480}}},

 M{radioT={10}, w=2240, sky="peak", theme="canyon", gravity=28, fuelUse=5.5, wind=8,
   spec={{0,390},{240,388},{400,382},{540,386,"pad"},{700,392},{800,430},{880,462},{1280,464},{1360,430},{1440,392},{1620,386},{1800,380},{1960,382,"pad"},{2100,386},{2240,390}},
   cell={x=300,y=300},
   beams={{x=950, period=4.5, on=1.3, warn=1.0, phase=0.0},
          {x=1070,period=4.5, on=1.3, warn=1.0, phase=2.2},
          {x=1190,period=4.5, on=1.3, warn=1.0, phase=3.4}},
   decor={{"crystals",400},{"crystals",1700},{"tower",2120}}},

 M{radioT={12}, w=3200, sky="peak", theme="peak", gravity=27, fuelUse=5.0, wind=-9,
   spec={{0,392},{240,390},{400,386},{520,384,"pad"},{680,386},{740,346},{920,342},{980,302},{1180,298},{1300,262,"pad"},{1460,264},{1520,226},{1720,222},{1780,200},{1980,198},{2200,196},{2400,196,"pad"},{2600,200},{2800,196},{3000,196,"pad"},{3140,200},{3200,200}},
   cell={x=300,y=300},
   debris={
     {x=1000, y=190, amp=70, speed=1.1, phase=0, axis="x", spin=1.2},
     {x=1900, y=130, amp=60, speed=1.0, phase=2, axis="x", spin=1.0}},
   beams={{x=860, period=4.0, on=1.2, warn=1.0, phase=0.0}},
   decor={{"tower",300},{"arch",1000},{"pylon",2200}}},

 M{radioT={8,30}, w=3200, sky="peak", theme="peak", gravity=30, fuelUse=4.8, wind=10,
   spec={{0,392},{240,390},{400,380},{560,394},{720,402},{900,386,"pad"},{1060,390},{1240,404},{1400,380},{1560,346},{1700,342,"pad"},{1840,350},{2000,398},{2200,406},{2360,376},{2500,344},{2660,306},{2820,302},{3040,296,"pad"},{3180,298},{3200,298}},
   cell={x=300,y=300},
   debris={
     {x=800,  y=250, amp=60, speed=1.2, phase=0,   axis="x", spin=1.2},
     {x=1900, y=240, amp=60, speed=1.0, phase=1.5, axis="y", spin=1.0},
     {x=2500, y=200, amp=50, speed=1.3, phase=3.0, axis="x", spin=1.4}},
   beams={{x=1300, period=4.0, on=1.2, warn=1.0, phase=0.0},
          {x=2100, period=4.5, on=1.2, warn=1.0, phase=2.0}},
   decor={{"camp",200},{"mast",3150}}},
}

-- Illustrations des cartes (assets/scenes/<nom>.png), une par carte, dans l'ordre des cartes pre puis post.
D.art = {
 {pre={"base","holo"}, post={"radar"}},
 {pre={"explorateur"}, post={"tour"}},
 {pre={"hangar"}, post={"regie"}},
 {pre={"cristaux"}, post={"mine"}},
 {pre={"ruines"}, post={"coeur"}},
 {pre={"faisceau"}, post={"colonie","ville","soleil"}},
 {pre={"couchant","terre"}, post={"radar"}},
 {pre={"camp"}, post={"regie"}},
 {pre={"soleil"}, post={"tour"}},
 {pre={"epave"}, post={"asteroides"}},
 {pre={"cargo"}, post={"hangar"}},
 {pre={"depart"}, post={"cratere"}, post2={"grotte","base"}},
 {pre={"aube","camp","ruines","faisceau","depart"}, post={"ville"}},
 {pre={"soleil"}, post={"radar"}},
 {pre={"mine"}, post={"cratere"}},
 {pre={"holo","radar","regie","grotte"}, post={"terre"}},
 {pre={"explorateur"}, post={"couchant","holo","camp","orbite"}},
 {pre={"depart"}, post={"tour","holo","faisceau","regie","colonie","orbite"}},
}

return D
