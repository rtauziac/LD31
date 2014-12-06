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
        rectangle = Rectangle(20, 20, 30, 30, 0, 0, 0, 0, 0.1, 0.6, 0.8),
        health = 1,
        state = entityState.idle,
        draw = function (self)
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.draw(self.images.idle, self.rectangle.origin.x, self.rectangle.origin.y - self.rectangle.size.y * 2, 0, 0.323, 0.27) -- micro optim
                -- love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
            end,
        images = {
            idle = love.graphics.newImage("resources/hero.png")
        }
    }
    self.enemies = {
        chomp = require "states.enemies.chomp"
    }
    self.waves = {
        
    }
    self.instances = {
        enemies = {
            self.enemies.chomp(100, 100)
        }
    }
    self.enemyRectangles = {
        self.instances.enemies[1].rectangle
    }
end

function game:update(dt)

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
    self.player.rectangle:update(dt, {self.world, self.enemyRectangles})
    
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
