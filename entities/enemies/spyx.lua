-- spyx.lua

local size = Vector2(250, 120)

local function new(x, y)
    local rand = math.random()* 2
    return setmetatable({
        rectangle = Rectangle(x or 0, y or 0, size.x, size.y, 0, 0, 0, 0, 1, 0, 0.94),
        lifetime = 5 + rand,
        totalLifeTime = 5 + rand,
        state = entityState.spawn,
        facingRight = true, -- defines if the sprite is facing right or left
        timeBeforeSpawn = 0.6, -- the time the enemy takes to spawn
        animationOffsetTime = 0 ,-- the offset of the animation
        update = function(self, dt) 
                self.animationOffsetTime = self.animationOffsetTime + dt
                if self.lifetime <= 0 and self.state ~= entityState.dead then
                    self.state = entityState.dead
                end
                if self.state == entityState.spawn then
                    self.timeBeforeSpawn = self.timeBeforeSpawn - dt
                    if self.timeBeforeSpawn <= 0 then
                        self.state = entityState.running
                    end
                elseif self.state ~= entityState.dead then
                    self.lifetime = self.lifetime - dt
                    local speed = 50
                    local player = global.states.game.player
                    local playerRectangle = player.rectangle
                    local playerPos = playerRectangle.origin
                    local direction = (playerPos - self.rectangle.origin):normalized()
                    local oldness = -(((self.lifetime/self.totalLifeTime)-1)^10)+1
                    self.rectangle:applyForce({x = direction.x * speed * oldness, y = direction.y * speed * oldness})
                    self.rectangle:update(dt, {global.states.game.world, global.states.game.enemyRectangles})
                    if self.rectangle:intersects(playerRectangle) then--and player.state ~= entityState.dead then
                        local feedback = global.constants.feedback
                        player:hurt(0.05)
                        self.rectangle:applyForce({x = -direction.x * feedback, y = -direction.y * feedback})
                        playerRectangle:applyForce({x = direction.x * feedback, y = direction.y * feedback})
                    end
                    if self.rectangle.origin.x > playerPos.x then
                        self.facingRight = false
                    else
                        self.facingRight = true
                    end
                end
            end,
        draw = function(self)
                local offset = Vector2(0, 0)
                local sprite
                if self.state == entityState.running then
                    sprite = self.animations.running:animation(self.animationOffsetTime)
                    offset = self.animations.running.offset
                end
                love.graphics.setColor(255, 255, 255, 255)
                if sprite then
                    if self.facingRight then
                        love.graphics.draw(sprite, self.rectangle.origin.x + offset.x, self.rectangle.origin.y + offset.y)
                    else 
                        love.graphics.draw(sprite, self.rectangle.origin.x + (self.rectangle.size.x - offset.x), self.rectangle.origin.y + offset.y, 0, -1, 1)
                    end
                end
                
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
            end,
        animations = {
            running = {
                offset = Vector2(-50, -70),
                images = {
                    love.graphics.newImage("resources/spyx/spyx_run_1.png"),
                    love.graphics.newImage("resources/spyx/spyx_run_2.png"),
                    love.graphics.newImage("resources/spyx/spyx_run_3.png"),
                    love.graphics.newImage("resources/spyx/spyx_run_4.png")
                },
                animation = function (self, t)
                        return self.images[math.floor(1+(10*t%4))]
                    end
            }
        }
    },
    chomp)
end

return setmetatable({new = new, size = size},
{__call = function(_, ...) return new(...) end})
