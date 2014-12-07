-- game.lua

local game = {}

function game:init()
    
    self.world = {
        Rectangle(100, 0, 100, designResolution.height),
        Rectangle(0, 0, designResolution.width, 100),
        Rectangle(0, designResolution.height - 100, designResolution.width, 100),
        Rectangle(designResolution.width - 200, 0, 0, designResolution.height)
    }
    self.player = require "entities.player"
    self.level = 0 -- the level to pass in planWave, the higher it is, the harder it is
    self.enemies = {
        spyx = require "entities.enemies.spyx"
    }
    self.waves = {
        
    }
    self.planWave = function(self, level)
                for i = 1, 1 + math.floor(level) do
                    local rand = math.random()
                    local reuseSpyx, deadEnemyCount = nil, #self.instances.deadEnemies
                    local randomX, randomY = 200 + math.random() * (designResolution.width - 400 - self.enemies.spyx.size.x), 300 + math.random() * (designResolution.height - 700)
                    if deadEnemyCount > 0 then
                        reuseSpyx = self.instances.deadEnemies[deadEnemyCount]
                        self.instances.deadEnemies[deadEnemyCount] = nil
                        reuseSpyx:spawn(randomX, randomY)
                    end
                    if reuseSpyx == nil then
                        reuseSpyx = self.enemies.spyx(randomX, randomY)
                    end
                    table.insert(self.waves, {enemy = reuseSpyx, t = global.t + 1 + rand})
                end
        end
    self.instances = {
        enemies = {
        },
        deadEnemies = {
        }
    }
    self.enemyRectangles = {
    }
    self.background = love.graphics.newImage("resources/background.jpg")
end

-- function game:enter()
    
-- end

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
        local t = global.t
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
            self.instances.deadEnemies[#self.instances.deadEnemies+1] = enemy
        end
        enemy:update(dt, {self.world})
    end
    
    if #self.instances.enemies == 0  and #self.waves == 0 and self.plan == nil and self.player.state ~= entityState.dead then
        self:planWave(self.level)
        self.level = self.level + 1
    end
end

function game:draw()
    love.graphics.setCanvas(global.canvases.main)
    love.graphics.draw(self.background)
    for i, enemy in ipairs(self.instances.enemies) do
        enemy:draw()
    end
    self.player:draw()
    love.graphics.setCanvas()
end

return game
