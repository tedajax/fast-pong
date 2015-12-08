function love.conf(t)
    t.identity = "FastPong"
    t.version = "0.9.2"

    t.window.vsync = true
    t.window.width = 800
    t.window.height = 600

    Config = {}
    Config.player1 = {
        up = "w",
        down = "s"
    }
    Config.player2 = {
        up = "up",
        down = "down"
    }
    Config.maxScore = 11
end