-- spyx.lua

local size = Vector2(250, 120)

local spyxSharedData = {
    images = {
        running = {
            love.graphics.newImage("resources/spyx/spyx_run_1.png"),
            love.graphics.newImage("resources/spyx/spyx_run_2.png"),
            love.graphics.newImage("resources/spyx/spyx_run_3.png"),
            love.graphics.newImage("resources/spyx/spyx_run_4.png")
        },
        spawn = {
            love.graphics.newImage("resources/spyx/spyx_spawn_1.png"),
            love.graphics.newImage("resources/spyx/spyx_spawn_2.png"),
            love.graphics.newImage("resources/spyx/spyx_spawn_3.png"),
            love.graphics.newImage("resources/spyx/spyx_spawn_4.png"),
            love.graphics.newImage("resources/spyx/spyx_spawn_5.png"),
            love.graphics.newImage("resources/spyx/spyx_spawn_6.png"),
            love.graphics.newImage("resources/spyx/spyx_spawn_7.png")
        }
    },
    timeBeforeSpawn = 0.53
}

local function new(x, y)
    local rand = math.random()* 2
    local spyx = {
        rectangle = Rectangle(x or 0, y or 0, size.x, size.y, 0, 0, 0, 0, 1, 0, 0.94),
        lifetime = 5 + rand,
        totalLifeTime = 5 + rand,
        state = entityState.spawn,
        facingRight = true, -- defines if the sprite is facing right or left
        timeBeforeSpawn = spyxSharedData.timeBeforeSpawn, -- the time the enemy takes to spawn
        animationOffsetTime = 0, -- the offset of the animation
        
        animations = {
            running = {
                offset = Vector2(-50, -70),
                images = {
                    -- love.graphics.newImage("resources/spyx/spyx_run_1.png"),
                    -- love.graphics.newImage("resources/spyx/spyx_run_2.png"),
                    -- love.graphics.newImage("resources/spyx/spyx_run_3.png"),
                    -- love.graphics.newImage("resources/spyx/spyx_run_4.png")
                    spyxSharedData.images.running[1],
                    spyxSharedData.images.running[2],
                    spyxSharedData.images.running[3],
                    spyxSharedData.images.running[4]
                },
                animation = function (self, t)
                        return self.images[math.floor(1+(10*t%4))]
                    end
            },
            spawn = {
                offset = Vector2(-50, -120),
                images = {
                    spyxSharedData.images.spawn[1],
                    spyxSharedData.images.spawn[2],
                    spyxSharedData.images.spawn[3],
                    spyxSharedData.images.spawn[4],
                    spyxSharedData.images.spawn[5],
                    spyxSharedData.images.spawn[6],
                    spyxSharedData.images.spawn[7]
                },
                animation = function (self, t)
                        return self.images[math.floor(1+(math.min(13*t, 6)))]
                    end,
            }
        }
    }
    
    function spyx:update(dt) 
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
    end
    
    function spyx:draw()
        local offset = Vector2(0, 0)
        local sprite
        if self.state == entityState.spawn then
            sprite = self.animations.spawn:animation(self.animationOffsetTime)
            offset = self.animations.spawn.offset
        elseif self.state == entityState.running then
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
        -- love.graphics.setColor(0, 0, 0, 255)
        -- love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
    end
    
    function spyx:spawn(x, y)
        local rand = math.random()* 2
        self.animationOffsetTime = 0
        self.rectangle.origin.x, self.rectangle.origin.y = x, y
        self.lifetime, self.totalLifeTime = 5 + rand, 5 + rand
        self.timeBeforeSpawn = spyxSharedData.timeBeforeSpawn
        self.state = entityState.spawn
    end
    
    return spyx
end

return setmetatable({new = new, size = size},
{__call = function(_, ...) return new(...) end})
