-- rectangle

vector = require 'hump.vector'

local assert = assert
local sqrt, cos, sin, atan2 , max, min, abs = math.sqrt, math.cos, math.sin, math.atan2, math.max, math.min, math.abs

local rectangle = {}
rectangle.__index = rectangle

local function new(x ,y ,w ,h, vx, vy, ax, ay, friction, bouncyness, airfric)
    return setmetatable(
    {
        origin = vector.new(x, y),
        size = vector.new(w, h),
        velocity = vector.new(vx or 0, vy or 0),
        acceleration = vector.new(ax or 0, ay or 0),
        friction = friction or 0.98,
        bouncyness = bouncyness or 0,
        touchBottom = false,
        touchLeft = false,
        touchTop = false,
        touchRight = false,
        airFriction = airfric or 1,
        gravity = vector.new(0, 0)
    },
    rectangle)
end
local zero = new(0,0,0,0)

local function isrectangle(r)
    return getmetatable(r) == rectangle
end

function rectangle:clone()
    return new(self.origin.x, self.origin.y, self.size.x, self.size.y)
end

function rectangle:unpack()
    return self.origin.x, self.origin.y, self.size.x, self.size.y
end

function rectangle:__tostring()
    return "("..tonumber(self.origin)..","..tonumber(self.size)..")"
end

function rectangle:applyForce(vect)
    self.acceleration.x = self.acceleration.x + vect.x
    self.acceleration.y = self.acceleration.y + vect.y
end

function rectangle:update(dt, listOfRectangles)
    self.velocity = (self.velocity + self.acceleration + self.gravity) * self.airFriction
    self.origin = self.origin + (self.velocity * dt)
    self.acceleration.x, self.acceleration.y = 0, 0
    self.touchBottom = false
    self.touchLeft = false
    self.touchTop = false
    self.touchRight = false
    if listOfRectangles then
        for i, rectangles in ipairs(listOfRectangles) do
            for j, rect in ipairs(rectangles) do
                if self ~= rect and self:intersects(rect) then
                    if self.velocity.y > 0 then
                    -- if self.origin.y > rect.origin.y + (self.size.y / 2 + rect.size.y / 2) then
                        if self.velocity.x > 0 then
                            if self:distanceFromTopOf(rect) > self:distanceFromLeftOf(rect) then
                                self:matchTopOf(rect)
                                self.touchBottom = true
                                self.velocity.y = -self.velocity.y * self.bouncyness * rect.bouncyness
                                self.velocity.x = self.velocity.x * rect.friction
                            else
                                self:matchLeftOf(rect)
                                self.touchLeft = true
                                self.velocity.x = -self.velocity.x * self.bouncyness * rect.bouncyness
                                self.velocity.y = self.velocity.y * rect.friction
                            end
                        else
                            if self:distanceFromTopOf(rect) > self:distanceFromRightOf(rect) then
                                self:matchTopOf(rect)
                                self.touchBottom = true
                                self.velocity.y = -self.velocity.y * self.bouncyness * rect.bouncyness
                                self.velocity.x = self.velocity.x * rect.friction
                            else
                                self:matchRightOf(rect)
                                self.touchRight = true
                                self.velocity.x = -self.velocity.x * self.bouncyness * rect.bouncyness
                                self.velocity.y = self.velocity.y * rect.friction
                            end
                        end
                    else
                        if self.velocity.x > 0 then
                            if self:distanceFromBottomOf(rect) > self:distanceFromLeftOf(rect) then
                                self:matchBottomOf(rect)
                                self.touchTop = true
                                self.velocity.y = -self.velocity.y * self.bouncyness * rect.bouncyness
                                self.velocity.x = self.velocity.x * rect.friction
                            else
                                self:matchLeftOf(rect)
                                self.touchLeft = true
                                self.velocity.x = -self.velocity.x * self.bouncyness * rect.bouncyness
                                self.velocity.y = self.velocity.y * rect.friction
                            end
                        else
                            if self:distanceFromBottomOf(rect) > self:distanceFromRightOf(rect) then
                                self:matchBottomOf(rect)
                                self.touchTop = true
                                self.velocity.y = -self.velocity.y * self.bouncyness * rect.bouncyness
                                self.velocity.x = self.velocity.x * rect.friction
                            else
                                self:matchRightOf(rect)
                                self.touchRight = true
                                self.velocity.x = -self.velocity.x * self.bouncyness * rect.bouncyness
                                self.velocity.y = self.velocity.y * rect.friction
                            end
                        end
                    end
                end
            end
        end
    end
end

function rectangle:intersects(other)
    return self:horizontalIntersect(other) and
    self:verticalIntersect(other)
end

function rectangle:horizontalIntersect(other)
    return self.origin.x < other.origin.x + other.size.x and
    self.origin.x + self.size.x > other.origin.x
end

function rectangle:verticalIntersect(other)
    return self.origin.y < other.origin.y + other.size.y and
    self.origin.y + self.size.y > other.origin.y
end

function rectangle:contains(other)
    return self.origin.x <= other.origin.x and
    self.origin.y <= other.origin.y and
    self.origin.x + self.size.x >= other.origin.x + other.size.x and
    self.origin.y + self.size.y >= other.origin.y + other.size.y
end

--- Left
function rectangle:matchLeftOf(other)
    self.origin.x = other.origin.x - self.size.x
end

function rectangle:distanceFromLeftOf(other)
    return other.origin.x - (self.origin.x + self.size.x)
end

--- Right
function rectangle:matchRightOf(other)
    self.origin.x = other.origin.x + other.size.x
end

function rectangle:distanceFromRightOf(other)
    return self.origin.x - (other.origin.x + other.size.x)
end

--- Top
function rectangle:matchTopOf(other)
    self.origin.y = other.origin.y - self.size.y
end

function rectangle:distanceFromTopOf(other)
    return other.origin.y - (self.origin.y + self.size.y)
end

--- Bottom
function rectangle:matchBottomOf(other)
    self.origin.y = other.origin.y + other.size.y
end

function rectangle:distanceFromBottomOf(other)
    return self.origin.y - (other.origin.y + other.size.y)
end


function rectangle:unpack()
    return self.origin.x, self.origin.y, self.size.x, self.size.y
end

-- the module
return setmetatable({new = new, isrectangle = isrectangle, zero = zero},
{__call = function(_, ...) return new(...) end})