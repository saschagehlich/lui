local pathMatch = "(.+)%.skins.Default$"
local basePath = (...):match(pathMatch)

local class = require(basePath .. ".lib.middleclass")

local DefaultSkin = class("DefaultSkin")

-- Colors
DefaultSkin.windowBackgroundColor = { 112, 131, 125 }
DefaultSkin.titleBarBackgroundColor = { 47, 67, 67 }

DefaultSkin.lightColor = { 255, 255, 255, 50 }
DefaultSkin.shadowColor = { 0, 0, 0, 50 }

-- Spacings
DefaultSkin.windowPadding = { x = 5, y = 30 }
DefaultSkin.windowTitleBarHitboxHeight = 15

--- Constructor
--  @param {lui} lui
function DefaultSkin:initialize(lui)
  self.lui = lui
  self.font = love.graphics.newFont(basePath .. "/skins/Default/66amagasaki.ttf", 8)
end

--- Draws the given window
--  @param {Window} window
function DefaultSkin:drawWindow(window)
  local x, y = window:_getRealPosition()

  love.graphics.setFont(self.font)

  self:drawWindowBackground(window, x, y)
  self:drawWindowTitleBarBackground(window, x, y)
  self:drawWindowTitleBarContent(window, x, y)
end

--- Draws the window background
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultSkin:drawWindowBackground(window, x, y)
  local width, height = window.size.width, window.size.height

  -- Draw background
  love.graphics.setColor(self.windowBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  -- Draw light
  local points = {
    x + 1, y + height - 1,
    x + 1, y,
    x + width - 1, y
  }
  love.graphics.setColor(self.lightColor)
  love.graphics.line(points)

  -- Draw shadow
  local points = {
    x + width, y,
    x + width, y + height - 1,
    x, y + height - 1
  }
  love.graphics.setColor(self.shadowColor)
  love.graphics.setLineStyle("rough")
  love.graphics.line(points)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the window titlebar background
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultSkin:drawWindowTitleBarBackground(window, x, y)
  local width, height = window.size.width - 4, 12
  local x, y = x + 2, y + 2

  -- Draw background
  love.graphics.setColor(self.titleBarBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  -- Draw shadow
  local points = {
    x, y + height + 1,
    x, y - 1,
    x + width + 1, y - 1
  }
  love.graphics.setColor(self.shadowColor)
  love.graphics.setLineStyle("rough")
  love.graphics.line(points)

  -- Draw light
  local points = {
    x + width + 1, y,
    x + width + 1, y + height,
    x, y + height
  }
  love.graphics.setColor(self.lightColor)
  love.graphics.setLineStyle("rough")
  love.graphics.line(points)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the window titlebar content
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultSkin:drawWindowTitleBarContent(window, x, y)
  local width = window.size.width
  love.graphics.printf(window.title, x, y + 3, width, "center")
end

return DefaultSkin
