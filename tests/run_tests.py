import sys, math, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lupa import lua51 as L
root = sys.argv[1]
mode = sys.argv[2] if len(sys.argv) > 2 else "full"      # full | noaudio
SP = os.path.dirname(os.path.abspath(__file__))
lua = L.LuaRuntime(unpack_returned_tuples=True)
lua.globals().ROOT = root
lua.globals().MODE = mode
lua.execute('package.path = ROOT.."/?.lua;"..package.path')
stub = r'''
love = {graphics={}, keyboard={}, timer={}, system={}, event={}}
OSNAME = 'Other'
function love.system.getOS() return OSNAME end
QUIT = 0
function love.event.quit() QUIT = QUIT + 1 end
SHOTS = {}
function love.graphics.captureScreenshot(n) SHOTS[#SHOTS+1] = n end
function love.graphics.setLineWidth() end
VIOL = {}
local function viol(msg) VIOL[msg] = (VIOL[msg] or 0) + 1 end
PRIM = 0
local curSize = 16
local function chk(name, n, min) if n < min then error(name.." called with "..n.." args (need >="..min..")", 3) end end
local function isnum(...) for i=1,select('#',...) do if type(select(i,...))~="number" then return false end end return true end
function love.graphics.rectangle(mode,x,y,w,h) PRIM = PRIM + 1 chk("rectangle",select('#',mode,x,y,w,h),5)
  if not isnum(x,y,w,h) then error("rectangle non-number",2) end end
function love.graphics.circle(mode,x,y,r) PRIM = PRIM + 1 chk("circle",select('#',mode,x,y,r),4) end
function love.graphics.line(...) PRIM = PRIM + 1 chk("line",select('#',...),4) end
function love.graphics.polygon(mode,...) PRIM = PRIM + 1
  local a={...}; if #a<6 then error("polygon <3 pts",2) end
  local n=#a/2; local sign=0
  for i=0,n-1 do
    local x1,y1=a[2*i+1],a[2*i+2]; local j=(i+1)%n; local k=(i+2)%n
    local x2,y2=a[2*j+1],a[2*j+2]; local x3,y3=a[2*k+1],a[2*k+2]
    local cr=(x2-x1)*(y3-y2)-(y2-y1)*(x3-x2)
    if math.abs(cr)>1e-9 then local s=cr>0 and 1 or -1; if sign==0 then sign=s elseif s~=sign then viol("CONCAVE polygon: "..table.concat(a,",")) break end end
  end
end
function love.graphics.print(t,x,y) PRIM = PRIM + 1 chk("print",select('#',t,x,y),3)
  if type(t)~="string" then error("print non-string",2) end
  if x + #t*curSize > 640 then viol("print overflow x: '"..t.."' x="..x.." size="..curSize) end
  if y + curSize > 480 then viol("print overflow y: '"..t.."'") end end
function love.graphics.printf(t,x,y,limit,align) PRIM = PRIM + 1 chk("printf",select('#',t,x,y,limit,align),5)
  if #t*curSize > limit then viol("printf overflow: '"..t.."' ("..#t*curSize.." > "..limit..") size="..curSize) end
  if y + curSize > 480 then viol("printf overflow y: '"..t.."' y="..y) end
  if t:find("[\128-\255]") then viol("non-ASCII text: "..t) end end
for _,n in ipairs{"push","pop","setColor","translate","rotate","scale"} do love.graphics[n]=function() end end
function love.graphics.setFont(f) curSize = f.s end
function love.graphics.newFont(s) if s%8~=0 then viol("font size not multiple of 8: "..s) end return {s=s} end
function love.graphics.setBackgroundColor() end
local held = {}
function love.keyboard.isDown(k, ...) if select('#',...)>0 then viol("isDown with multiple args") end return held[k] or false end
function love.timer.getTime() return 1 end
function __hold(k,v) held[k]=v end
function __viol() return VIOL end

-- audio stub (records loads / plays)
AUD = {loaded={}, plays={}, missing={}}
if MODE ~= "noaudio" then
  love.audio = {}
  function love.audio.newSource(path, kind)
    local f = io.open(ROOT.."/"..path, "rb")
    if not f then AUD.missing[path] = true; error("Could not open file "..path) end
    f:close()
    AUD.loaded[path] = (AUD.loaded[path] or 0) + 1
    local s = {path=path, playing=false}
    function s:setLooping(b) self.loop=b end
    function s:setVolume(v) end
    function s:play() self.playing=true; AUD.plays[path]=(AUD.plays[path] or 0)+1 end
    function s:stop() self.playing=false end
    return s
  end
end
-- image stub : lit la vraie taille du PNG (en-tete IHDR) ; absent en mode noaudio (teste le decor de secours)
IMG = {loaded={}, drawn=0, missing={}}
function love.graphics.draw(img, x, y, r, sx, sy)
  PRIM = PRIM + 1
  if type(img) ~= "table" or not img.w then viol("draw: not an image") return end
  if type(x) ~= "number" or type(y) ~= "number" then viol("draw: bad position") end
  IMG.drawn = IMG.drawn + 1
end
if MODE ~= "noaudio" then
  function love.graphics.newImage(path)
    local f = io.open(ROOT.."/"..path, "rb")
    if not f then IMG.missing[path] = true; error("Could not open file "..path) end
    local d = f:read(32); f:close()
    local function u32(i) return d:byte(i)*16777216 + d:byte(i+1)*65536 + d:byte(i+2)*256 + d:byte(i+3) end
    local w, h = u32(17), u32(21)
    IMG.loaded[path] = {w=w, h=h, n=((IMG.loaded[path] or {n=0}).n)+1}
    local im = {w=w, h=h}
    function im:getWidth() return self.w end
    function im:getHeight() return self.h end
    function im:getDimensions() return self.w, self.h end
    function im:setFilter() end
    return im
  end
end
function __img() return IMG end
-- filesystem stub (memoire)
FS = {}
if MODE ~= "noaudio" then
  love.filesystem = {}
  function love.filesystem.read(name) if FS[name] then return FS[name], #FS[name] end return nil, "Could not open file" end
  function love.filesystem.write(name, data) FS[name] = data; return true end
end
function __fs() return FS end
function __aud() return AUD end
'''
lua.execute(stub)
src = open(root+"/src/game.lua").read()
assert src.rstrip().endswith("return Game")
src = src.rstrip()[:-len("return Game")] + '''
Game._dbg = function()
  local m = mission()
  return {state=state, x=ship.x, y=ship.y, vx=ship.vx, vy=ship.vy, angle=ship.angle, landed=ship.landed,
          cargo=cargo, fuel=fuel, hull=hull, padIndex=padIndex, npads=#pads, failed=failed, mi=missionIndex,
          hascell=(m.cell~=nil), cellx=m.cell and m.cell.x or 0, celly=m.cell and m.cell.y or 0,
          padx=pads[padIndex] and pads[padIndex].x or 0, pady=pads[padIndex] and pads[padIndex].y or 0, t=missionTime,
          g=m.gravity, cruise=200, camX=camX, worldW=worldW, sysOpen=sysOpen, msg=message, mt=messageTimer, cardIdx=cardIdx, ncards=#cardsOf(), wind=windCur,
          menuN=#menu, menuSel=menuSel, musicName=Audio.musicName, musicOn=Audio.musicOn,
          tgcheck=(function() local ok=true for i,p in ipairs(pads) do for x=p.x-PAD_HALF-8,p.x+PAD_HALF+8,4 do if groundAt(x)~=p.y then ok=false end end end return ok end)()}
end
Game._set = function(t)
  for k,v in pairs(t) do ship[k] = v end
  if t.fuel then fuel = t.fuel end
  failed = false; hitCooldown = 0
end
Game._ship = function() return {x=ship.x, y=ship.y, vx=ship.vx, vy=ship.vy, angle=ship.angle, resting=ship.resting, landed=ship.landed, fuel=fuel, hull=hull, gy=groundAt(ship.x), failed=failed} end
Game._begin = function(i) beginMission(i) end
Game._explore = function() require('src.station').reset(); loadExplorerSprites(); explore.x, explore.y, explore.vy, explore.t = 100, 0, 0, 0; explore.repaired, explore.repairs, explore.campaign = false, 0, false; state = 'explore' end
Game._tp = function(x) explore.x = x end
Game._st = function() local S = require('src.station').s; return {room=S.room, d1=S.door[1], d2=S.door[2], d3=S.door[3], repairs=S.repairs, solved=S.solved, pages=S.pages, log=S.logRead, mode=S.mode, used=require('src.station').used(), sel=S.sel, x=explore.x} end
Game._sg = function() local S = require('src.signal').s; return {f=S.f, p=S.p, tf=S.c.tf, tp=S.c.tp, locked=S.locked, match=S.match or 0, mul=explore.nextMul or 1} end
Game._cm = function() local C = require('src.communications').s; return {room=C.room, checked=C.checked, repaired=C.repaired, d1=C.doors[1], d2=C.doors[2], mode=C.mode} end
Game._sgset = function(f,p) local S = require('src.signal').s; S.f, S.p = f, p end
Game._dis = function() local D = require('src.disembark').s; return {t=D.t or 0, active=D.active and 1 or 0} end
Game._title = function() state = 'title'; buildMenu() end
Game._forcegame = function() state = 'game'; paused = false end
Game._maxg = function(x1,x2)
  if x1>x2 then x1,x2=x2,x1 end
  local lo = 9999
  for x=x1-20,x2+20,4 do local g=groundAt(x); if g<lo then lo=g end end
  return lo
end
Game._beams = function()
  local out = {}
  for i,b in ipairs(mission().beams or {}) do out[i] = {x=b.x, st=beamState(b), u=(missionTime+b.phase)%b.period, period=b.period, on=b.on, warn=b.warn} end
  return out
end
Game._debris = function()
  local out = {}
  for i,d in ipairs(mission().debris or {}) do local x,y = debrisPos(d); out[i] = {x=x,y=y,soft=d.soft and true or false} end
  return out
end
return Game
'''
open(SP+"/game_dbg9.lua","w").write(src)
lua.execute(f'package.path = "{SP}/?.lua;"..package.path')
lua.execute(f'package.loaded["src.game"] = dofile("{SP}/game_dbg9.lua")')
def run(code):
    try: lua.execute(code); return None
    except Exception as e: return str(e)
