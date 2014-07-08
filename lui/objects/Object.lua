local pathMatch = "(.+)%.objects.Object$"
local class = require((...):match(pathMatch) .. ".lib.middleclass")

local Object = class("Object")

--- `Object` constructor
--  @param {lui} lui
function Object:initialize(lui)
  self.lui = lui

  self.children = {}

  -- Decides whether `position` should be relative to its parent
  -- or absolute (= relative to screen / window)
  self.positionMode = "relative"

  self.size = { width = 0, height = 0 }
  self.position = { x = 0, y = 0 }
  self.padding = { x = 0, y = 0 }

  self.isVisible = false
end

--- Update method
--  @param {Number} dt
function Object:update(dt)
  -- Update children
  self:eachChild(function (object)
    object:update(dt)
  end)
end

--- Draws the object
function Object:draw()
  -- Draw children
  self:eachChild(function (object)
    object:draw()
  end)
end

--- Calls fn for each child
--  @param {Function} fn
function Object:eachChild(fn)
  for _, child in pairs(self.children) do
    fn(child)
  end
end

--- Adds a child to this object
--  @param {Object} object
function Object:addChild(object)
  self.children[#self.children + 1] = object
  object.parent = self
end

--- Gets the drawing position (considering positionMode, offset etc.)
--  @returns {Number, Number}
function Object:_getRealPosition()
  return self.position.x, self.position.y
end

--- Displays the object
function Object:show()
  self.isVisible = true
end

--- Hides the object
function Object:hide()
  self.isVisible = false
end

-- Sets the position
function Object:setPosition(x, y)
  if x ~= nil then self.position.x = x end
  if y ~= nil then self.position.y = y end
end

return Object
