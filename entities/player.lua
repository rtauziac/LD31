-- player.lua

local playerSharedData = {
    startAirFriction = 0.8
}

local player = {
    rectangle = Rectangle(designResolution.width/2, designResolution.height/2, 100, 100, 0, 0, 0, 0, 0.1, 0.6, playerSharedData.startAirFriction),
    health = 1, -- the health of the player 1...0
    previousHealth = 1,
    speed = 125,
    state = entityState.idle, -- the state of the player, defines the behavior and the animations
    facingRight = true, -- defines the direction where the player looks
    animationOffsetTime = 0 ,-- the offset of the animation
    soundSchedule = {
        step = 0
    },
    animations = {
        idle = {
            offset = Vector2(0, -120),
            images = {
                love.graphics.newImage("resources/eye/eye_idle_1.png"),
                love.graphics.newImage("resources/eye/eye_idle_2.png"),
                love.graphics.newImage("resources/eye/eye_idle_3.png"),
                love.graphics.newImage("resources/eye/eye_idle_4.png"),
                love.graphics.newImage("resources/eye/eye_idle_5.png")
            },
            animation = function (self, t)
                    return self.images[math.floor(1+(10*t%5))]
                end
        },
        running = {
            offset = Vector2(-25, -85),
            images = {
                love.graphics.newImage("resources/eye/eye_run_1.png"),
                love.graphics.newImage("resources/eye/eye_run_2.png"),
                love.graphics.newImage("resources/eye/eye_run_3.png"),
                love.graphics.newImage("resources/eye/eye_run_4.png"),
                love.graphics.newImage("resources/eye/eye_run_5.png")
            },
            animation = function (self, t)
                    return self.images[math.floor(1+(21*t%5))]
                end
        },
        hurt = {
            offset = Vector2(-56, -125),
            images = {
                love.graphics.newImage("resources/eye/eye_hurt_1.png"),
                love.graphics.newImage("resources/eye/eye_hurt_2.png"),
                love.graphics.newImage("resources/eye/eye_hurt_3.png"),
                love.graphics.newImage("resources/eye/eye_hurt_4.png"),
                love.graphics.newImage("resources/eye/eye_hurt_5.png")
            },
            animation = function (self, t)
                    return self.images[math.floor(1+(math.min(13*t, 4)))]
                end,
            duration = 0.43
        },
        death = {
            offset = Vector2(-26, -125),
            images = {
                love.graphics.newImage("resources/eye/eye_death_1.png"),
                love.graphics.newImage("resources/eye/eye_death_2.png"),
                love.graphics.newImage("resources/eye/eye_death_3.png"),
                love.graphics.newImage("resources/eye/eye_death_4.png"),
                love.graphics.newImage("resources/eye/eye_death_5.png"),
                love.graphics.newImage("resources/eye/eye_death_6.png"),
                love.graphics.newImage("resources/eye/eye_death_7.png"),
                love.graphics.newImage("resources/eye/eye_death_8.png"),
                love.graphics.newImage("resources/eye/eye_death_9.png"),
                love.graphics.newImage("resources/eye/eye_death_10.png"),
            },
            animation = function (self, t)
                    return self.images[math.floor(1+(math.min(13*t, 9)))]
                end,
        }
    }
}

function player:update(dt)
    self.animationOffsetTime = self.animationOffsetTime + dt
    if self.health < self.previousHealth and self.health >= 0 then
        sounds.ouch:setPitch(0.8 + math.random()*0.4)
        sounds.ouch:play()
    end
   self.previousHealth = self.health
    if self.health <= 0 then
        if self.state ~= entityState.dead then
            self.animationOffsetTime = 0 
            self.state = entityState.dead
            sounds.death:play()
            self.rectangle.airFriction = playerSharedData.startAirFriction * 0.6
        end
    else
        -- if self.state == entityState.hurt and self.animationOffsetTime <= self.animations.hurt.duration then
            -- if self.state ~= entityState.hurt then
                -- animationOffsetTime = 0
            -- end
        
        if self.state == entityState.hurt and self.animationOffsetTime <= self.animations.hurt.duration then
        else
        -- print(self.animationOffsetTime, self.animations.hurt.duration)
            if self.rectangle.velocity:len2() > 100000 then
                if self.state ~= entityState.running then
                    -- print("running")
                    self.animationOffsetTime = 0
                end
                if self.soundSchedule.step > self.animationOffsetTime % 0.23 then
                    sounds.step:rewind()
                    sounds.step:setPitch(0.8 + math.random()*0.4)
                    sounds.step:play()
                end
                self.soundSchedule.step = self.animationOffsetTime % 0.23
                self.state = entityState.running
            else
                if self.state ~= entityState.idle then
                    -- print("idle")
                    self.animationOffsetTime = 0
                end
                self.state = entityState.idle
            end
            
            -- if self.state ~= entityState.hurt then
                if self.rectangle.velocity.x < -0.3 then
                    self.facingRight = false
                elseif self.rectangle.velocity.x > 0.3 then
                    self.facingRight = true
                end
            -- end
        end
    end -- dead
end
    
function player:draw()
    love.graphics.setColor(255, 255, 255, 255)
    
    local offset = Vector2(0, 0)
    local sprite
    if self.state == entityState.idle then
        sprite = self.animations.idle:animation(self.animationOffsetTime)
        offset = self.animations.idle.offset
    elseif self.state == entityState.running then
        sprite = self.animations.running:animation(self.animationOffsetTime)
        offset = self.animations.running.offset
    elseif self.state == entityState.hurt then
        sprite = self.animations.hurt:animation(self.animationOffsetTime)
        offset = self.animations.hurt.offset
    elseif self.state == entityState.dead then
        sprite = self.animations.death:animation(self.animationOffsetTime)
        offset = self.animations.death.offset
    end
    if self.facingRight then
        love.graphics.draw(sprite, self.rectangle.origin.x + offset.x, self.rectangle.origin.y + offset.y, 0, 0.5, 0.5)
    else 
        love.graphics.draw(sprite, self.rectangle.origin.x + (self.rectangle.size.x - offset.x), self.rectangle.origin.y + offset.y, 0, -0.5, 0.5)
    end
    -- love.graphics.setColor(0, 0, 0, 255)
    -- love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
end

function player:hurt(damage)
    if self.state ~= entityState.hurt then
        self.animationOffsetTime = 0
        self.state = entityState.hurt
        -- print("damage")
        -- print(tostring(self.state == entityState.hurt), tostring(self.animationOffsetTime <= self.animations.hurt.duration))
    end
    self.health = self.health - damage
end

function player:respawn()
    self.health = 1
    self.rectangle.airFriction = playerSharedData.startAirFriction
    self.rectangle.origin.x, self.rectangle.origin.y = designResolution.width/2, designResolution.height/2
    self.state = entityState.idle
end

return player
