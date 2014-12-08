-- spyx.lua

local size = Vector2(115, 55)

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
        },
        dying = {
            love.graphics.newImage("resources/spyx/spyx_dying_1.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_2.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_3.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_4.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_5.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_6.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_7.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_8.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_9.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_10.png"),
            love.graphics.newImage("resources/spyx/spyx_dying_11.png")
        }
    },
    timeBeforeSpawn = 0.53
}

local function new(x, y)
    local rand = math.random()* 2
    local spyx = {
        rectangle = Rectangle(x or 0, y or 0, size.x, size.y, 0, 0, 0, 0, 1, 0, 0.9),
        speed = 30 + math.random()*5,
        lifetime = 5 + rand,
        totalLifeTime = 5 + rand,
        state = entityState.spawn,
        facingRight = true, -- defines if the sprite is facing right or left
        timeBeforeSpawn = spyxSharedData.timeBeforeSpawn, -- the time the enemy takes to spawn
        animationOffsetTime = 0, -- the offset of the animation
        
        animations = {
            running = {
                offset = Vector2(-30, -40),
                images = spyxSharedData.images.running,
                animation = function (self, t)
                        return self.images[math.floor(1+(10*t%4))]
                    end
            },
            spawn = {
                offset = Vector2(-30, -65),
                images = spyxSharedData.images.spawn,
                animation = function (self, t)
                        return self.images[math.floor(1+(math.min(13*t, 6)))]
                    end,
            },
            dying = {
                offset = Vector2(-30, -40),
                images = spyxSharedData.images.dying,
                animation = function (self, t)
                        return self.images[math.floor(1+(math.min(13*t, 10)))]
                    end
            }
        },
        sounds = {
            lavaOut = sounds.lavaOut:clone(),
            vanishing = sounds.vanishing:clone()
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
            local player = global.states.game.player
            if player.state == entityState.dead then
                self.lifetime = self.lifetime - (dt*2)
            else
                self.lifetime = self.lifetime - dt
            end
            
            if self.lifetime < 0.7 then
                if self.state ~= entityState.dying then
                    self.state = entityState.dying
                    self.animationOffsetTime = 0
                    self.sounds.vanishing:setPitch(0.8 + math.random()*0.4)
                    self.sounds.vanishing:play()
                end
            end
            
            local speed = self.speed
            local playerRectangle = player.rectangle
            local playerPos = playerRectangle.origin
            local direction = (playerPos - self.rectangle.origin):normalized()
            local oldness = math.max(-((((self.lifetime - 0.7)/self.totalLifeTime)-1)^8)+1, 0)
            self.rectangle:applyForce({x = direction.x * speed * oldness, y = direction.y * speed * oldness})
            self.rectangle:update(dt, {global.states.game.world, global.states.game.enemyRectangles})
            if self.rectangle:intersects(playerRectangle) and player.state ~= entityState.dead then
                local feedback = global.constants.feedback
                player:hurt(0.05)
                self.rectangle:applyForce({x = -direction.x * feedback, y = -direction.y * feedback})
                playerRectangle:applyForce({x = direction.x * feedback, y = direction.y * feedback})
            end
            if self.rectangle.origin.x > playerPos.x  and self.state ~= entityState.dying then
                self.facingRight = false
            elseif self.state ~= entityState.dying then
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
        elseif self.state == entityState.dying then
            sprite = self.animations.dying:animation(self.animationOffsetTime)
            offset = self.animations.dying.offset
        end
        love.graphics.setColor(255, 255, 255, 255)
        if sprite then
            if self.facingRight then
                love.graphics.draw(sprite, self.rectangle.origin.x + offset.x, self.rectangle.origin.y + offset.y, 0, 0.5, 0.5)
            else 
                love.graphics.draw(sprite, self.rectangle.origin.x + (self.rectangle.size.x - offset.x), self.rectangle.origin.y + offset.y, 0, -0.5, 0.5)
            end
        end
        -- love.graphics.setColor(0, 0, 0, 255)
        -- love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
    end
    
    function spyx:spawn(x, y)
        local rand = math.random()* 2
        self.animationOffsetTime = 0
        self.speed = 40 + math.random()*20
        self.rectangle.origin.x, self.rectangle.origin.y = x, y
        self.lifetime, self.totalLifeTime = 5 + rand, 5 + rand
        self.timeBeforeSpawn = spyxSharedData.timeBeforeSpawn
        self.state = entityState.spawn
    end
    
    return spyx
end

return setmetatable({new = new, size = size},
{__call = function(_, ...) return new(...) end})
