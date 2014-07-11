local path = ...
local class = require(path .. ".lib.middleclass")
local EventEmitter = require(path .. ".objects.mixins.EventEmitter")

local lui = class("lui")

lui.availableObjects = {
  "Object", "Root", "Group",
  "Window", "Panel", "Tooltip",
  "Button", "Text", "Image",
  "List", "ListItem", "ScrollBar",
  "Tabs", "Tab"
}

lui.availableSchemes = {
  Blue = require(path .. ".schemes.Blue"),
  Gray = require(path .. ".schemes.Gray"),
  Red = require(path .. ".schemes.Red")
}

lui.availableThemes = {
  Default = require(path .. ".themes.Default")
}

function lui.percent (value)
  return { value = value, type = "percent" }
end

lui:include(EventEmitter)

--- The main entry point / constructor
--  @param {Table} config
function lui:initialize(config)
  self.config = config
  self.objects = {}

  -- States
  self.isHovered = false
  self.isDragging = false
  self.isPressed = false

  self:_buildCreators()

  self.defaultTheme = self:getTheme("Default")
  self.defaultScheme = self:getScheme("Blue")

  self.root = self:createRoot()

  EventEmitter._init(self)
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
  object:on("dragstart", self._onDragStart, self)
  object:on("dragend", self._onDragEnd, self)
  object:on("mousepressed", self._onMousePressed, self)
  object:on("mousereleased", self._onMouseReleased, self)
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

--- Gets called when the user drags an object
--  @private
function lui:_onDragStart()
  self.isDragging = true
end

--- Gets called when the user is no longer dragging an object
--  @private
function lui:_onDragEnd()
  self.isDragging = false
end

--- Gets called when the user pressed the mouse button on an object
--  @private
function lui:_onMousePressed()
  self.isPressed = true
end

--- Gets called when the user is no longer pressing the mouse button on
--  an object
--  @private
function lui:_onMouseReleased()
  self.isPressed = false
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

--- Returns the theme with the given name
--  @param {String} name
--  @returns {Theme} theme
--  @public
function lui:getTheme(name)
  assert(
    self.availableThemes[name],
    "Theme " .. name .. " does not exist."
  )
  return self.availableThemes[name](self.lui)
end

--- Returns the color scheme with the given name
--  @param {String} name
--  @returns {Scheme} theme
--  @public
function lui:getScheme(name)
  assert(
    self.availableSchemes[name],
    "Scheme " .. name .. " does not exist."
  )
  return self.availableSchemes[name]
end

--- Gets called when the love's mousepressed method has been
--  called. Emits an event so that other objects can grab it.
--  @param {Number} x
--  @param {Number} y
--  @param {MouseConstant} button
function lui:mousepressed(x, y, button)
  self:emit("mousepressed", x, y, button)
end

--- Returns the path for the given theme
--  @param {String} themeName
--  @returns {String}
--  @public
function lui:getThemePath(themeName)
  return path .. "/themes/" .. themeName.pathName
end

return lui
