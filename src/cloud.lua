local cloud = {}
cloud.__index = cloud

local function randf(min, max)
  return min + (max - min) * love.math.random()
end

function cloud.new(sprites, camera)
  local bounds = camera:getViewBounds()
  local cl = {
    sprite = sprites[love.math.random(1, #sprites)],

    speed = love.math.random(150, 200),
    scale = randf(0.3, 0.8),

    x = love.math.random(bounds.left, bounds.right),
    y = love.math.random(bounds.top, bounds.bottom),

    camera = camera
  }

  return setmetatable(cl, cloud)
end

function cloud:update(delta)
  self.x = self.x + self.speed * delta

  local bounds = self.camera:getViewBounds()
  if self.x > bounds.right + self.sprite:getWidth() then
    self.x = bounds.left - self.sprite:getWidth()
    self.y = love.math.random(bounds.top, bounds.bottom)
  end
end

function cloud:draw()
  love.graphics.draw(self.sprite, math.floor(self.x), math.floor(self.y), 0, self.scale, self.scale)
end

return cloud
