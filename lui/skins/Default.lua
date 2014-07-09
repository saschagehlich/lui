local pathMatch = "(.+)%.skins.Default$"
local basePath = (...):match(pathMatch)

local class = require(basePath .. ".lib.middleclass")
local Object = require(basePath .. ".objects.Object")

local DefaultSkin = class("DefaultSkin")

-- Colors
DefaultSkin.windowBackgroundColor = { 112, 131, 125 }
DefaultSkin.panelBackgroundColor = { 159, 183, 111, 128 }
-- DefaultSkin.panelBackgroundColor = { 255, 0, 0, 128 }
DefaultSkin.buttonBackgroundColor = { 112, 131, 125 }
DefaultSkin.buttonPressedBackgroundColor = { 159, 175, 175 }
DefaultSkin.titleBarBackgroundColor = { 47, 67, 67 }

DefaultSkin.lightColor = { 255, 255, 255, 50 }
DefaultSkin.shadowColor = { 0, 0, 0, 50 }

-- Spacings
DefaultSkin.windowPadding = {
  top = 20,
  right = 5,
  bottom = 5,
  left = 5
}
DefaultSkin.windowTitleBarHeight = 12

--- Constructor
--  @param {lui} lui
function DefaultSkin:initialize(lui)
  self.lui = lui
  self.font = love.graphics.newFont(basePath .. "/skins/Default/66amagasaki.ttf", 8)
  self.windowTitleFont = self.font
  self.buttonFont = self.font
end

--- Draws the given window
--  @param {Window} window
function DefaultSkin:drawWindow(window)
  local x, y = window:getPosition()

  self:drawWindowBackground(window, x, y)
  self:drawWindowTitleBarBackground(window, x, y)
  self:drawWindowTitleBarContent(window, x, y)
end

--- Draws the given panel
--  @param {Panel} panel
function DefaultSkin:drawPanel(panel)
  local x, y = panel:getPosition()
  local width, height = panel:getSize()

  -- Draw background
  love.graphics.setColor(self.panelBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(false, x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the given button
--  @param {Button} button
function DefaultSkin:drawButton(button)
  local x, y = button:getPosition()
  local width, height = button:getSize()

  local color = self.buttonBackgroundColor
  local lightingInset = false
  if button.isPressed or button.isToggled then
    color = self.buttonPressedBackgroundColor
    -- lightingInset = true
  end

  love.graphics.setColor(color)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(lightingInset, x, y, width, height)
end

--- Draws the window background
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultSkin:drawWindowBackground(window, x, y)
  local width, height = window:getSize()

  -- Draw background
  love.graphics.setColor(self.windowBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(false, x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the window titlebar background
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultSkin:drawWindowTitleBarBackground(window, x, y)
  local width = window:_evaluateNumber(window.size.width, "x") - 4
  local height = self.windowTitleBarHeight
  local x, y = x + 2, y + 2

  -- Draw background
  love.graphics.setColor(self.titleBarBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(true, x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the lighting
--  @param {Boolean} inset
--  @param {Number} x
--  @param {Number} y
--  @param {Number} width
--  @param {Number} height
function DefaultSkin:drawLighting(inset, x, y, width, height)

  local points
  if inset == true then
    points = {
      x, y + height + 1,
      x, y - 1,
      x + width + 1, y
    }
    love.graphics.setColor(self.shadowColor)
  else
    points = {
      x + 1, y + height,
      x, y,
      x + width, y
    }
    love.graphics.setColor(self.lightColor)
  end
  love.graphics.setLineStyle("rough")
  love.graphics.line(points)

  -- Draw bottom right
  if inset == true then
    points = {
      x + width + 1, y,
      x + width + 1, y + height,
      x, y + height
    }
    love.graphics.setColor(self.lightColor)
  else
    points = {
      x + width, y + 1,
      x + width, y + height - 1,
      x + 1, y + height - 1
    }
    love.graphics.setColor(self.shadowColor)
  end
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
  love.graphics.setFont(self.windowTitleFont)

  local width = window:_evaluateNumber(window.size.width, "x")
  love.graphics.printf(window.title, x, y + 3, width, "center")
end

return DefaultSkin
