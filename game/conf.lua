-- LUNAR COURIER v0.9 - AKA-Love / LOVE 11.x
function love.conf(t)
    t.identity = "lunar-courier"
    t.window.title = "LUNAR COURIER"
    -- Surface virtuelle 640x480 = exactement 2x l'ecran AKA (320x240).
    t.window.width = 640
    t.window.height = 480
    t.window.resizable = false
    t.window.vsync = 1
    t.console = false
end