err = run('dofile(ROOT.."/main.lua"); love.load()')
print("load:", err)
def dbg():
    t = lua.eval('require("src.game")._dbg()')
    return {k: t[k] for k in t}
def beams():
    t = lua.eval('require("src.game")._beams()')
    return [{k: t[i][k] for k in ('x','st','u','period','on','warn')} for i in range(1, len(t)+1)]
def debris():
    t = lua.eval('require("src.game")._debris()')
    return [{k: t[i][k] for k in ('x','y','soft')} for i in range(1, len(t)+1)]
PERF = {'max':0,'sum':0,'n':0}
def step(n=1, dt=1/30):
    for _ in range(n):
        lua.execute(f"PRIM=0; love.update({dt}); love.draw()")
        c = int(lua.eval('PRIM'))
        if dbg_state_game(): PERF['max']=max(PERF['max'],c); PERF['sum']+=c; PERF['n']+=1
def dbg_state_game():
    return lua.eval('require("src.game")._dbg().state') == 'game'
def key(k): lua.execute(f"love.keypressed('{k}')")
def hold(k,v): lua.execute(f"__hold('{k}',{'true' if v else 'false'})")
def clamp(v,a,b): return max(a,min(b,v))

# ---------------------------------------------------------------- 1. contenu (longueurs, ASCII)
data = open(root+"/src/data.lua").read()
problems = []
for f in ("data","i18n","text_fr","text_en","game","art","save"):
    if re.search(r'[^\x00-\x7f]', open(root+f"/src/{f}.lua").read()): problems.append(f"non-ASCII in {f}.lua")
