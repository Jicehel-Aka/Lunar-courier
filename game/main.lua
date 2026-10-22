-- LUNAR COURIER v0.8 - AKA-Love / LOVE 11.x
-- Aucune mise a l'echelle locale : la surface virtuelle est 640x480.
-- Le fond est entierement redessine a chaque image (pas de love.graphics.clear).
local Game = require("src.game")

function love.load()
    if love.graphics.setBackgroundColor then
        love.graphics.setBackgroundColor(0.02, 0.04, 0.08)
    end
    Game.load()
end

function love.update(dt) Game.update(dt) end
function love.draw() Game.draw() end
function love.keypressed(key) Game.keypressed(key) end
function love.keyreleased(key) Game.keyreleased(key) end
function love.focus(focused) Game.focus(focused) end
