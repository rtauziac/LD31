-- game.lua

local game = {}
local floor = math.floor

local states = {
    playing = 0,
    score = 1
}

function game:init()
    self.numbers = {
        zero  = love.graphics.newImage("resources/0.png"),
        one   = love.graphics.newImage("resources/1.png"),
        two   = love.graphics.newImage("resources/2.png"),
        three = love.graphics.newImage("resources/3.png"),
        four  = love.graphics.newImage("resources/4.png"),
        five  = love.graphics.newImage("resources/5.png"),
        six   = love.graphics.newImage("resources/6.png"),
        seven = love.graphics.newImage("resources/7.png"),
        eight = love.graphics.newImage("resources/8.png"),
        nine  = love.graphics.newImage("resources/9.png")
    }
    sounds.static:setLooping(true)
    self.world = {
        Rectangle(0, 0, 80, designResolution.height),
        Rectangle(0, 0, designResolution.width, 100),
        Rectangle(0, designResolution.height - 20, designResolution.width, 50),
        Rectangle(designResolution.width - 100, 0, 0, designResolution.height)
    }
    self.state = states.playing
    self.player = require "entities.player"
    self.level = 0 -- the level to pass in planWave, the higher it is, the harder it is
    self.score = 0
    self.enemies = {
        spyx = require "entities.enemies.spyx"
    }
    self.waves = {
        
    }
    self.planWave = function(self, level)
                for i = 1, 1 + math.floor(level) do
                    local rand = math.random() * (level/4)
                    local reuseSpyx, deadEnemyCount = nil, #self.instances.deadEnemies
                    local randomX, randomY = 300 + math.random() * (designResolution.width - 500 - self.enemies.spyx.size.x), 300 + math.random() * (designResolution.height - 700)
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
    self.backgroundBottom = love.graphics.newImage("resources/backgroundBottom.png")
    self.returnRestart = love.graphics.newImage("resources/enter restart.png")
end

function game:enter()
    self:newGame()
end

function game:newGame()
    self.level = 0
    self.score = 0
    self.state = states.playing
    self.player:respawn()
    sounds.static:rewind()
    sounds.static:play()
end

