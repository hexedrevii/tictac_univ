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

return camera
