-- game.lua

local game = {}

local entityState = {
    idle = 0,
    running = 1,
    dancing = 2,
    dead = 3
}

function game:init()
    self.world = {
        Rectangle(0, 0, 100, designResolution.height),
        Rectangle(0, 0, designResolution.width, 100),
        Rectangle(0, designResolution.height - 100, designResolution.width, 100),
        Rectangle(designResolution.width - 100, 0, 0, designResolution.height)
    }
    self.player = {
        rectangle = Rectangle(500, 500, 30, 30, 0, 0, 0, 0, 0.1, 0.6, 0.8),
        health = 1, -- the health of the player 1...0
        state = entityState.idle, -- the state of the player, defines the behavior and the animations
        facingRight = true, -- defines the direction where the player looks
        animationStartTime = os.time(), -- origin of the animation
        animationOffsetTime = 0 ,-- the offset of the animation
        update = function(self, dt)
                self.animationOffsetTime = self.animationOffsetTime + dt
                if self.rectangle.velocity.x < -0.1 then
                    self.facingRight = false
                    self.state = entityState.running
                elseif self.rectangle.velocity.x > 0.1 then
                    self.facingRight = true
                    self.state = entityState.running
                else
                    if self.state ~= entityState.idle then
                        self.animationStartTime = os.time()
                        self.animationOffsetTime = 0
                    end
                    self.state = entityState.idle
                end
            end,
        draw = function (self)
                love.graphics.setColor(255, 255, 255, 255)
                
                local sprite
                if self.state == entityState.idle then
                    sprite = self.images.idle:animation(self.animationStartTime + self.animationOffsetTime)
                elseif self.state == entityState.running then
                    sprite = self.images.idle:animation(0)
                end
                
                if self.facingRight then
                    love.graphics.draw(sprite, self.rectangle.origin.x, self.rectangle.origin.y - self.rectangle.size.y * 2, 0, 0.323, 0.27)
                else
                    local offset = self.rectangle.size.x
                    love.graphics.draw(sprite, self.rectangle.origin.x + offset, self.rectangle.origin.y - self.rectangle.size.y * 2, 0, -0.323, 0.27)
                end
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
            end,
        images = {
            idle = {
                images = {
                    love.graphics.newImage("resources/eye_idle_1.png"),
                    love.graphics.newImage("resources/eye_idle_2.png"),
                    love.graphics.newImage("resources/eye_idle_3.png"),
                    love.graphics.newImage("resources/eye_idle_4.png"),
                    love.graphics.newImage("resources/eye_idle_5.png")
                },
                animation = function (self, t)
                        print(t, math.floor(1+(10*t%5)))
                        return self.images[math.floor(1+(10*t%5))]
                    end
            }
        }
    }
    self.enemies = {
        chomp = require "states.enemies.chomp"
    }
    self.waves = {
        
    }
    self.instances = {
        enemies = {
            -- self.enemies.chomp(100, 100)
        }
    }
    self.enemyRectangles = {
        -- self.instances.enemies[1].rectangle
    }
end

function game:update(dt)

    self.player:update(dt)
    if self.player.health <= 0 then
        print("player dead")
    end
    
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
    self.player.rectangle:applyForce(direction:normalized() * 100)
    self.player.rectangle:update(dt, {self.world})
    
    for index, enemy in ipairs(self.instances.enemies) do
        enemy:update(dt, {self.world, self.enemies})
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
