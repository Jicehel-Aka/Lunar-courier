-- LUNAR COURIER - sauvegarde (love.filesystem.read/write, protege par pcall).
-- Fichier texte "cle=valeur". Sur AKA-Love l'ecriture n'atteint la carte SD qu'a la fermeture,
-- love.filesystem.write s'en charge. Si la sauvegarde est impossible, le jeu continue sans.
local S = {next = 1, best = 1, music = 1, shot = 0, lang = nil, kb = nil, ranks = string.rep("0", 18), unlockAll = false, ok = false}
local FILE = "lunar_courier.sav"
local NUM = {next = true, best = true, music = true, shot = true}

function S.load()
    local ok, data = pcall(function()
        if love.filesystem and love.filesystem.read then return (love.filesystem.read(FILE)) end
        return nil
    end)
    if ok and type(data) == "string" then
        for k, v in data:gmatch("(%a+)=(%w+)") do
            if NUM[k] then S[k] = tonumber(v) or S[k]
            elseif k == "lang" or k == "kb" then S[k] = v
            elseif k == "ranks" and #v == 18 then S.ranks = v end
        end
    end
    if S.next < 1 then S.next = 1 end
    if S.best < S.next then S.best = S.next end
end

function S.save()
    local text = "next="..S.next.."\nbest="..S.best.."\nmusic="..S.music.."\nshot="..S.shot.."\nranks="..S.ranks.."\n"
    if S.lang then text = text.."lang="..S.lang.."\n" end
    if S.kb then text = text.."kb="..S.kb.."\n" end
    local ok, r = pcall(function()
        if love.filesystem and love.filesystem.write then return love.filesystem.write(FILE, text) end
        return false
    end)
    S.ok = ok and r ~= false and r ~= nil
    return S.ok
end

return S
