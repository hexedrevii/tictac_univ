local globals = require 'src.global'
local game    = require 'src.worlds.game'


function love.load()
  globals.input:pushKeymap('uiaccept', nil, nil, 1)

  globals.world:set(game)
end

function love.update(delta)
  globals.world:update(delta)
end

function love.draw()
  globals.world:draw()
end


function love.mousepressed(x, y, button)
  globals.input:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  globals.input:mousereleased(x, y, button)
end
