local pathMatch = "(.+)%.objects.Group$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Group = class("Group", Object)

--- `Group` constructor
--  @param {lui} lui
--  @param {String} text
function Group:initialize(lui)
  Object.initialize(self, lui)
end

return Group