def wrapcount(text, maxw=500, size=16):
    mc = maxw//size; lines=[]
    for para in (text+"\n").split("\n")[:-1]:
        if para=="": lines.append(""); continue
        cur=""
        for w in para.split():
            if cur=="": cur=w
            elif len(cur)+1+len(w)<=mc: cur+=" "+w
            else: lines.append(cur); cur=w
        lines.append(cur)
    return lines
lua.execute(f'DATA = dofile(ROOT.."/src/data.lua"); I18N = require("src.i18n")')
nm = int(lua.eval("#DATA.missions"))
ncards = 0
for lang in ("fr","en","pt","de","es","it"):
  lua.execute(f'I18N.setLang("{lang}")')
  for i in range(1, nm+1):
    m = lua.eval(f"I18N.mission({i})")
    name, obj = m['name'], m['objective']
    if len(name) > 20: problems.append(f"{lang} M{i} name too long {len(name)}: {name}")
    if len(obj) > 26: problems.append(f"{lang} M{i} objective too long {len(obj)}: {obj}")
    for kind in ('pre','post'):
        cards = m[kind]
        if cards is None: continue
        for j in range(1, len(cards)+1):
            c = cards[j]; title, body = c[1], c[2]; ncards += 1
            if len(title) > 21: problems.append(f"{lang} M{i} {kind}{j} title {len(title)}: {title}")
            wl = wrapcount(body)
            if len(wl) > 12: problems.append(f"{lang} M{i} {kind}{j} body {len(wl)} lines: {title}")
            for ln in wl:
                if len(ln) > 31: problems.append(f"{lang} M{i} {kind}{j} line too long: {ln}")
    rad = m['radio']
    if rad is not None:
        for j in range(1, len(rad)+1):
            if len(rad[j]) > 66: problems.append(f"{lang} M{i} radio {j} len {len(rad[j])}")
    nr = len(rad) if rad is not None else 0
    if nr != int(lua.eval(f"#(DATA.missions[{i}].radioT or {{}})")): problems.append(f"{lang} M{i} radio count {nr} != radioT")
    if int(lua.eval(f"#(I18N.mission({i}).pre or {{}})")) != int(lua.eval(f"#(DATA.art[{i}].pre)")): problems.append(f"{lang} M{i} pre count vs art")
lua.execute('I18N.setLang("fr")')
art_errs = lua.eval('''(function()
  local D = require("src.data"); local out = {}
  for i,m in ipairs(D.missions) do
    local a = D.art and D.art[i]
    if not a then out[#out+1] = "M"..i..": no art entry"
    else
      if #a.pre ~= #(require('src.i18n').mission(i).pre or {}) then out[#out+1] = "M"..i..": art.pre count "..#a.pre.." != cards "..#(require('src.i18n').mission(i).pre or {}) end
      if #a.post ~= #(require('src.i18n').mission(i).post or {}) then out[#out+1] = "M"..i..": art.post count "..#a.post.." != cards "..#(require('src.i18n').mission(i).post or {}) end
      for _,l in ipairs{a.pre, a.post} do for _,n in ipairs(l) do
        local f = io.open(ROOT.."/assets/scenes/"..n..".png", "rb")
        if not f then out[#out+1] = "M"..i..": missing image "..n else f:close() end
      end end
    end
  end
  return table.concat(out, "; ") end)()''')
