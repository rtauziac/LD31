-- chomp.lua

local chomp = {}

local function new(x, y)
    local rand = math.random()* 2
    return setmetatable({
        rectangle = Rectangle(x or 0, y or 0, 150, 150, 0, 0, 0, 0, 1, 0, 0.94),
        lifetime = 5 + rand,
        totalLifeTime = 5 + rand,
        state = entityState.running,
        update = function(self, dt) 
                if self.lifetime <= 0 and self.state ~= entityState.dead then
                    self.state = entityState.dead
                end
                if self.state ~= entityState.dead then
                    self.lifetime = self.lifetime - dt
                    local speed = 50
                    local player = global.states.game.player
                    local playerRectangle = player.rectangle
                    local playerPos = playerRectangle.origin
                    local direction = (playerPos - self.rectangle.origin):normalized()
                    local oldness = -(((self.lifetime/self.totalLifeTime)-1)^10)+1
                    self.rectangle:applyForce({x = direction.x * speed * oldness, y = direction.y * speed * oldness})
                    self.rectangle:update(dt, {global.states.game.world, global.states.game.enemyRectangles})
                    if self.rectangle:intersects(playerRectangle) and player.state ~= entityState.dead then
                        local feedback = global.constants.feedback
                        player:hurt(0.01)
                        -- global.states.game.player.health = global.states.game.player.health - 0.01 -- hit
                        self.rectangle:applyForce({x = -direction.x * feedback, y = -direction.y * feedback})
                        playerRectangle:applyForce({x = direction.x * feedback, y = direction.y * feedback})
                    end
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
