local WorldController = require 'lib.marshmallow.worldController'
local Input = require 'lib.marshmallow.input'

local globals = {
  world = WorldController.new(),

  font = love.graphics.newFont('assets/JungleAdventurer.otf', 36),
  fontBig = love.graphics.newFont('assets/JungleAdventurer.otf', 48),

  input = Input.new()
}

return globals