if art_errs: problems.append("art: " + art_errs)
print(f"{nm} missions, {ncards} story cards; content problems:", problems or "none")
CONTENT = problems

# ---------------------------------------------------------------- 2. ecrans
errs=[]
for _ in range(3):
    e=run("love.draw()"); errs.append(e) if e else None
print("title draw errors:", errs or "none", "| menu items:", dbg()['menuN'])

def advance_to_game(limit=60):
    g=0
    while dbg()['state']!='game' and g<limit:
        key('space'); step(1); g+=1
    return g

# New game: menu "NOUVELLE PARTIE" is item 1 when no save
key('space'); step(1)           # -> instructions
print("after new:", dbg()['state'])
key('space'); step(1)           # -> pre cards of M1
print("pre cards M1:", dbg()['state'], dbg()['ncards'])

import ap
autopilot = ap.make_autopilot(dbg, beams, debris, step, hold, clamp, lambda a,b: int(lua.eval(f'require("src.game")._maxg({a},{b})')))
def run_station():
    """Parcourt la station Argo (4 pieces) avec les vraies touches : portes, relais, mini-jeu, journal, sortie."""
    G = 'require("src.game")'
    def st(): 
        t = lua.eval(G + '._st()'); return {k: t[k] for k in ('room','d1','d2','d3','repairs','solved','pages','log','mode','used','sel','x')}
    def tp(x): lua.execute(G + '._tp(%d)' % x)
    def check(cond, label):
        if not cond:
            print("STATION FAIL:", label, st()); FAILED.append("station: " + label)
        return cond
    ok = True
    def cross(dir_key):
        hold(dir_key, True); step(30); hold(dir_key, False); step(30)
    # piece 1 : mur invisible tant que la porte est fermee
    tp(300); hold('right', True); step(60); hold('right', False)
    ok &= check(st()['x'] <= 500.5 and st()['room'] == 1, "porte 1 fermee bloque le passage")
    key('a'); step(1)
    ok &= check(st()['d1'], "console du sas ouvre la porte 1")
    # on traverse la porte ouverte : la piece suivante commence sur sa porte de gauche
    hold('right', True); step(24); hold('right', False); step(30)
    ok &= check(st()['room'] == 2 and st()['x'] < 120, "traverser la porte 1 mene a la porte gauche de la piece 2")
    # piece 2 : relais dans le mauvais ordre puis le bon
    tp(270); key('a'); step(1)
    ok &= check(st()['repairs'] == 0, "relais 2 avant 1 refuse")
    tp(470); key('a'); step(1)
    ok &= check(not st()['d2'], "porte 2 verrouillee")
    for x in (190, 270, 350):
        tp(x); key('a'); step(1)
    ok &= check(st()['repairs'] == 3 and st()['d2'], "3 relais ouvrent la porte 2")
    tp(540); cross('right')
    ok &= check(st()['room'] == 3 and st()['x'] < 140, "passage en piece 3 par sa porte de gauche")
    # retour arriere : la porte de gauche ramene devant la porte de la piece precedente
    tp(60); hold('left', True); step(8); hold('left', False); step(30)
    ok &= check(st()['room'] == 2 and st()['x'] > 500, "retour piece 2 devant sa porte de droite")
    tp(540); cross('right')
    ok &= check(st()['room'] == 3, "retour piece 3")
    # piece 3 : notes puis mini-jeu
    for x in (120, 250):
        tp(x); key('a'); step(1)
    tp(470); key('a'); step(1)
    ok &= check(st()['mode'] == 'energy', "console ouvre le mini-jeu")
    # essai raté : BALISE + JOURNAL + SAS (6) mais sans lumiere -> pas resolu
    key('down'); step(1); key('a'); step(1)             # balise on (1)
    key('down'); key('down'); step(1); key('a'); step(1)  # journal on (3) -> 4
    key('up'); key('up'); key('up'); step(1); key('a'); step(1)  # sas on (2) -> 6
    ok &= check(st()['used'] == 6 and not st()['solved'], "6 unites sans lumiere : non resolu")
    key('down'); step(1); key('a'); step(1)             # balise off -> 5
    key('down'); step(1); key('a'); step(1)             # eclairage on -> 6
    ok &= check(st()['solved'] and st()['d3'] and st()['mode'] == 'walk', "sas+eclairage+journal resolvent")
    # surcharge refusee
    tp(540); cross('right')
    ok &= check(st()['room'] == 4, "passage en piece 4")
    # piece 4 : sortie verrouillee tant que le journal n'est pas lu
    tp(470); key('a'); step(1)
    ok &= check(st()['room'] == 4 and not st()['log'], "sortie verrouillee")
    for i in range(3):
        tp(300); key('a'); step(1)
    ok &= check(st()['pages'] == 3 and st()['log'], "journal en 3 pages")
    tp(470); key('a'); step(1)
    return ok

