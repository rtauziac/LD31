-- chomp.lua

local chomp = {}

local function new(x, y)
    return setmetatable({
        rectangle = Rectangle(x or 0, y or 0, 25, 25, 0, 0, 0, 0, 1, 1, 0.9),
        update = function(self, dt)
                local speed = 25
                local playerRectangle = global.states.game.player.rectangle
                local playerPos = playerRectangle.origin
                local direction = (playerPos - self.rectangle.origin):normalized()
                self.rectangle:applyForce({x = direction.x * speed, y = direction.y * speed})
                self.rectangle:update(dt)
                if self.rectangle:intersects(playerRectangle) then
                    local feedback = global.constants.feedback
                    global.states.game.player.health = global.states.game.player.health - 0.01 -- hit
                    self.rectangle:applyForce({x = -direction.x * feedback, y = -direction.y * feedback})
                    playerRectangle:applyForce({x = direction.x * feedback, y = direction.y * feedback})
                end
            end,
        draw = function(self)
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.rectangle("fill", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
            end
    },
    chomp)
end

return setmetatable({new = new},
{__call = function(_, ...) return new(...) end})
