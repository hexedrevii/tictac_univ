local ButtonController = require 'src.buttonController'
local global = require 'src.global'

local menu = {}

function menu:init()
  self.buttons = ButtonController.new()
  self.buttons:addNewButton(5, 5, "quit", function()
    love.event.quit()
  end)

  self.buttons:addNewButton(5, 5, "play", function()
    local game = require 'src.worlds.game'
    global.world:set(game)
  end)
end

function menu:update(delta)
  local offset = 0
  for _, element in ipairs(self.buttons.elements) do
    local w, h = love.graphics.getDimensions()
    element.x = w * 0.5 - global.font:getWidth(element.text) * 0.5
    element.y = h * 0.5 - global.font:getHeight() * 0.5 - offset

    offset = offset - 30
  end

  local mx, my = love.mouse.getPosition()
  self.buttons:update(mx, my, global.font)
end

function menu:draw()
  local r,g,b = love.math.colorFromBytes(145, 185, 250)
  love.graphics.clear(r, g, b)

  local w, h = love.graphics.getDimensions()
  local title = "TicToe"
  love.graphics.setFont(global.fontBig)
  love.graphics.print(title, w * 0.5 - global.fontBig:getWidth(title) * 0.5, 30)

  self.buttons:draw(global.font)
end



return menu
