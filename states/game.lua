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
        rectangle = Rectangle(20, 20, 30, 30, 0, 0, 0, 0, 0.1, 0.6, 0.8),
        health = 1,
        draw = function (self)
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.draw(self.images.idle, self.rectangle.origin.x, self.rectangle.origin.y - self.rectangle.size.y * 2, 0, 0.323, 0.27) -- micro optim
                -- love.graphics.rectangle("line", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
            end,
        images = {
            idle = love.graphics.newImage("resources/hero.png")
        }
    },
    self.enemies = {
        chomp = require "states.enemies.chomp"
    },
    self.waves = {
        
    },
    self.instances = {
        enemies = {
        }
    }
end

function game:update(dt)
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
    self.player.rectangle:update(dt, self.world)
end

function game:draw()
    global.canvases.main:clear(255, 255, 255, 255)
    love.graphics.setCanvas(global.canvases.main)
    self.player:draw()
    love.graphics.setCanvas()
end

return game
