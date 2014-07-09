local pathMatch = "(.+)%.objects.Panel$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Panel = class("Panel", Object)

--- `Panel` constructor
--  @param {lui} lui
--  @param {String} text
function Panel:initialize(lui)
  Object.initialize(self, lui)
end

--- Draws the Panel
function Panel:draw()
  if self.isVisible then
    self.lui.skin:drawPanel(self)
  end

  Object.draw(self)
end

return Panel
