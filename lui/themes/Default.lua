local pathMatch = "(.+)%.themes.Default$"
local basePath = (...):match(pathMatch)

local class = require(basePath .. ".lib.middleclass")
local Object = require(basePath .. ".objects.Object")

local DefaultTheme = class("DefaultTheme")
DefaultTheme.pathName = "Default"

-- Generic
DefaultTheme.lightColor = { 255, 255, 255, 80 }
DefaultTheme.shadowColor = { 0, 0, 0, 80 }

-- Scrollbars
DefaultTheme.scrollbarSize = 12

-- Spacings
DefaultTheme.windowPadding = {
  top = 30,
  right = 5,
  bottom = 5,
  left = 5
}
DefaultTheme.windowTitleBarHeight = 25

--- Constructor
--  @param {lui} lui
function DefaultTheme:initialize(lui)
  self.lui = lui
  self.font = love.graphics.newFont(12)
  self.windowTitleFont = self.font
  self.buttonFont = self.font
end

--- Draws the given scrollbar
--  @param {ScrollBar} scrollbar
function DefaultTheme:drawScrollBar(scrollbar)
  local x, y = scrollbar:getPosition()
  local width, height = scrollbar:getSize()

  -- Draw background
  love.graphics.setColor(scrollbar.scheme.scrollBarBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the given tooltip
--  @param {Tooltip} tooltip
function DefaultTheme:drawTooltip(tooltip)
  local x, y = tooltip:getPosition()
  local width, height = tooltip:getSize()

  -- Draw background
  love.graphics.setColor(tooltip.scheme.tooltipBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the given list
--  @param {List} list
function DefaultTheme:drawList(list)
  local x, y = list:getPosition()
  local width, height = list:getSize()

  -- Draw background
  love.graphics.setColor(list.scheme.listBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(true, x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the given window
--  @param {Window} window
function DefaultTheme:drawWindow(window)
  local x, y = window:getPosition()

  self:drawWindowBackground(window, x, y)
  self:drawWindowTitleBarBackground(window, x, y)
  self:drawWindowTitleBarContent(window, x, y)
end

--- Draws the given panel
--  @param {Panel} panel
function DefaultTheme:drawPanel(panel)
  local x, y = panel:getPosition()
  local width, height = panel:getSize()

  -- Draw background
  love.graphics.setColor(panel.scheme.panelBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(false, x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the given button
--  @param {Button} button
function DefaultTheme:drawButton(button)
  local x, y = button:getPosition()
  local width, height = button:getSize()

  local color = button.scheme.buttonBackgroundColor
  local lightingInset = false
  if button.isPressed or button.isToggled then
    color = button.scheme.buttonPressedBackgroundColor
    lightingInset = true
  end

  love.graphics.setColor(color)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(lightingInset, x, y, width, height)
end

--- Draws the window background
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultTheme:drawWindowBackground(window, x, y)
  local width, height = window:getSize()

  -- Draw background
  love.graphics.setColor(window.scheme.windowBackgroundColor)
  love.graphics.rectangle("fill", x, y, width, height)

  self:drawLighting(false, x, y, width, height)

  -- Reset color
  love.graphics.setColor(255, 255, 255)
end

--- Draws the window titlebar background
--  @param {Window} window
--  @param {Number} x
--  @param {Number} y
function DefaultTheme:drawWindowTitleBarBackground(window, x, y)
  local width = window:_evaluateNumber(window.size.width, "x") - 4
  local height = self.windowTitleBarHeight
  local x, y = x + 2, y + 2

  -- Draw background
  love.graphics.setColor(window.scheme.windowTitleBarBackgroundColor)
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
function DefaultTheme:drawLighting(inset, x, y, width, height)
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
function DefaultTheme:drawWindowTitleBarContent(window, x, y)
  love.graphics.setFont(self.windowTitleFont)

  local width = window:_evaluateNumber(window.size.width, "x")
  love.graphics.printf(window.title, x, y + 7, width, "center")
end

return DefaultTheme
