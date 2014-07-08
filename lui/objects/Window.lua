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
end

return Window
