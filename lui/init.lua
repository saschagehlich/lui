local path = ...
local class = require(path .. ".lib.middleclass")
local DefaultSkin = require(path .. ".skins.Default")

local lui = class("lui")

lui.availableObjects = {
  "Object", "Window"
}

--- The main entry point / constructor
--  @param {Table} config
function lui:initialize(config)
  self.config = config
  self.skin = DefaultSkin(self)
  self.objects = {}

  self:buildCreators()

  self.root = self:createObject()
end

--- Builds `lui:create{ObjectName}` methods for all available object types
function lui:buildCreators()
  for _, objectName in ipairs(self.availableObjects) do
    -- Get class
    local class = require(path .. ".objects." .. objectName)
    assert(class, "Object type " .. objectName .. " could not be found.")

    -- Create generator method
    self["create" .. objectName] = function(...)
      local newObject = class(...)
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