def run_signal(mi):
    """Mini-jeu d'accord du signal : touches reelles, puis alignement sur la cible, verrouillage, vol suivant."""
    G = 'require("src.game")'
    def sg():
        t = lua.eval(G + '._sg()'); return {k: t[k] for k in ('f','p','tf','tp','locked','match','mul')}
    ok = True
    s0 = sg(); step(2)
    hold('right', True); step(15); hold('right', False)
    s1 = sg()
    if not s1['f'] > s0['f'] + 0.1: print("SIGNAL FAIL: droite n'augmente pas la frequence", s0, s1); FAILED.append("signal freq"); ok = False
    hold('up', True); step(10); hold('up', False)
    s2 = sg()
    if abs(s2['p'] - s1['p']) < 0.05: print("SIGNAL FAIL: haut ne change pas la phase", s1, s2); FAILED.append("signal phase"); ok = False
    step(60)
    if sg()['locked']: print("SIGNAL FAIL: verrouille sans accord"); FAILED.append("signal lock early"); ok = False
    lua.execute(G + '._sgset(%f,%f)' % (s2['tf'], s2['tp']))
    step(50)
    if not sg()['locked'] or sg()['match'] < 0.9: print("SIGNAL FAIL: pas de verrouillage a l'accord", sg()); FAILED.append("signal lock"); ok = False
    step(80)
    d = dbg()
    if d['state'] != 'card': print("SIGNAL FAIL: pas de vol apres l'accord", d['state']); FAILED.append("signal exit"); ok = False
    return ok

def run_disembark(mi, natural):
    """Debarquement apres M3/M5/M9 : le temps avance, la touche d'action passe la scene, sinon elle se termine seule."""
    G = 'require("src.game")'
    t0 = lua.eval(G + '._dis().t'); step(60); t1 = lua.eval(G + '._dis().t')
    ok = True
    if not t1 > t0 + 1.0: print("DISEMBARK FAIL: le temps n'avance pas", t0, t1); FAILED.append("disembark time"); ok = False
    if natural:
        n = 0
        while dbg()['state'] == 'disembark' and n < 900: step(1); n += 1
        if n >= 900 or n < 150: print("DISEMBARK FAIL: duree anormale", n); FAILED.append("disembark length M%d" % mi); ok = False
    else:
        key('a'); step(2)
    want = {3: 'explore', 5: 'reactor', 9: 'explore'}.get(mi, 'signal')
    if dbg()['state'] != want: print("DISEMBARK FAIL: attendu", want, "obtenu", dbg()['state']); FAILED.append("disembark exit M%d" % mi); ok = False
    return ok

def run_comms():
    """M9 : explorer le sas, retablir le relais, reparer les connecteurs puis ouvrir l'accord du signal."""
    G = 'require("src.game")'
    def cm():
        t = lua.eval(G + '._cm()')
        return {k: t[k] for k in ('room','checked','repaired','d1','d2','mode')}
    def tp(x): lua.execute(G + '._tp(%d)' % x)
    ok = True
    def need(cond, label):
        nonlocal ok
        if not cond:
            print("COMMS FAIL:", label, cm(), dbg()['state'])
            FAILED.append("communications: " + label)
            ok = False
    # Salle 1 : examiner puis remettre le relais de securite sous tension.
    tp(470); key('e'); step(1)
    need(cm()['checked'] and dbg()['state']=='explore', "inspection du panneau")
    key('e'); step(1)
    need(cm()['d1'], "relais de securite retabli")
    hold('right', True); step(30); hold('right', False); step(25)
    need(cm()['room']==2, "passage vers le couloir technique")
    # Salle 2 : rebrancher le boitier central.
    tp(310); key('e'); step(1)
    need(cm()['repaired'] and cm()['d2'], "connecteurs rebranches")
    hold('right', True); step(30); hold('right', False); step(25)
    need(cm()['room']==3, "passage vers la salle de reception")
    # Salle 3 : interaction avec le recepteur ouvre le mini-jeu, sans le court-circuiter.
    tp(470); key('e'); step(1)
    need(dbg()['state']=='signal', "le recepteur lance le mini-jeu de signal")
    return ok

def run_reactor():
    """M5 : inserer le module, regler les trois bobines (A=1, B=3, C=2), demarrer le reacteur, puis M6."""
    ok = True
    def need(cond, label):
        nonlocal ok
        if not cond: print("REACTOR FAIL:", label, dbg()['state']); FAILED.append("reactor: " + label); ok = False
    for _ in range(6): key('right'); step(1)
    key('e'); step(1)                                   # module insere
    for _ in range(7): key('right'); step(1)
    key('e'); step(1)                                   # console
    key('e'); step(1)                                   # phases fausses : refus
    need(dbg()['state'] == 'reactor', "refus si phases fausses")
    for target in (1, 3, 2):
        for _ in range(target): key('up'); step(1)
        key('right'); step(1)
    key('e'); step(1)
    step(120)
    need(dbg()['state'] == 'card', "enchainement vers M6 apres le reacteur")
    return ok

results={}
advance_to_game()

# ---------------------------------------------------------------- 2b. physique d'atterrissage (hors plateforme)
def ship_state():
    t = lua.eval('require("src.game")._ship()'); return {k: t[k] for k in t}
