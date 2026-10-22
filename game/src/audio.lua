-- LUNAR COURIER - audio. Tout est protege par pcall : si une fonction ou un fichier
-- manque (runtime AKA-Love incomplet), le jeu continue en silence. WAV 16 bits mono 44100 Hz (taux fixe du lecteur AKA).
local A = {sfx = {}, music = nil, musicName = nil, musicOn = true, thrusting = false}

local function try(f, ...)
    local ok, r = pcall(f, ...)
    if ok then return r end
    return nil
end

local function make(path, loop, vol)
    if not (love and love.audio and love.audio.newSource) then return nil end
    local s = try(love.audio.newSource, path, "static")
    if not s then return nil end
    if loop and s.setLooping then try(s.setLooping, s, true) end
    if vol and s.setVolume then try(s.setVolume, s, vol) end
    return s
end

-- Effets ponctuels : une Source NEUVE a chaque lecture. Le runtime AKA-Love memorise le numero de piste
-- d'une Source ; rejouer ou arreter une Source dont la piste a ete reprise entre-temps (par la musique,
-- par exemple) couperait cette autre piste. Une Source neuve n'a pas de piste memorisee.
local SFX_VOL = {pickup=0.8, pad=0.8, land=0.9, hit=0.9, bounce=0.7, menu=0.6, card=0.5, fail=0.9, warn=0.6}

function A.load()
    for n in pairs(SFX_VOL) do
        A.sfx[n] = make("sfx/"..n..".wav", false, SFX_VOL[n]) and true or nil   -- verifie seulement que le fichier existe
    end
    A.sfx.thrust = make("sfx/thrust.wav", true, 0.5)
end

function A.play(name)
    if not A.sfx[name] then return end
    local s = make("sfx/"..name..".wav", false, SFX_VOL[name])
    if s and s.play then try(s.play, s) end
end

-- Boucle du propulseur : start/stop uniquement sur changement d'etat
function A.thrust(on)
    local s = A.sfx.thrust
    if on == A.thrusting then return end
    A.thrusting = on
    if not s then return end
    if on then if s.play then try(s.play, s) end
    else if s.stop then try(s.stop, s) end end
end

function A.setMusic(name)
    -- Ne pas recreer une source a chaque frame si l audio n est pas disponible.
    -- Le nom est invalide seulement apres un changement explicite de musique.
    if name == A.musicName then return end
    if A.music then
        if A.music.stop then try(A.music.stop, A.music) end
        A.music = nil
        collectgarbage("collect")
    end
    A.musicName = name
    if not A.musicOn or not name then return end
    A.music = make("mus/"..name..".wav", true, 0.45)
    if A.music and A.music.play then try(A.music.play, A.music) end
end

function A.toggleMusic()
    A.musicOn = not A.musicOn
    local n = A.musicName
    if not A.musicOn then
        if A.music then
            if A.music.stop then try(A.music.stop, A.music) end
            A.music = nil
            collectgarbage("collect")
        end
    else
        A.musicName = nil
        A.setMusic(n)
    end
    return A.musicOn
end

-- Silence total (pause, retour au titre)
function A.silenceThrust() A.thrust(false) end

return A
