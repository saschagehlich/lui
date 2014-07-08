local pathMatch = "(.+)%.objects.Object$"
local class = require((...):match(pathMatch) .. ".lib.middleclass")

local Object = class("Object")

--- `Object` constructor
--  @param {lui} lui
function Object:initialize(lui)
  self.lui = lui

  self.isVisible = false
end

--- Displays the object
function Object:show()
  self.isVisible = true
end

--- Hides the object
function Object:hide()
  self.isVisible = false
end

return Object