def setship(**kw):
    items = ",".join(f"{k}={('true' if v is True else 'false' if v is False else v)}" for k,v in kw.items())
    lua.execute('require("src.game")._set({'+items+'})')
PHYS = []
def phys_land(label, angle, vy, vx=0.0, fuel=100, x=None, secs=8.0, takeoff=True):
    d = dbg(); pad_x = d['padx']
    gx = x if x is not None else min(560, pad_x + 160) if pad_x < 420 else pad_x - 160
    gy = lua.eval(f'require("src.game")._maxg({gx},{gx})')
    setship(x=gx, y=gy-60, vx=vx, vy=vy, angle=angle, fuel=fuel, resting=False, landed=False)
    contacts = 0; prev_vy = vy; rest_frames = 0; hist = []
    for _ in range(int(secs*30)):
        step(1); st = ship_state(); hist.append(st)
        if st['vy'] < 0 and prev_vy >= 0 and st['gy'] - st['y'] < 16: contacts += 1
        prev_vy = st['vy']
        if st['resting']: rest_frames += 1
    st = ship_state()
    rec = {"label": label, "rest_frames": rest_frames, "contacts": contacts, "angle": round(st['angle'],2), "hull": st['hull'], "failed": st['failed']}
    if takeoff and not st['failed'] and st['fuel'] > 0:
        gy0 = st['y']
        hold('up', True); step(60); hold('up', False)
        st2 = ship_state(); rec["lift"] = round(gy0 - st2['y'], 1)
    PHYS.append(rec); return rec
PHYS_PROBLEMS = []
LEAKS = {}
def run_physics():
    global badx, PHYS_PROBLEMS, LEAKS
    lua.execute('require("src.game")._begin(1)'); lua.execute('require("src.game")._forcegame()')
    for lab, ang, vy in (("plat", 0.0, 20), ("incline 0.25", 0.25, 20), ("incline 0.45", 0.45, 20), ("incline 0.6", 0.6, 20), ("incline 0.9", 0.9, 25), ("rapide", 0.0, 55), ("tres rapide", 0.0, 80)):
        r = phys_land(lab, ang, vy)
        print("PHYS", r)
    for lab, kw in (("fuel 0", dict(angle=0.0, vy=20, fuel=0, takeoff=False)), ("vx 60", dict(angle=0.0, vy=20, vx=60)), ("vx 90 incline", dict(angle=0.4, vy=30, vx=90)), ("renverse", dict(angle=2.5, vy=20))):
        r = phys_land(lab, **kw); print("PHYS", r)
    # balayage : poses a de nombreux x (bords de plateforme, pentes), sur les 18 missions ; re-decollage obligatoire
    badx = []; nsweep = 0
    for mi in range(1, nm+1):
        lua.execute(f'require("src.game")._begin({mi})')
        if dbg()['state'] != 'game': lua.execute('require("src.game")._forcegame()')
        wwid = int(dbg()['worldW'])
        for gx in range(30, wwid-30, 23):
            for ang, vx in ((0.0, 0), (0.35, 40), (-0.4, -50)):
                lua.execute(f'require("src.game")._begin({mi})'); lua.execute('require("src.game")._forcegame()')
                r = phys_land(f"M{mi} x{gx}", ang, 22, vx=vx, x=gx, secs=2.5); nsweep += 1
                st = ship_state()
                if st['landed']: continue                       # pose sur la plateforme finale : mission terminee, normal
                if r.get('lift', 999) < 60 or r['contacts'] > 3: badx.append((mi, gx, ang, vx, r))
    print("PHYS sweep:", nsweep, "poses,", len(badx), "problemes", [(b[0], b[1], b[2], b[4].get('lift'), b[4]['contacts']) for b in badx][:12])

    # ---------------------------------------------------------------- 2c. fuite memoire Lua en inactivite prolongee
    def lua_mem():
        lua.execute("collectgarbage('collect'); collectgarbage('collect')"); return float(lua.eval("collectgarbage('count')"))
    LEAKS = {}
    def leak_probe(label, setup, frames=3000):
        setup(); step(30); m0 = lua_mem()
        for _ in range(frames): step(1)
        m1 = lua_mem(); LEAKS[label] = round(m1-m0, 1)
        print("LEAK", label, "frames", frames, "delta KB", LEAKS[label], "| total KB", round(m1))
    lua.execute('require("src.game")._begin(1)'); lua.execute('require("src.game")._forcegame()')
    setship(x=300, y=100, vx=0, vy=0, angle=0, resting=False, landed=False)
    leak_probe("vol en cours (ship pose hors plateforme)", lambda: setship(x=200, y=lua.eval('require("src.game")._maxg(200,200)')-12, vx=0, vy=0))
    leak_probe("vol avec poussee et particules", lambda: hold('up', True), 600); hold('up', False)
    lua.execute('require("src.game")._explore()')
    leak_probe("station (explore) inactive", lambda: None)
    lua.execute('require("src.game")._title()')
    leak_probe("ecran titre inactif", lambda: None)
    PHYS_PROBLEMS = []
    for r in [x for x in PHYS if not x['label'].startswith('M')]:
        if r['label'] in ('incline 0.6', 'incline 0.9', 'renverse') and r['contacts'] > 0: PHYS_PROBLEMS.append(f"rebonds repetes sur pose inclinee: {r}")
        if r['label'] == 'fuel 0' and not r['failed']: PHYS_PROBLEMS.append(f"pose sans carburant : blocage non detecte: {r}")
        if r['label'] not in ('fuel 0',) and r.get('lift', 0) < 60: PHYS_PROBLEMS.append(f"redecollage impossible: {r}")
    if badx: PHYS_PROBLEMS.append(f"balayage de pose : {len(badx)} cas sans redecollage ou avec rebonds repetes, ex. {badx[0]}")
    for k, v in LEAKS.items():
        if v > 30: PHYS_PROBLEMS.append(f"fuite memoire Lua en inactivite ({k}) : +{v} Ko")
    print("PHYSIQUE/MEMOIRE:", PHYS_PROBLEMS or "ok")

