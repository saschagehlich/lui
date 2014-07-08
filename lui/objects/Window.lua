local pathMatch = "(.+)%.objects.Window$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Window = class("Window", Object)

--- `Window` constructor
--  @param {lui} lui
--  @param {String} title
function Window:initialize(lui, title)
  Object.initialize(self, lui)

  self.title = title or "New Window"
  self.size = { width = 250, height = 200 }
  self.padding = self.lui.skin.windowPadding

  self.titleHitboxHeight = self.lui.skin.windowTitleBarHitboxHeight

  -- Window objects are automatically added to root
  self.lui.root:addChild(self)
end

--- Draws the window
function Window:draw()
  self.lui.skin:drawWindow(self)
end

return Window
