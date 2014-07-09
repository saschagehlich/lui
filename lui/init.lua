local path = ...
local class = require(path .. ".lib.middleclass")
local DefaultSkin = require(path .. ".skins.Default")

local lui = class("lui")

lui.availableObjects = {
  "Object", "Root", "Window", "Button"
}

--- The main entry point / constructor
--  @param {Table} config
function lui:initialize(config)
  self.config = config
  self.skin = DefaultSkin(self)
  self.objects = {}

  -- States
  self.hovered = false

  self:_buildCreators()

  self.root = self:createRoot()
end

--- Builds `lui:create{ObjectName}` methods for all available object types
--  @private
function lui:_buildCreators()
  for _, objectName in ipairs(self.availableObjects) do
    -- Get class
    local class = require(path .. ".objects." .. objectName)
    assert(class, "Object type " .. objectName .. " could not be found.")

    -- Creates a new instance of `objectName`
    self["create" .. objectName] = function(...)
      local newObject = class(...)
      self:_onNewObject(newObject)
      self:_addObject(newObject)
      return newObject
    end
  end
end

--- Adds the given object to the objects table
--  @param {Object} object
--  @private
function lui:_addObject(object)
  self.objects[#self.objects + 1] = object
end

--- Gets called when a new object is instantiated, listens for
--  events to update global states
--  @param {Object} object
--  @private
function lui:_onNewObject(object)
  object:on("hover blur", self._updateHoverState, self)
end

--- Iterates over all objects, checks for hovered state
--  @private
function lui:_updateHoverState()
  self.hovered = false

  self.root:eachChild(function (object)
    if self.hovered then return end
    if object.hovered then
      self.hovered = object.hovered
    end
  end, true)
end

--- Updates the root object
--  @param {Number} dt
function lui:update(dt)
  self.root:update(dt)
end

--- Draws the root object
function lui:draw()
  -- Generic styles
  love.graphics.setLineStyle("rough")

  self.root:draw()
end

return lui
