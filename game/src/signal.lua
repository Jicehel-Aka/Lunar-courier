-- Mini-jeu "accorder le signal" (missions 5 et 9).
-- Deux courbes : la cible (turquoise) et la votre (orange). GAUCHE/DROITE regle la frequence,
-- HAUT/BAS regle la phase. Quand elles se superposent assez longtemps, le signal se verrouille.
-- Indices a l'ecran : jauge de signal et sens de correction de la frequence.
-- Rectangles uniquement, texte ASCII, aucune entree autre que la croix directionnelle.
local Sg = {}

local CFG = {
    [5] = {title="SAS DU COEUR", intro="Le sas attend le code du module. Accordez votre signal sur le sien.",
           done="Le sas reconnait le code. LUNA : consommation reduite de 15 % au prochain vol.",
           tf=3.0, tp=0.30, f0=1.5, p0=0.0, tol=0.16, hint=true, bonus=0.85},
    [9] = {title="MESSAGE DE VARGA", intro="Le message est brouille. Accordez le recepteur sur la face cachee.",
           done="Message recu : 'Apporte-moi de l'energie.' LUNA : consommation reduite de 20 %.",
           tf=4.4, tp=0.65, f0=5.6, p0=0.10, tol=0.12, hint=true, bonus=0.80},
}
Sg.CFG = CFG

local FREQ_SPEED, PHASE_SPEED = 0.9, 0.45
local HOLD = 1.4          -- secondes de superposition necessaires
local N = 58              -- points par courbe
local X0, STEP = 91, 8

local st = {active=false}
Sg.s = st

function Sg.start(i)
    local c = CFG[i]
    st.active, st.mission, st.c = true, i, c
    st.f, st.p, st.t, st.hold, st.locked, st.fin = c.f0, c.p0, 0, 0, false, 0
    st.match = 0
end

function Sg.has(i) return CFG[i] ~= nil end

local function wave(f, p, x) return math.sin(2 * math.pi * (f * x + p)) end

-- Ecart moyen entre les deux courbes (0 = identiques, jusqu'a 2).
local function gap(f, p, c)
    local sum = 0
    for k = 0, 23 do
        local x = k / 23
        sum = sum + math.abs(wave(f, p, x) - wave(c.tf, c.tp, x))
    end
    return sum / 24
end
Sg.gap = gap

-- keys : {f=-1/0/1, p=-1/0/1}. Retourne true quand le mini-jeu est termine (apres le verrouillage).
function Sg.update(dt, kf, kp)
    if not st.active then return false end
    st.t = st.t + dt
    local c = st.c
    if st.locked then
        st.fin = st.fin + dt
        return st.fin >= 2.2
    end
    st.f = math.max(1, math.min(6, st.f + kf * FREQ_SPEED * dt))
    st.p = (st.p + kp * PHASE_SPEED * dt) % 1
    local g = gap(st.f, st.p, c)
    st.gap = g
    st.match = math.max(0, math.min(1, 1 - g / 1.2))
    -- tolerance elargie apres une minute pour ne jamais bloquer le joueur
    local tol = c.tol * (st.t > 60 and 1.5 or 1)
    if g <= tol then st.hold = st.hold + dt else st.hold = math.max(0, st.hold - dt * 2) end
    if st.hold >= HOLD then st.locked = true end
    return false
end

function Sg.bonus() return st.c and st.c.bonus or 1 end

local function wrapText(text, n)
    local lines, cur = {}, ""
    for word in text:gmatch("%S+") do
        if #cur > 0 and #cur + 1 + #word > n then lines[#lines + 1] = cur; cur = word
        else cur = (#cur > 0) and (cur.." "..word) or word end
    end
    if #cur > 0 then lines[#lines + 1] = cur end
    return lines
end

-- ui : color, rect, panel, f16, f24
function Sg.draw(ui)
    local g = love.graphics
    local c = st.c
    -- fond : seulement les marges, le cadre couvre le reste (pas de surdessin)
    ui.color(3, 8, 19); ui.rect(0, 0, 640, 24); ui.rect(0, 456, 640, 24); ui.rect(0, 24, 40, 432); ui.rect(600, 24, 40, 432)
    ui.panel(40, 24, 560, 432)
    g.setFont(ui.f24)
    ui.color(135, 239, 231); g.printf("ACCORDER LE SIGNAL", 40, 40, 560, "center")
    g.setFont(ui.f16)
    ui.color(255, 177, 78); g.printf(c.title, 40, 74, 560, "center")
    -- ecran des courbes
    ui.color(9, 23, 40); ui.rect(80, 104, 480, 170)
    ui.color(30, 70, 84); ui.rect(80, 189, 480, 1)
    for k = 1, 5 do ui.color(18, 44, 58); ui.rect(80 + k * 80, 104, 1, 170) end
    for k = 0, N - 1 do
        local x = k / (N - 1)
        local yt = 189 - math.floor(wave(c.tf, c.tp, x) * 70)
        ui.color(60, 190, 190); ui.rect(X0 + k * STEP - 3, yt - 3, 6, 6)
    end
    for k = 0, N - 1 do
        local x = k / (N - 1)
        local yp = 189 - math.floor(wave(st.f, st.p, x) * 70)
        if st.locked then ui.color(120, 255, 200) else ui.color(255, 170, 60) end
        ui.rect(X0 + k * STEP - 2, yp - 2, 4, 4)
    end
    -- jauge de signal (20 cases)
    ui.color(214, 225, 230); g.printf("SIGNAL", 80, 290, 120, "left")
    local cells = math.floor((st.match or 0) * 20 + 0.5)
    for k = 1, 20 do
        if k <= cells then
            if st.locked then ui.color(120, 255, 200) elseif k > 16 then ui.color(255, 190, 79) else ui.color(75, 220, 184) end
        else ui.color(25, 55, 70) end
        ui.rect(200 + (k - 1) * 18, 290, 14, 18)
    end
    -- indices
    ui.color(206, 222, 230)
    local msg
    if st.locked then msg = c.done
    elseif (st.t or 0) < 6 then msg = c.intro
    elseif c.hint then
        if math.abs(st.f - c.tf) > 0.12 then
            msg = st.f > c.tf and "FREQUENCE TROP HAUTE : ralentissez (gauche)." or "FREQUENCE TROP BASSE : accelerez (droite)."
        elseif st.gap and st.gap > c.tol then msg = "Bonne frequence. Ajustez la phase (haut/bas)."
        else msg = "Ne bougez plus..." end
    end
    local lines = wrapText(msg, 30)
    for i = 1, math.min(3, #lines) do g.printf(lines[i], 70, 326 + (i - 1) * 22, 500, "left") end
    ui.color(255, 190, 98)
    g.printf("GAUCHE/DROITE : FREQUENCE", 70, 400, 500, "left")
    g.printf("HAUT/BAS : PHASE", 70, 422, 500, "left")
end

return Sg
