-- main.lua

Gamestate = require "hump.gamestate"
Camera = require "hump.camera"
Vector2 = require "hump.vector"
Timer = require "hump.timer"
Rectangle = require "rectangle"

Nil = {} -- a nil pointer

windowSize = {
    width = 0,
    height = 0
}

global = {
    canvases = {
        main = Nil -- set in load()
    },
    states = {
        menu = require "states/menu",
        game = require "states/game"
    },
    options = {}
}

-- require other states

function love.load()
    global.canvases.main = love.graphics.newCanvas(designResolution.width, designResolution.height)
    global.canvases.main:setFilter("nearest")
    Gamestate.registerEvents()
    Gamestate.switch(global.states.game)
    windowSize.width, windowSize.height = love.window.getDimensions()
end

function love.resize(w, h)
    windowSize.width, windowSize.height = w, h
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

function love.update(dt)
    Timer.update(dt)
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(global.canvases.main, 0, 0, 0, windowSize.width / designResolution.width, windowSize.height / designResolution.height)
end
