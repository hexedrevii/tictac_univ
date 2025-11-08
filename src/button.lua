local button = {}
button.__index = button

function button.new(x, y, text, callback)
  local btn = {
    x = x, y = y,
    text = text,
    callback = callback,

    active = false,

    colour = {1,1,1}
  }

  return setmetatable(btn, button)
end

function button:draw(font)
  love.graphics.setFont(font)
  love.graphics.print(self.text, self.x, self.y)
end

return button
