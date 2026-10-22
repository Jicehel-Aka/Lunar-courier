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
love = {graphics={}, keyboard={}, timer={}}
VIOL = {}
local function viol(msg) VIOL[msg] = (VIOL[msg] or 0) + 1 end
local curSize = 16
local function chk(name, n, min) if n < min then error(name.." called with "..n.." args (need >="..min..")", 3) end end
local function isnum(...) for i=1,select('#',...) do if type(select(i,...))~="number" then return false end end return true end
function love.graphics.rectangle(mode,x,y,w,h) chk("rectangle",select('#',mode,x,y,w,h),5)
  if not isnum(x,y,w,h) then error("rectangle non-number",2) end end
function love.graphics.circle(mode,x,y,r) chk("circle",select('#',mode,x,y,r),4) end
function love.graphics.line(...) chk("line",select('#',...),4) end
function love.graphics.polygon(mode,...)
  local a={...}; if #a<6 then error("polygon <3 pts",2) end
  local n=#a/2; local sign=0
  for i=0,n-1 do
    local x1,y1=a[2*i+1],a[2*i+2]; local j=(i+1)%n; local k=(i+2)%n
    local x2,y2=a[2*j+1],a[2*j+2]; local x3,y3=a[2*k+1],a[2*k+2]
    local cr=(x2-x1)*(y3-y2)-(y2-y1)*(x3-x2)
    if math.abs(cr)>1e-9 then local s=cr>0 and 1 or -1; if sign==0 then sign=s elseif s~=sign then viol("CONCAVE polygon: "..table.concat(a,",")) break end end
  end
end
function love.graphics.print(t,x,y) chk("print",select('#',t,x,y),3)
  if type(t)~="string" then error("print non-string",2) end
  if x + #t*curSize > 640 then viol("print overflow x: '"..t.."' x="..x.." size="..curSize) end
  if y + curSize > 480 then viol("print overflow y: '"..t.."'") end end
function love.graphics.printf(t,x,y,limit,align) chk("printf",select('#',t,x,y,limit,align),5)
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
          g=m.gravity, cruise=mission().cruise or 200, msg=message, mt=messageTimer, cardIdx=cardIdx, ncards=cardList and #cardList or 0, wind=windCur,
          menuN=#menu, menuSel=menuSel, musicName=Audio.musicName, musicOn=Audio.musicOn,
          tgcheck=(function() local ok=true for i,p in ipairs(pads) do for x=p.x-PAD_HALF-8,p.x+PAD_HALF+8,4 do if groundAt(x)~=p.y then ok=false end end end return ok end)()}
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
def step(n=1, dt=1/30):
    for _ in range(n): lua.execute(f"love.update({dt}); love.draw()")
def key(k): lua.execute(f"love.keypressed('{k}')")
def hold(k,v): lua.execute(f"__hold('{k}',{'true' if v else 'false'})")
def clamp(v,a,b): return max(a,min(b,v))

# ---------------------------------------------------------------- 1. contenu (longueurs, ASCII)
data = open(root+"/src/data.lua").read()
problems = []
if re.search(r'[^\x00-\x7f]', data): problems.append("non-ASCII in data.lua")
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
lua.execute(f'DATA = dofile(ROOT.."/src/data.lua")')
nm = int(lua.eval("#DATA.missions"))
ncards = 0
for i in range(1, nm+1):
    m = lua.eval(f"DATA.missions[{i}]")
    name, obj = m['name'], m['objective']
    if len(name) > 20: problems.append(f"M{i} name too long {len(name)}: {name}")
    if len(obj) > 26: problems.append(f"M{i} objective too long {len(obj)}: {obj}")
    for kind in ('pre','post'):
        cards = m[kind]
        if cards is None: continue
        for j in range(1, len(cards)+1):
            c = cards[j]; title, body = c[1], c[2]; ncards += 1
            if len(title) > 21: problems.append(f"M{i} {kind}{j} title {len(title)}: {title}")
            wl = wrapcount(body)
            if len(wl) > 12: problems.append(f"M{i} {kind}{j} body {len(wl)} lines: {title}")
            for ln in wl:
                if len(ln) > 31: problems.append(f"M{i} {kind}{j} line too long: {ln}")
    rad = m['radio']
    if rad is not None:
        for j in range(1, len(rad)+1):
            if len(rad[j]['text']) > 66: problems.append(f"M{i} radio {j} len {len(rad[j]['text'])}")
art_errs = lua.eval('''(function()
  local D = require("src.data"); local out = {}
  for i,m in ipairs(D.missions) do
    local a = D.art and D.art[i]
    if not a then out[#out+1] = "M"..i..": no art entry"
    else
      if #a.pre ~= #(m.pre or {}) then out[#out+1] = "M"..i..": art.pre count "..#a.pre.." != cards "..#(m.pre or {}) end
      if #a.post ~= #(m.post or {}) then out[#out+1] = "M"..i..": art.post count "..#a.post.." != cards "..#(m.post or {}) end
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
autopilot = ap.make_autopilot(dbg, beams, debris, step, hold, clamp)
results={}
advance_to_game()
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
        print("mission",mi,"NOT completed by naive autopilot", results[mi]); FAILED.append(mi); lua.execute(f'require("src.game")._goto({mi+1})') if mi<nm else None; continue
    hold('left',False); hold('right',False); hold('up',False)
    key('space'); step(1)            # landed -> debrief
    st_deb = dbg()['state']
    seen=0; g=0
    while dbg()['state'] in ('debrief','card') and g<30:
        if dbg()['state']=='card': seen+=1
        key('space'); step(1); g+=1
    d=dbg()
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
v = lua.eval('__viol()')
print("VIOLATIONS:", {k: v[k] for k in v} or "none")
img = lua.eval('__img()')
problems = []
if mode != "noaudio":
    loaded = {k: (img['loaded'][k]['w'], img['loaded'][k]['h']) for k in img['loaded']}
    print("images loaded:", len(loaded), "| draws:", img['drawn'], "| missing:", sorted(k for k in img['missing']) or "none")
    for k,(w,h) in sorted(loaded.items()):
        if w < 320 or h != 75: problems.append(f"image {k} is {w}x{h} (need width>=320, height 75)")
    miss = sorted(k for k in img['missing'])
    if miss: problems.append("missing images: "+", ".join(miss))
    if img['drawn'] == 0: problems.append("no image was ever drawn")
else:
    print("images: none (fallback banner path) | draws:", img['drawn'])
for k in v: problems.append("violation: "+str(k))
if FAILED: problems.append("missions not completed: "+str(FAILED))
if CONTENT: problems.append("content: "+str(CONTENT))
if problems:
    print("TEST PROBLEMS:"); [print("  -", x) for x in problems]; sys.exit(1)
print("ALL OK")
