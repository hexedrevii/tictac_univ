local globals = require 'src.global'
local game    = require 'src.worlds.game'


function love.load()
  globals.world:set(game)
end

function love.update(delta)
  globals.world:update(delta)
end

function love.draw()
  globals.world:draw()
end
