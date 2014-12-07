-- game.lua

local game = {}

function game:init()
    self.world = {
        Rectangle(0, 0, 100, designResolution.height),
        Rectangle(0, 0, designResolution.width, 100),
        Rectangle(0, designResolution.height - 100, designResolution.width, 100),
        Rectangle(designResolution.width - 100, 0, 0, designResolution.height)
    }
    self.player = {
        rectangle = Rectangle(500, 500, 200, 200, 0, 0, 0, 0, 0.1, 0.6, 0.8),
        health = 1, -- the health of the player 1...0
        speed = 250,
        state = entityState.idle, -- the state of the player, defines the behavior and the animations
        facingRight = true, -- defines the direction where the player looks
        animationStartTime = os.time(), -- origin of the animation
        animationOffsetTime = 0 ,-- the offset of the animation
        update = function(self, dt)
                self.animationOffsetTime = self.animationOffsetTime + dt
                
                -- print(self.rectangle.velocity:len())
                if self.state == entityState.hurt and self.animationOffsetTime < self.animations.hurt.duration then
                    -- do nothing
                    -- print("hurt")
                    if self.state ~= entityState.hurt then
                        animationStartTime = os.time()
                        animationOffsetTime = 0 
                    end
                elseif self.rectangle.velocity:len2() > 499999 then
                    if self.state ~= entityState.running then
                        -- print("running")
                        self.animationStartTime = os.time()
                        self.animationOffsetTime = 0
                    end
                    self.state = entityState.running
                else
                    if self.state ~= entityState.idle then
                        -- print("idle")
                        self.animationStartTime = os.time()
                        self.animationOffsetTime = 0
                    end
                    self.state = entityState.idle
                end
                
                if self.rectangle.velocity.x < -0.1 then
                    self.facingRight = false
                    
                elseif self.rectangle.velocity.x > 0.1 then
                    self.facingRight = true
                end
            end,
        draw = function (self)
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
                end
                if self.facingRight then
                    love.graphics.draw(sprite, self.rectangle.origin.x + offset.x, self.rectangle.origin.y + offset.y)
                else 
                    love.graphics.draw(sprite, self.rectangle.origin.x + (self.rectangle.size.x - offset.x), self.rectangle.origin.y + offset.y, 0, -1, 1)
                end
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
            end,
        hurt = function(self, damage)
                self.state = entityState.hurt
                self.health = self.health - damage
            end,
        animations = {
            idle = {
                offset = Vector2(0, -240),
                images = {
                    love.graphics.newImage("resources/eye_idle_1.png"),
                    love.graphics.newImage("resources/eye_idle_2.png"),
                    love.graphics.newImage("resources/eye_idle_3.png"),
                    love.graphics.newImage("resources/eye_idle_4.png"),
                    love.graphics.newImage("resources/eye_idle_5.png")
                },
                animation = function (self, t)
                        return self.images[math.floor(1+(10*t%5))]
                    end
            },
            running = {
                offset = Vector2(-50, -170),
                images = {
                    love.graphics.newImage("resources/eye_run_1.png"),
                    love.graphics.newImage("resources/eye_run_2.png"),
                    love.graphics.newImage("resources/eye_run_3.png"),
                    love.graphics.newImage("resources/eye_run_4.png"),
                    love.graphics.newImage("resources/eye_run_5.png")
                },
                animation = function (self, t)
                        return self.images[math.floor(1+(21*t%5))]
                    end
            },
            hurt = {
                offset = Vector2(-92, -250),
                images = {
                    love.graphics.newImage("resources/eye_hurt_1.png"),
                    love.graphics.newImage("resources/eye_hurt_2.png"),
                    love.graphics.newImage("resources/eye_hurt_3.png"),
                    love.graphics.newImage("resources/eye_hurt_4.png"),
                    love.graphics.newImage("resources/eye_hurt_5.png")
                },
                animation = function (self, t)
                        print(t,    math.floor(1+(math.min(10*t, 4))))
                        return self.images[math.floor(1+(math.min(13*t, 4)))]
                    end,
                duration = 0.4
            }
        }
    }
    self.enemies = {
        chomp = require "states.enemies.chomp"
    }
    self.waves = {
        
    }
    self.planWave = function(self, level)
            for i = 1, 1 + math.floor(level) do
                table.insert(self.waves, {enemy = self.enemies.chomp(100 + i * 70, 100), t = os.time() + 0 + i})
            end
        end
    self.instances = {
        enemies = {
            -- self.enemies.chomp(100, 100)
        }
    }
    self.enemyRectangles = {
        -- self.instances.enemies[1].rectangle
    }
end

function game:enter()
    self:planWave(5)
end

function game:update(dt)
    self.player:update(dt)
    -- if self.player.health <= 0 then
        -- print("player dead")
    -- end
    
    local direction = Vector2(0, 0)
    if love.keyboard.isDown("up") then
        direction.y = -1
    end
    if love.keyboard.isDown("down") then
        direction.y = direction.y + 1
    end
    
    if love.keyboard.isDown("left") then
        direction.x = -1
    end
    if love.keyboard.isDown("right") then
        direction.x = direction.x + 1
    end
    self.player.rectangle:applyForce(direction:normalized() * self.player.speed)
    self.player.rectangle:update(dt, {self.world})
    
    for i, plan in ipairs(self.waves) do    
        local t = os.time()
        if plan.t < t then
            table.insert(self.instances.enemies, plan.enemy)
            table.insert(self.enemyRectangles, plan.enemy.rectangle)
            table.remove(self.waves, i)
        end
    end
    
    for i, enemy in ipairs(self.instances.enemies) do
        if enemy.state == entityState.dead then
            table.remove(self.instances.enemies, i)
            table.remove(self.enemyRectangles, i)
        end
        enemy:update(dt, {self.world})
    end
end

function game:draw()
    global.canvases.main:clear(255, 255, 255, 255)
    love.graphics.setCanvas(global.canvases.main)
    for i, enemy in ipairs(self.instances.enemies) do
        enemy:draw()
    end
    self.player:draw()
    love.graphics.setCanvas()
end

return game
