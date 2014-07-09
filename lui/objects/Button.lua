local pathMatch = "(.+)%.objects.Button$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Button = class("Button", Object)

--- `Button` constructor
--  @param {lui} lui
--  @param {String} text
function Button:initialize(lui, text)
  Object.initialize(self, lui)

  self.text = text
  self.size = { width = 100, height = 50 }
end

--- Draws the Button
function Button:draw()
  self.lui.skin:drawButton(self)

  Object.draw(self)
end

return Button
