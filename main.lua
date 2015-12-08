require 'paddle'
require 'ball'

function love.load()
    math.randomseed(os.time())

    ScanlinePosition = 0

    Game = {}

    Game.maxScore = Config.maxScore

    Game.p1_score = function(self)
        self.p1Score = self.p1Score + 1
        if self.p1Score >= self.maxScore then
            Game:game_over("P1")
        end
        self.ball:reset()
        self.isReady = true
        Score:play()
    end

    Game.p2_score = function(self)
        self.p2Score = self.p2Score + 1
        if self.p2Score >= self.maxScore then
            Game:game_over("P2")
        end
        self.ball:reset()
        self.isReady = true
        Score:play()
    end

    Game.game_over = function(self, player)
        self.winner = player
        Win:play()
    end

    Timescale = 1

    local hw = love.graphics.getWidth() / 2
    local hh = love.graphics.getHeight() / 2

    Game.leftPaddle = create_paddle(-hw + 25, Config.player1.up, Config.player1.down)
    Game.rightPaddle = create_paddle(hw - 25, Config.player2.up, Config.player2.down)

    local bounds = {
        l = -hw,
        r = hw,
        t = -hh,
        b = hh,
    }

    Game.ball = create_ball(bounds, Game.leftPaddle, Game.rightPaddle)

    Game.p1Score = 0
    Game.p2Score = 0

    Game.isReady = true
    Game.winner = nil

    love.audio.setPosition(0, 0, -1)

    BGSound = love.audio.newSource("bg.wav")
    BGSound:setLooping(true)
    BGSound:setVolume(0.5)
    BGSound:play()

    PaddleHit = love.audio.newSource("paddlehit.wav")
    SideHit = love.audio.newSource("sidehit.wav")
    Score = love.audio.newSource("score.wav")
    Win = love.audio.newSource("win.wav")

    ScoreFont = love.graphics.newFont("pressstart.ttf", 24)
    love.graphics.setFont(ScoreFont)
end

function love.keypressed(keycode)
    if keycode == "escape" then
        love.event.quit()
    end

    if keycode == "f" then
        Game:game_over("P1")
    end

    if Game.isReady and keycode == "return" then
        Game.isReady = false
        Game.ball:start()
    end

    if Game.winner ~= nil and keycode == "return" then
        Game.isReady = true
        Game.winner = nil
        Game.p1Score = 0
        Game.p2Score = 0
        Game.ball:reset()
        Game.leftPaddle.y = 0
        Game.rightPaddle.y = 0
    end
end

function love.update(dt)
    local delta = dt * Timescale

    if Game.winner == nil then
        Game.leftPaddle:update(delta)
        Game.rightPaddle:update(delta)
        Game.ball:update(delta)

        BGSound:setPitch(0.5 + Game.ball:normalized_speed())
    end

    ScanlinePosition = ScanlinePosition + 0 * dt
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    love.graphics.setColor(127, 127, 127)
    love.graphics.rectangle("fill", -5, -love.graphics.getHeight() / 2, 10, love.graphics.getHeight())

    Game.leftPaddle:render()
    Game.rightPaddle:render()
    Game.ball:render()

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(Game.p1Score, -200, -love.graphics.getHeight() / 2 + 50)
    love.graphics.print(Game.p2Score, 200, -love.graphics.getHeight() / 2 + 50)

    if Game.winner ~= nil then
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", -115, -55, 230, 80)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", -110, -50, 220, 70)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf(Game.winner .. " Wins!", -100, -20, 200, "center")
    end

    love.graphics.pop()

    for i = -16, love.graphics.getHeight(), 4 do
        love.graphics.setColor(0, 0, 0, math.random(20, 50))
        love.graphics.rectangle("fill", 0, i + math.fmod(ScanlinePosition, 8), love.graphics.getWidth(), math.random(1, 2))
    end

    for i = -16, love.graphics.getHeight(), 4 do
        love.graphics.setColor(0, 0, 0, math.random(20, 50))
        love.graphics.rectangle("fill", i + math.fmod(ScanlinePosition, 8), 0, math.random(1, 2), love.graphics.getHeight())
    end

    for i = 1, 100 do
        love.graphics.setColor(255, 255, 255, math.random(20, 50))
        love.graphics.rectangle("fill", math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight()), 2, 2)
    end
end