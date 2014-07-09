local path = ...
local class = require(path .. ".lib.middleclass")
local DefaultSkin = require(path .. ".skins.Default")

local lui = class("lui")

lui.availableObjects = {
  "Object", "Root", "Group",

  "Window", "Panel",
  "Button", "Text", "Image"
}

--- The main entry point / constructor
--  @param {Table} config
function lui:initialize(config)
  self.config = config
  self.skin = DefaultSkin(self)
  self.objects = {}

  -- States
  self.isHovered = false

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
  self.isHovered = false

  self.root:eachChild(function (object)
    if self.isHovered then return end
    if object.isHovered then
      self.isHovered = object.isHovered
    end
  end, true)
end

--- Sets the cursor, remembers the object that changed it
--  @param {String|Cursor} cursor
--  @param {Object} object
--  @public
function lui:setCursor(cursor, object)
  if type(cursor) == "string" then
    cursor = love.mouse.getSystemCursor(cursor)
  end

  love.mouse.setCursor(cursor)
  self.mouseCursorObject = object

  object:on("removed", function()
    self:resetCursor()
  end)
end

--- Resets the cursor
--  @public
function lui:resetCursor()
  love.mouse.setCursor()
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
