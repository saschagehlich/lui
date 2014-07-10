local pathMatch = "(.+)%.objects.Window$"
local basePath = (...):match(pathMatch)

local class = require(basePath .. ".lib.middleclass")
local Object = require(basePath .. ".objects.Object")

local Window = class("Window", Object)

--- `Window` constructor
--  @param {lui} lui
--  @param {String} title
function Window:initialize(lui, title)
  Object.initialize(self, lui)

  self.isVisible = false
  self.isDraggable = true
  self.showCloseButton = true

  self.title = title or "New Window"
  self.size = { width = 250, height = 200 }
  self.padding = self.theme.windowPadding

  self.draggingArea = {
    x = 0,
    y = 0,
    width = lui.percent(100),
    height = self.theme.windowTitleBarHeight
  }

  self:_createCloseButton()

  -- Window objects are automatically added to root
  self.lui.root:addChild(self)
end

--- Since we get the default window padding and the
--  title bar height from the theme, we need to reset
--  it when the theme changes
--  @param {Theme} theme
--  @public
function Window:setTheme(theme)
  Object.setTheme(self, theme)

  self.padding = self.theme.windowPadding
  self.draggingArea.height = self.theme.windowTitleBarHeight
end

--- Creates the close button
--  @private
function Window:_createCloseButton()
  local size = self.theme.windowTitleBarHeight

  self.closeButton = self.lui:createButton()
  self.closeButton:setSize(size, size)
  self.closeButton:setPositionMode("absolute")
  self.closeButton:setPosition({ right = 2, top = 2 })
  self.closeButton:on("click", self._onCloseClick, self)

  local tooltip = self.lui:createTooltip("Close")
  self.closeButton:setTooltip(tooltip)

  self:addInternal(self.closeButton)

  self.closeImage = self.lui:createImage(self.lui:getThemePath(self.theme) .. "/window/close.png")
  self.closeButton:addChild(self.closeImage)

  self.closeImage:setCenter()
end

--- Gets called when the user clicks on the close button
--  @private
function Window:_onCloseClick()
  self:remove()
  self:emit("close", self)
end

--- Draws the window
function Window:draw()
  self.theme:drawWindow(self)

  Object.draw(self)
end

--- Shows / hides the close button
--  @param {Boolean} bool
--  @public
function Window:setShowCloseButton(bool)
  self.showCloseButton = bool
  if not self.showCloseButton then
    self.closeButton:hide()
  else
    self.closeButton:show()
  end
end

return Window