if mode == "physics":
    run_physics()
    sys.exit(1 if PHYS_PROBLEMS else 0)
total_attempts=0
FAILED=[]
for mi in range(1, nm+1):
    ok=False
    for attempt in range(1,8):
        d=dbg()
        if d['mi']!=mi: break
        if not d['tgcheck']: print("!! mission",mi,"pads not on flat ground")
        res=autopilot(150, [0,1.5,3.0,4.5,6.0,7.5,9.0][attempt-1])
        total_attempts+=1
        if res[0] is True:
            d=res[1]; results[mi]=(attempt, round(d['fuel']), round(d['hull']), round(d['t'],1)); ok=True; break
        else:
            hold('left',False); hold('right',False); hold('up',False)
            results[mi]=(attempt,'fail',res[1]); key('v'); step(1)
    if not ok:
        print("mission",mi,"NOT completed by naive autopilot", results[mi]); FAILED.append(mi); break
    hold('left',False); hold('right',False); hold('up',False)
    key('space'); step(1)            # landed -> debrief
    st_deb = dbg()['state']
    seen=0; g=0
    while dbg()['state'] in ('debrief','card') and g<80:
        if dbg()['state']=='card': seen+=1
        key('space'); step(1); g+=1
    d=dbg()
    # M03 ouvre une sequence d'exploration avant M04 : reparer les 3 relais puis lire le terminal.
    # Simule les commandes joueur au lieu de sauter l'interlude narratif.
    if mi in (3, 5, 9):
        if d['state'] != 'disembark':
            print("expected disembark after M%d, got" % mi, d['state']); FAILED.append("disembark missing M%d" % mi)
        else:
            run_disembark(mi, mi == 5); d = dbg()
    if mi == 3 and d['state'] == 'explore':
        ok_st = run_station()
        d = dbg()
        if not ok_st or d['state'] != 'card' or d['cardIdx'] != 1:
            print("station interlude did not launch M04:", d['state'], d['mi'], d['cardIdx'])
            FAILED.append("station interlude")
    if mi == 9 and d['state'] == 'explore':
        run_comms(); d = dbg()
    if mi == 5 and d['state'] == 'reactor':
        run_reactor(); d = dbg()
    elif mi in (5, 9):
        if d['state'] != 'signal':
            print("expected signal mini-game after M%d, got" % mi, d['state']); FAILED.append("signal missing M%d" % mi)
        else:
            run_signal(mi); d = dbg()
    # entering next mission: pre cards counted inside 'seen'
    print(f"M{mi:02d}: attempts={results[mi][0]} fuel={results[mi][1]} hull={results[mi][2]} t={results[mi][3]}s | debrief={st_deb} cards_shown={seen} -> state={d['state']} mi={d['mi']}")
    if d['state']=='card':
        advance_to_game()
print("final:", dbg()['state'], "mi", dbg()['mi'], "menuN", dbg()['menuN'])
fs = lua.eval('__fs()'); print("save file:", {k: fs[k] for k in fs})
if mode != "noaudio":
    a = lua.eval('__aud()')
    print("audio loaded:", sorted(k for k in a['loaded']), "missing:", sorted(k for k in a['missing']) or "none")
    print("audio plays:", {k: a['plays'][k] for k in a['plays']})

if mode != "physics":
    run_physics()

# ---------------------------------------------------------------- 3. PC / langues / menu / capture
EXTRA = []
def check(c, msg):
    if not c: EXTRA.append(msg)
