local camera = {}
camera.__index = camera

function camera.new(x, y, scale)
  local cam = {
    x = x or 0,
    y = y or 0,

    scale = scale or 1,
    baseScale = scale or 1,

    target = nil
  }

  return setmetatable(cam, camera)
end

function camera:lookAt(x, y)
  self.x = x
  self.y = y
end

function camera:scaleWindow(width, height)
  local ww, wh = love.graphics.getDimensions()
  local sx, sy = ww / width, wh / height

  self.scale = math.min(sx, sy) * self.baseScale
end

function camera:attach()
  love.graphics.push()

  local ww, wh = love.graphics.getDimensions()
  love.graphics.translate(ww * 0.5, wh * 0.5)

  love.graphics.scale(self.scale)

  love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
  love.graphics.pop()
end

function camera:mouseToWorld()
  local mx, my = love.mouse.getPosition()
  local ww, wh = love.graphics.getDimensions()

  local worldX = (mx - ww * 0.5) / self.scale + self.x
  local worldY = (my - wh * 0.5) / self.scale + self.y

  return worldX, worldY
end

---@class view
---@field left number
---@field right number
---@field top number
---@field bottom number
---@field width number
---@field height number
local _view

---Get the view size of the camera
---@return view
function camera:getViewBounds()
  local ww, wh = love.graphics.getDimensions()
  local halfWidth  = (ww * 0.5) / self.scale
  local halfHeight = (wh * 0.5) / self.scale

  return {
    left = self.x - halfWidth,
    right = self.x + halfWidth,
    top = self.y - halfHeight,
    bottom = self.y + halfHeight,
    width = halfWidth * 2,
    height = halfHeight * 2
  }
end

return camera
