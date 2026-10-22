-- LUNAR COURIER v0.9 - audio. Tout est protege par pcall : si une fonction ou un fichier
-- manque (runtime AKA-Love incomplet), le jeu continue en silence. WAV 16 bits mono.
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

function A.load()
    local names = {pickup=0.8, pad=0.8, land=0.9, hit=0.9, bounce=0.7, menu=0.6, card=0.5, fail=0.9, warn=0.6}
    for n, v in pairs(names) do A.sfx[n] = make("sfx/"..n..".wav", false, v) end
    A.sfx.thrust = make("sfx/thrust.wav", true, 0.5)
end

function A.play(name)
    local s = A.sfx[name]
    if not s then return end
    if s.stop then try(s.stop, s) end
    if s.play then try(s.play, s) end
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