lua.execute('I18N.aka = false; I18N.kbTouched = false; I18N.setLang("fr")')
check(lua.eval('I18N.kb') == 'azerty', "PC fr should default to azerty")
check(lua.eval('I18N.t("hint2")') == 'ESPACE : OK    X : SON', "PC fr hint2: "+str(lua.eval('I18N.t("hint2")')))
lua.execute('I18N.setLang("en")')
check(lua.eval('I18N.kb') == 'qwerty', "PC en should follow qwerty")
check(lua.eval('I18N.t("card_next")') == 'SPACE : CONTINUE', "PC en card_next: "+str(lua.eval('I18N.t("card_next")')))
lua.execute('I18N.setKb("azerty", true); I18N.setLang("fr"); I18N.setLang("en")')
check(lua.eval('I18N.kb') == 'azerty', "explicit kb must not follow language")
lua.execute('I18N.aka = true; I18N.setKb("aka", true)')
check(lua.eval('I18N.t("card_next")') == 'A : CONTINUE', "AKA en card_next: "+str(lua.eval('I18N.t("card_next")')))
for aka, kb in ((False,"azerty"),(False,"qwerty"),(True,"aka")):
  for lang in ("fr","en","pt","de","es","it"):
    lua.execute(f'I18N.aka = {"true" if aka else "false"}; I18N.setKb("{kb}", true); I18N.setLang("{lang}")')
    # retour au titre puis parcours de tous les ecrans + menu systeme
    e = run('local G=require("src.game"); G.keypressed("escape"); G.keyreleased("escape")'); 
    check(e is None, f"menu open {aka}{kb}{lang}: {e}")
    for _ in range(14):
        e = run('local G=require("src.game"); G.keypressed("down"); love.draw()'); check(e is None, f"menu nav: {e}")
    for _ in range(4):
        e = run('local G=require("src.game"); G.keypressed("right"); love.draw()'); check(e is None, f"menu cycle: {e}")
    run('local G=require("src.game"); G.keypressed("escape"); G.keyreleased("escape")')
    # pages Commandes et Credits du menu, pause
    for nav in (1, 6):
        e = run('local G=require("src.game"); G.keypressed("escape","escape",false); G.keyreleased("escape")' + ' G.keypressed("down");'*nav + ' G.keypressed("space"); love.draw(); G.keypressed("space"); G.keypressed("escape","escape",false); G.keyreleased("escape")')
        check(e is None, f"menu page {nav} {lang}: {e}")
    for st in ("title","instructions","card","game","debrief"):
        e = run('love.draw()'); check(e is None, f"draw {st}: {e}")
# captures : F12, appui long, menu
n0 = int(lua.eval('#SHOTS'))
run('local G=require("src.game"); G.keypressed("f12", "f12", false)')
check(int(lua.eval('#SHOTS')) == n0+1, "F12 screenshot")
run('local G=require("src.game"); G.keypressed("escape","escape",false)'); step(30)
run('local G=require("src.game"); G.keyreleased("escape")')
check(int(lua.eval('#SHOTS')) == n0+2, "long MENU screenshot")
check(not lua.eval('require("src.game")._dbg().sysOpen'), "long MENU must not open the menu")
run('local G=require("src.game"); G.keypressed("escape","escape",false); G.keyreleased("escape"); G.keypressed("down"); G.keypressed("down"); G.keypressed("right"); G.keypressed("escape","escape",false); G.keyreleased("escape")')
fsd = lua.eval('__fs()')['lunar_courier.sav']
if fsd is not None: check('shot=2' in fsd and 'lang=' in fsd and 'kb=' in fsd, "settings saved: "+repr(fsd))
# clavier azerty : q/z/d pilotent
lua.execute('I18N.setKb("azerty", true)')
check(lua.eval('table.concat(I18N.moveKeys().up, ",")') == 'up,z', "azerty up keys")
lua.execute('I18N.setKb("qwerty", true)')
check(lua.eval('table.concat(I18N.moveKeys().up, ",")') == 'up,w', "qwerty up keys")
lua.execute('I18N.setKb("aka", true); I18N.aka = true; I18N.setLang("fr")')
print("pc/lang/menu/screenshot checks:", EXTRA or "ok")
v = lua.eval('__viol()')
print("VIOLATIONS:", {k: v[k] for k in v} or "none")
img = lua.eval('__img()')
problems = []
if mode != "noaudio":
    loaded = {k: (img['loaded'][k]['w'], img['loaded'][k]['h']) for k in img['loaded']}
    print("images loaded:", len(loaded), "| draws:", img['drawn'], "| missing:", sorted(k for k in img['missing']) or "none")
    for k,(w,h) in sorted(loaded.items()):
        if ('/scenes/' in k and (w < 320 or h != 75)) or ('/portraits/' in k and (w != 48 or h != 48)): problems.append(f"image {k} is {w}x{h} (need width>=320, height 75)")
    miss = sorted(k for k in img['missing'])
    if miss: problems.append("missing images: "+", ".join(miss))
    if img['drawn'] == 0: problems.append("no image was ever drawn")
else:
    print("images: none (fallback banner path) | draws:", img['drawn'])
for k in v: problems.append("violation: "+str(k))
if FAILED: problems.append("missions not completed: "+str(FAILED))
for x in EXTRA: problems.append("extra: "+x)
for x in PHYS_PROBLEMS: problems.append("physique: "+x)
if CONTENT: problems.append("content: "+str(CONTENT))
if problems:
    print("TEST PROBLEMS:"); [print("  -", x) for x in problems]; sys.exit(1)
print(f"primitives/frame in game: avg={PERF['sum']//max(1,PERF['n'])} max={PERF['max']}")
print("ALL OK")
