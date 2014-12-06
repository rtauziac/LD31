-- chomp.lua

local chomp = {
    rectangle = Rectangle(0, 0, 25, 25, 0, 0, 0, 0, 1, 1, 0.7)
}

function chomp:update()
    local playerPos = global.states.game.player.rectangle.origin
    -- self.rectangle:applyForce()
end

function chomp:draw()
    love.graphics.rectangle("fill", self.rectangle.origin.x, self.rectangle.origin.y, self.rectangle.size.x, self.rectangle.size.y)
end

return chomp
