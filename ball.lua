function create_ball(bounds, leftpaddle, rightpaddle)
    local self = {}

    self.baseX = 0
    self.baseY = 0

    self.x = self.baseX
    self.y = self.baseY

    self.bounds = bounds
    self.leftPaddle = leftpaddle
    self.rightPaddle = rightpaddle

    self.width = 10
    self.height = 10

    self.speed = 0
    self.minSpeed = 400
    self.maxSpeed = 1000
    self.speedDecay = 10
    self.angle = 0

    self.oldX = 0
    self.oldY = 0

    self.oldPositions = {}
    self.maxOlds = 5
    for i = 1, self.maxOlds do
        self.oldPositions[i] = { x = 0, y = 0 }
    end

    self.afterImageTimer = 0
    self.afterImageTime = 0.05

    self.maxPaddleBounceAngle = 140

    self.reset = function(self)
        self.x = self.baseX
        self.y = self.baseY
        self.speed = 0
    end

    self.start = function(self)
        local direction = math.random(0, 1)
        if direction == 0 then
            self.angle = math.random(120, 240)
        else
            self.angle = math.random(-60, 60)
        end
        self.speed = 400
    end

    self.bounce_vertical = function(self)
        self.angle = math.fmod(360 - self.angle, 360)
    end

    self.bounce_horizontal = function(self, scalar, direction)
        local angle = self.maxPaddleBounceAngle / 2 * scalar

        if direction < 0 then
            angle = angle + 180
        else
            angle = 360 - angle
        end

        self.angle = math.fmod(angle, 360)
    end

    self.normalized_speed = function(self)
        return self.speed / self.maxSpeed
    end

    self.update = function(self, dt)
        for i = self.maxOlds, 2, -1 do
            self.oldPositions[i].x = self.oldPositions[i - 1].x
            self.oldPositions[i].y = self.oldPositions[i - 1].y
        end
        self.oldPositions[1].x = self.x
        self.oldPositions[1].y = self.y

        if self.x > self.bounds.r + self.width / 2 then
            Game:p1_score()
        end

        if self.x < self.bounds.l - self.width / 2 then
            Game:p2_score()
        end

        if self.y < self.bounds.t + self.height / 2 then
            self.y = self.bounds.t + self.height / 2
            self.angle = math.fmod(360 - self.angle, 360)
            SideHit:play()
        end

        if self.y > self.bounds.b - self.height / 2 then
            self.y = self.bounds.b - self.height / 2
            self.angle = math.fmod(360 - self.angle, 360)
            SideHit:play()
        end

        local hitLeft, leftDiff = self.leftPaddle:ballHitPoint(self)
        local hitRight, rightDiff = self.rightPaddle:ballHitPoint(self)

        if hitLeft then
            self.x = self.leftPaddle:right() + self.width / 2
            self:bounce_horizontal(leftDiff, 1)
            self.speed = self.speed + 200
            PaddleHit:play()
        end

        if hitRight then
            self.x = self.rightPaddle:left() - self.width / 2
            self:bounce_horizontal(rightDiff, -1)
            self.speed = self.speed + 200
            PaddleHit:play()
        end

        if self.speed > self.minSpeed then
            self.speed = self.speed - self.speedDecay * dt
            if self.speed < self.minSpeed then
                self.speed = self.minSpeed
            end
        end

        if self.speed > self.maxSpeed then
            self.speed = self.maxSpeed
        end

        local rads = math.rad(self.angle)
        local velx = math.cos(rads) * self.speed * dt
        local vely = math.sin(rads) * self.speed * dt
        self.x = self.x + velx
        self.y = self.y + vely
    end

    self.render = function(self)
        local hw, hh = self.width / 2, self.height / 2

        for i = self.maxOlds, 1, -1 do
            local x = self.oldPositions[i].x
            local y = self.oldPositions[i].y
            love.graphics.setColor(255, 0, 0, 31 + 20 * (self.maxOlds - i))
            love.graphics.rectangle("fill", x - hw, y - hh, self.width, self.height)
        end

        love.graphics.setColor(255, 0, 0)
        local hw, hh = self.width / 2, self.height / 2
        love.graphics.rectangle("fill", self.x - hw, self.y - hh, self.width, self.height)

        -- love.graphics.setColor(0, 255, 0)
        -- local lx = self.x + math.cos(math.rad(self.angle)) * 50
        -- local ly = self.y + math.sin(math.rad(self.angle)) * 50
        -- love.graphics.line(self.x, self.y, lx, ly)
    end

    self.left = function(self) return self.x - self.width / 2 end
    self.right = function(self) return self.x + self.width / 2 end
    self.top = function(self) return self.y - self.height / 2 end
    self.bottom = function(self) return self.y + self.height / 2 end

    return self
end