local path = ...
local class = require(path .. "/lib.middleclass")

local lui = class("lui")

lui.availableObjects = {
  "Window"
}

--- The main entry point / constructor
--  @param {Table} config
function lui:initialize(config)
  self.config = config
  self.objects = {}

  self:buildCreators()
end

--- Builds `lui:create{ObjectName}` methods for all available object types
function lui:buildCreators()
  for _, objectName in ipairs(self.availableObjects) do
    -- Get class
    local class = require(path .. ".objects." .. objectName)
    assert(class, "Object type " .. objectName .. " could not be found.")

    -- Create generator method
    self["create" .. objectName] = function(...)
      local newObject = class(self, ...)
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

--- Calls `fn` for each existing object
--  @param {Function} fn
function lui:eachObject(fn)
  for _, object in ipairs(self.objects) do
    fn(object)
  end
end

--- Updates all objects
--  @param {Number} dt
function lui:update(dt)
  self:eachObject(function (object)
    object:update(dt)
  end)
end

--- Draws all objects
function lui:draw()
  self:eachObject(function (object)
    object:draw()
  end)
end

return lui
