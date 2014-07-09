local pathMatch = "(.+)%.objects.Window$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Window = class("Window", Object)

--- `Window` constructor
--  @param {lui} lui
--  @param {String} title
function Window:initialize(lui, title)
  Object.initialize(self, lui)

  self.isVisible = false
  self.isDraggable = true

  self.title = title or "New Window"
  self.size = { width = 250, height = 200 }
  self.padding = self.lui.skin.windowPadding

  self.draggingArea = {
    x = 0,
    y = 0,
    width = "100%",
    height = self.lui.skin.windowTitleBarHeight
  }

  -- Window objects are automatically added to root
  self.lui.root:addChild(self)
end

--- Draws the window
function Window:draw()
  self.lui.skin:drawWindow(self)

  Object.draw(self)
end

return Window
