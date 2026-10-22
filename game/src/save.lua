-- LUNAR COURIER v0.9 - sauvegarde (love.filesystem.read/write, protege par pcall).
-- Fichier texte "cle=valeur". Sur AKA-Love l'ecriture n'atteint la carte SD qu'a la fermeture,
-- love.filesystem.write s'en charge. Si la sauvegarde est impossible, le jeu continue sans.
local S = {next = 1, best = 1, music = 1, unlockAll = false, ok = false}
local FILE = "lunar_courier.sav"

function S.load()
    local ok, data = pcall(function()
        if love.filesystem and love.filesystem.read then return (love.filesystem.read(FILE)) end
        return nil
    end)
    if ok and type(data) == "string" then
        for k, v in data:gmatch("(%a+)=(%d+)") do
            if k == "next" or k == "best" or k == "music" then S[k] = tonumber(v) end
        end
    end
    if S.next < 1 then S.next = 1 end
    if S.best < S.next then S.best = S.next end
end

function S.save()
    local text = "next="..S.next.."\nbest="..S.best.."\nmusic="..S.music.."\n"
    local ok, r = pcall(function()
        if love.filesystem and love.filesystem.write then return love.filesystem.write(FILE, text) end
        return false
    end)
    S.ok = ok and r ~= false and r ~= nil
    return S.ok
end

return S
