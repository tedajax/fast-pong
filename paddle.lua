function create_paddle(x, upkey, downkey)
    local self = {}

    self.x = x
    self.y = 0
    self.width = 20
    self.height = 100

    self.upkey = upkey
    self.downkey = downkey

    self.speed = 1000

    self.fieldTop = -love.graphics.getHeight() / 2 + self.height / 2
    self.fieldBottom = love.graphics.getHeight() / 2 - self.height / 2

    self.update = function(self, dt)
        if love.keyboard.isDown(self.upkey) then
            self.y = self.y - self.speed * dt
        end

        if love.keyboard.isDown(self.downkey) then
            self.y = self.y + self.speed * dt
        end

        if self.y < self.fieldTop then
            self.y = self.fieldTop
        end

        if self.y > self.fieldBottom then
            self.y = self.fieldBottom
        end
    end

    self.render = function(self)
        love.graphics.setColor(255, 255, 255)
        local ww = self.width / 2
        local hh = self.height / 2
        love.graphics.rectangle("fill", self.x - ww, self.y - hh, self.width, self.height)
    end

    -- returns if there is a hit and distance from center of paddle
    self.ballHitPoint = function(self, ball)
        local hit = self:left() < ball:right() and self:right() > ball:left() and
                    self:top() < ball:bottom() and self:bottom() > ball:top()

        local diff = self.y - ball.y
        diff = diff / (self.height / 2 + ball.height / 2)

        return hit, diff
    end

    self.left = function(self) return self.x - self.width / 2 end
    self.right = function(self) return self.x + self.width / 2 end
    self.top = function(self) return self.y - self.height / 2 end
    self.bottom = function(self) return self.y + self.height / 2 end

    return self
end