-- game.lua

local game = {}

function game:init()
    self.world = {
        Rectangle(0, 300, 100, designResolution.height),
        Rectangle(0, 0, designResolution.width, 100),
        Rectangle(0, designResolution.height - 100, designResolution.width, 100),
        Rectangle(designResolution.width - 100, 0, 0, designResolution.height)
    }
    self.player = require "entities.player"
    self.enemies = {
        chomp = require "entities.enemies.chomp"
    }
    self.waves = {
        
    }
    self.planWave = function(self, level)
            for i = 1, 1 + math.floor(level) do
                table.insert(self.waves, {enemy = self.enemies.chomp(100 + math.random() * (designResolution.width - 300), 300 + math.random() * (designResolution.height - 400)), t = os.time() + i})
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
    
    if self.player.state ~= entityState.dead then
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
    end
    
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
    love.graphics.setCanvas(global.canvases.main)
    for i, enemy in ipairs(self.instances.enemies) do
        enemy:draw()
    end
    self.player:draw()
    love.graphics.setCanvas()
end

return game