function game:update(dt)
    self.player:update(dt)
    if self.state == states.playing then
        
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
        end
        self.player.rectangle:update(dt, {self.world})
        
        for i, plan in ipairs(self.waves) do    
            local t = global.t
            if plan.t < t then
                plan.enemy.sounds.lavaOut:play()
                table.insert(self.instances.enemies, plan.enemy)
                table.insert(self.enemyRectangles, plan.enemy.rectangle)
                table.remove(self.waves, i)
            end
        end
        
        for i, enemy in ipairs(self.instances.enemies) do
            if enemy.state == entityState.dead then
                if self.player.state ~= entityState.dead then
                    self.score = self.score + 1
                end
                table.remove(self.instances.enemies, i)
                table.remove(self.enemyRectangles, i)
                self.instances.deadEnemies[#self.instances.deadEnemies+1] = enemy
            end
            enemy:update(dt, {self.world})
        end
        
        if #self.instances.enemies == 0  and #self.waves == 0 and self.plan == nil then
            if self.player.state == entityState.dead and self.state ~= states.score then
                self.state = states.score
                sounds.dong:play()
            else
                self:planWave(self.level)
                self.level = self.level + 1
            end
        end
    elseif self.state == states.score then
        if love.keyboard.isDown("return") then
            self:newGame()
        end
    end
end

function game:draw()
    love.graphics.setCanvas(global.canvases.main)
    love.graphics.draw(self.background)
    for i, enemy in ipairs(self.instances.enemies) do
        enemy:draw()
    end
    self.player:draw()
    if self.state == states.score then
        local unit, decimals, hundreds, thousands = nil, nil, nil, nil
        if self.score%10 == 1 then
            unit = self.numbers.one
        elseif self.score%10 == 2 then
            unit = self.numbers.two
        elseif self.score%10 == 3 then
            unit = self.numbers.three
        elseif self.score%10 == 4 then
            unit = self.numbers.four
        elseif self.score%10 == 5 then
            unit = self.numbers.five
        elseif self.score%10 == 6 then
            unit = self.numbers.six
        elseif self.score%10 == 7 then
            unit = self.numbers.seven
        elseif self.score%10 == 8 then
            unit = self.numbers.eight
        elseif self.score%10 == 9 then
            unit = self.numbers.nine
        else
            unit = self.numbers.zero
        end
        
        if floor(self.score/10)%10 == 1 then
            decimals = self.numbers.one
        elseif floor(self.score/10)%10 == 2 then
            decimals = self.numbers.two
        elseif floor(self.score/10)%10 == 3 then
            decimals = self.numbers.three
        elseif floor(self.score/10)%10 == 4 then
            decimals = self.numbers.four
        elseif floor(self.score/10)%10 == 5 then
            decimals = self.numbers.five
        elseif floor(self.score/10)%10 == 6 then
            decimals = self.numbers.six
        elseif floor(self.score/10)%10 == 7 then
            decimals = self.numbers.seven
        elseif floor(self.score/10)%10 == 8 then
            decimals = self.numbers.eight
        elseif floor(self.score/10)%10 == 9 then
            decimals = self.numbers.nine
        end
        
        if floor(self.score/100)%10 == 1 then
            hundreds = self.numbers.one
        elseif floor(self.score/100)%10 == 2 then
            hundreds = self.numbers.two
        elseif floor(self.score/100)%10 == 3 then
            hundreds = self.numbers.three
        elseif floor(self.score/100)%10 == 4 then
            hundreds = self.numbers.four
        elseif floor(self.score/100)%10 == 5 then
            hundreds = self.numbers.five
        elseif floor(self.score/100)%10 == 6 then
            hundreds = self.numbers.six
        elseif floor(self.score/100)%10 == 7 then
            hundreds = self.numbers.seven
        elseif floor(self.score/100)%10 == 8 then
            hundreds = self.numbers.eight
        elseif floor(self.score/100)%10 == 9 then
            hundreds = self.numbers.nine
        end
        
        if floor(self.score/1000)%10 == 1 then
            thousands = self.numbers.one
        elseif floor(self.score/1000)%10 == 2 then
            thousands = self.numbers.two
        elseif floor(self.score/1000)%10 == 3 then
            thousands = self.numbers.three
        elseif floor(self.score/1000)%10 == 4 then
            thousands = self.numbers.four
        elseif floor(self.score/1000)%10 == 5 then
            thousands = self.numbers.five
        elseif floor(self.score/1000)%10 == 6 then
            thousands = self.numbers.six
        elseif floor(self.score/1000)%10 == 7 then
            thousands = self.numbers.seven
        elseif floor(self.score/1000)%10 == 8 then
            thousands = self.numbers.eight
        elseif floor(self.score/1000)%10 == 9 then
            thousands = self.numbers.nine
        end
        
        local offset = 0
        if decimals == nil then
            offset = -125
        elseif hundreds == nil then
            offset = -75
        elseif thousands == nil then
            offset = 25
        else
            offset = 125
        end
        love.graphics.draw(unit, designResolution.width / 2 + offset, designResolution.height / 2 - 125, 0, 0.5, 0.5)
        if decimals ~= nil then
            love.graphics.draw(decimals, designResolution.width / 2 + offset - 200, designResolution.height / 2 - 125, 0, 0.5, 0.5)
        end
        if hundreds ~= nil then
            love.graphics.draw(hundreds, designResolution.width / 2 + offset - 200 - 200, designResolution.height / 2 - 125, 0, 0.5, 0.5)
        end
        if thousands ~= nil then
            love.graphics.draw(thousands, designResolution.width / 2 + offset - 200 - 200 - 200, designResolution.height / 2 - 125, 0, 0.5, 0.5)
        end
        love.graphics.draw(self.returnRestart, designResolution.width/2 - self.returnRestart:getWidth()/4, designResolution.height/1.4, 0, 0.5, 0.5)
    end
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.backgroundBottom, 0, designResolution.height-self.backgroundBottom:getHeight())
    love.graphics.setCanvas()
end

return game
