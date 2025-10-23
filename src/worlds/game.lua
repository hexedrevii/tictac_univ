local Camera = require 'src.camera'

local game = {}

function game:init()
  self.camera = Camera.new()

  self.x = 0
  self.y = 0
end

function game:update(delta)
  self.camera:scaleWindow(1920, 1080)
end

function game:draw()
  local r,g,b = love.math.colorFromBytes(145, 185, 250)
  love.graphics.clear(r, g, b)

  self.camera:attach()
  love.graphics.rectangle('fill', 0,0,20,20)
  self.camera:detach()


  love.graphics.print('test', 50, 50)
end

return game
