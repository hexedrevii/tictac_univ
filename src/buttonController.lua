local Button = require "src.button"
local global = require "src.global"
local buttonController = {}
buttonController.__index = buttonController

function buttonController.new()
  local controller = {
    elements = {}
  }

  return setmetatable(controller, buttonController)
end

function buttonController:addNewButton(x, y, text, callback)
  table.insert(self.elements, Button.new(x, y, text, callback))
end

function buttonController:update(mx, my, font)
  for _, element in ipairs(self.elements) do
    local w = font:getWidth(element.text)
    local h = font:getHeight()

    if mx >= element.x and mx <= element.x + w and
       my >= element.y and my <= element.y + h
    then
      element.colour = {1, 0.984, 0}
      if global.input:isPressed('uiaccept') then
        if element.callback then
          element.callback(element)
        end
      end
    else
      element.colour = {1,1,1}
    end
  end
end

function buttonController:draw(font)
  for _, element in ipairs(self.elements) do
    love.graphics.setColor(element.colour)
    element:draw(font)
    love.graphics.setColor(1,1,1)
  end
end

return buttonController
