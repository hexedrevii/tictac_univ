local Camera = require 'src.camera'
local Timer  = require 'lib.marshmallow.timer'
local Cloud  = require 'src.cloud'
local ButtonController = require 'src.buttonController'

local global = require 'src.global'

local game = {}

function game:init()
  self.camera = Camera.new()

  self.clicker = love.audio.newSource('assets/click.wav', 'static')

  self.noughts = {
    sprites = {
      x = love.graphics.newImage('assets/x.png'),
      o = love.graphics.newImage('assets/o.png')
    },

    gap = 100,
    scale = 0.5,

    size = 512,

    startx = 0,
    starty = 0,

    ids = {
      x = 1,
      o = 2,
    }
  }

  self.camera:scaleWindow(1920, 1080)
  self:__centreCamera()

  self.clouds = {}
  self.cloudSprites = {
    love.graphics.newImage('assets/cloud_1.png'),
    love.graphics.newImage('assets/cloud_2.png')
  }

  for i = 1, 20 do
    table.insert(self.clouds, Cloud.new(self.cloudSprites, self.camera))
  end

  self.boardSprites = {
    edge_down = love.graphics.newImage('assets/wood_edge_down.png'),
    edge_up   = love.graphics.newImage('assets/wood_edge_up.png'),
    middle    = love.graphics.newImage('assets/wood_middle.png'),
    vertical  = love.graphics.newImage('assets/wood_vertical.png')
  }

  self.boardScale = 0.8

  self.board = {
    0,0,0,
    0,0,0,
    0,0,0,
  }

  self.colliders = {}

  self.turns = {
    x = 1,
    o = 2
  }

  self.states = {
    play = 'play',
    pause = 'pause',
  }

  self.totalTurns = 1

  self.turn = self.turns.x
  self.playerIs = self.turns.x

  self.winConditions = {
    -- Horizontals
    {1,2,3},
    {4,5,6},
    {7,8,9},

    -- Verticals
    {1,4,7},
    {2,5,8},
    {3,6,9},

    -- Diagonals
    {1,5,9},
    {3,5,7}
  }

  self.moveTimer = Timer.new(0.5, function ()
    -- Find all empty areas in board
    local empty = {}
    for i = 1, #self.board do
      if self.board[i] == 0 then
        table.insert(empty, i)
      end
    end

    local idx = love.math.random(1, #empty)
    if #empty >= 1 then
      self.board[empty[idx]] = self.turn
      self.clicker:play()
    end

    self:__handleWin()
    if not self.gameEnded then
      self:__handleTurnChange(idx)
    end
  end, true)

  self.moveTimer:stop()

  self.startTimer = Timer.new(0.25, function ()
    self.gameStarted = true
  end, true)

  self.gameEnded = false
  self.isDraw = false

  self.endButtons = ButtonController.new()
  self.endButtons:addNewButton(5, -100, "retry", function()
    global.world:set(game)
  end)

  self.endButtons:addNewButton(5, -100, "main menu", function()
    local menu = require 'src.worlds.menu'
    global.world:set(menu)
  end)
end

function game:__collidesDraw()
  local mx, my = self.camera:mouseToWorld()
  for _,collider in ipairs(self.colliders) do
    if mx >= collider.x and mx <= collider.x + collider.w and
       my >= collider.y and my <= collider.y + collider.h then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", collider.x, collider.y, collider.w, collider.h)
        love.graphics.setColor(1,1,1)
      end
  end
end

function game:__handleTurnChange(idx)
  if self.turn == self.turns.x then
    self.turn = self.turns.o
  else
    self.turn = self.turns.x
  end

  self.totalTurns = self.totalTurns + 1

  if not self.gameEnded then
    local draw = false
    local cnt = 0
    for _,id in ipairs(self.board) do
      if id ~= 0 then
        cnt = cnt + 1
      end
    end

    if cnt == #self.board then draw = true end

    if draw then
      self.gameEnded = true
      self.isDraw = true
    end
  end
end

function game:putMiddle(string, font, ww)
  return ww * 0.5 - font:getWidth(string) * 0.5
end

function game:putMiddleY(font, wh)
  return wh * 0.5 - font:getHeight() * 0.5
end

function game:__handleWin()
  for _, condition in ipairs(self.winConditions) do
    if self.board[condition[1]] == self.turn and
      self.board[condition[2]] == self.turn and
      self.board[condition[3]] == self.turn then
      self.gameEnded = true
    end
  end
end

function game:__collides()
  local mx, my = self.camera:mouseToWorld()
  for _,collider in ipairs(self.colliders) do
    if mx >= collider.x and mx <= collider.x + collider.w and
       my >= collider.y and my <= collider.y + collider.h then
      if love.mouse.isDown(1) then
        if self.board[collider.boardIndex] == 0 then
          self.board[collider.boardIndex] = self.turn

          self:__handleWin()
          self.clicker:play()

          if not self.gameEnded then
            self:__handleTurnChange(collider.boardIndex)
            self.moveTimer:start()
          end
        end
      end
    end
  end
end

function game:__drawNoughts()
  local x = self.noughts.startx
  local y = self.noughts.starty

  for i = 1, #self.board do
    local row = math.floor((i - 1) / 3)  -- Integer division to get the row index
    local col = (i - 1) % 3              -- Modulo to get the column index

    x = self.noughts.startx + col * (self.noughts.size * self.noughts.scale + self.noughts.gap)
    y = self.noughts.starty + row * (self.noughts.size * self.noughts.scale + self.noughts.gap)

    if #self.colliders ~= 9 then
      table.insert(self.colliders, {
        x = x, y = y,
        w = self.noughts.size * self.noughts.scale,
        h = self.noughts.size * self.noughts.scale,

        boardIndex = i
      })
    end

    if self.board[i] ~= 0 then
      local sprite = self.board[i] == self.noughts.ids.x and
        self.noughts.sprites.x or self.noughts.sprites.o

      love.graphics.draw(sprite, x, y, 0, self.noughts.scale, self.noughts.scale)
    end

    if row ~= 2 then
      love.graphics.draw(
        self.boardSprites.vertical,

        x, y + self.noughts.size * self.noughts.scale + 20, 0,
        self.noughts.scale, self.noughts.scale
      )
    end
  end
end

function game:__centreCamera()
  local centerX = self.noughts.startx + self.noughts.size * self.noughts.scale + self.noughts.size * 0.5 * self.noughts.scale + self.noughts.gap
  local centerY = self.noughts.starty + self.noughts.size * self.noughts.scale + self.noughts.size * 0.5 * self.noughts.scale + self.noughts.gap

  self.camera:lookAt(centerX, centerY)
end

function game:__drawLine(x, y)
  love.graphics.draw(self.boardSprites.edge_up, x, y, 0, self.boardScale, self.boardScale)
  love.graphics.draw(self.boardSprites.edge_down, x, y + self.boardSprites.edge_up:getHeight() * self.boardScale - 1, 0, self.boardScale, self.boardScale)
end

function game:update(delta)
  self.camera:scaleWindow(1920, 1080)
  self:__centreCamera()

  self.startTimer:update(delta)

  local offset = 50
  for _, button in ipairs(self.endButtons.elements) do
    local w, h = love.graphics.getDimensions()
    button.y = h - offset
    offset = offset + 60
  end

  if self.gameEnded then
    local mx, my = love.mouse.getPosition()
    self.endButtons:update(mx, my, global.fontBig)

    return
  end

  for _, cloud in ipairs(self.clouds) do
    cloud:update(delta)
  end

  self.moveTimer:update(delta)

  if self.turn == self.playerIs and self.gameStarted then
    self:__collides()
  end
end

function game:draw()
  local r,g,b = love.math.colorFromBytes(145, 185, 250)
  love.graphics.clear(r, g, b)

  self.camera:attach()
    for _, cloud in ipairs(self.clouds) do
      cloud:draw()
    end

    self:__drawNoughts()

    if self.turn == self.playerIs and not self.gameEnded then
      self:__collidesDraw()
    end

    self:__drawLine(220, 80)
    self:__drawLine(575, 80)

  self.camera:detach()

  if not self.gameEnded then
    love.graphics.setColor(love.math.colorFromBytes(194, 129, 70))
    love.graphics.rectangle("fill", 10, 10, 175, 90)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(global.font)
    love.graphics.print('turn ' .. self.totalTurns, 20, 20)

    local who = self.turn == 1 and 'x' or 'o'
    love.graphics.print(who .. "'s turn", 20, 60)
  end

  if self.gameEnded then
    local ww, wh = love.graphics.getDimensions()
    love.graphics.setColor(0,0,0,0.90)
    love.graphics.rectangle('fill', 0, 0, ww, wh)
    love.graphics.setColor(1,1,1,1)

    love.graphics.setFont(global.fontBig)

    local header = 'game end!'
    love.graphics.print(header, self:putMiddle(header, global.fontBig, ww), 20)

    love.graphics.setFont(global.font)

    local y = self:putMiddleY(global.font, wh)
    local winner = self.isDraw and 'its a draw!' or 'won by ' .. (self.turn == self.turns.x and 'x' or 'o')
    love.graphics.print(winner, self:putMiddle(winner, global.font, ww), y - 40)

    local turns = 'took ' .. self.totalTurns .. ' turns'
    love.graphics.print(turns, self:putMiddle(turns, global.font, ww), y)

    self.endButtons:draw(global.fontBig)
  end
end

return game
