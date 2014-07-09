local pathMatch = "(.+)%.objects.Object$"
local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Util = require((...):match(pathMatch) .. ".lib.Util")
local EventEmitter = require((...):match(pathMatch) .. ".lib.EventEmitter")

local Object = class("Object", EventEmitter)

--- `Object` constructor
--  @param {lui} lui
function Object:initialize(lui)
  self.lui = lui

  EventEmitter.initialize(self)

  self.children = {}

  -- Decides whether `position` should be relative to its parent
  -- or absolute (= relative to screen / window)
  self.positionMode = "relative"

  -- States
  self.dragging = false
  self.hovering = false

  self.size = { width = 0, height = 0 }
  self.position = { x = 0, y = 0 }
  self.padding = { x = 0, y = 0 }

  self.isVisible = false
  self.isDraggable = false
end

--- Update method
--  @param {Number} dt
function Object:update(dt)
  self:_handleMouse(dt)

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

--- Gets the drawing position (considering positionMode, offset etc.)
--  @returns {Number, Number}
--  @private
function Object:_getRealPosition()
  local x = self:_evaluateNumber(self.position.x, "x")
  local y = self:_evaluateNumber(self.position.y, "y")
  return x, y
end

--- If the given value is a string containing %, this
--  function converts it to a number
--  @param {String|Number} value
--  @param {Number} direction
--  @returns {Number}
--  @private
function Object:_evaluateNumber(value, direction)
  assert(direction, "Object:_evaluateNumber needs a direction")

  if type(value) == "string" then
    assert(string.find(value, "%%"), "Value " .. value .. " is a string, but does not contain `%`.")

    -- Remove %
    value = string.gsub(value, "%%", "")

    -- Get parent size
    if direction == "x" then
      local width = self.parent.size.width
      return width / 100 * value
    elseif direction == "y" then
      local height = self.parent.size.height
      return height / 100 * value
    end
  else
    return value
  end
end

--- Handles mouse interaction
--  @param {Number} dt
--  @private
function Object:_handleMouse(dt)
  self:_handleHover()

  if self.isDraggable then
    self:_handleDragging()
  end
end

--- Handles hover states
--  @private
function Object:_handleHover()
  local x, y = self:_getRealPosition()
  local width = self:_evaluateNumber(self.size.width, "x")
  local height = self:_evaluateNumber(self.size.height, "y")

  -- Rectangular intersection
  local mouseX, mouseY = love.mouse.getPosition()
  if not (mouseX < x or
    mouseX > x + width or
    mouseY < y or
    mouseY > y + height) then
      -- Update hovered state, emit `hover` event
      if not self.hovered then
        self:emit("hover", self)
        self.hovered = true
      end
  else
    -- Update hovered state, emit `blur` event
    if self.hovered then
      self.hovered = false
      self:emit("blur", self)
    end
  end
end

--- Handles object dragging
--  @private
function Object:_handleDragging()
  -- Handle dragging state
  local mouseDown = love.mouse.isDown("l")
  local mouseOnDraggingArea = self:_isMouseOnDraggingArea()
  if mouseDown and not self.dragging and mouseOnDraggingArea then
    -- Not dragging but mouse is down, start dragging
    local x, y = love.mouse.getPosition()
    self.lastDragPosition = {
      x = x,
      y = y
    }
    self.dragging = true
  elseif not mouseDown and self.dragging then
    -- Mouse is not down but dragging still active, stop dragging
    self.dragging = false
  elseif mouseDown and self.dragging then
    -- Dragging
    self:_updateDragging()
  end

  -- If we're dragging, we're also hovering
  if self.dragging then
    self.hovering = true
  end
end

--- Update the position when dragging
--  @private
function Object:_updateDragging()
  local x, y = love.mouse:getPosition()
  local lastX, lastY = self.lastDragPosition.x, self.lastDragPosition.y

  -- Calculate distance
  local distX, distY = x - lastX, y - lastY

  -- Add distance to current position
  local windowX, windowY = self:_getRealPosition()
  self:setPosition(windowX + distX, windowY + distY)

  self.lastDragPosition.x = x
  self.lastDragPosition.y = y
end

--- Is the mouse on the title bar?
--  @returns {Boolean}
--  @private
function Object:_isMouseOnDraggingArea()
  -- Quit early if not hovering
  if not self.hovered then
    return false
  end

  local x, y = self:_getRealPosition()
  local mouseX, mouseY = love.mouse.getPosition()
  local mousePosition = { x = mouseX, y = mouseY }
  local draggingArea = {
    x = x + self:_evaluateNumber(self.draggingArea.x, "x"),
    y = y + self:_evaluateNumber(self.draggingArea.y, "y"),
    width = self:_evaluateNumber(self.draggingArea.width, "x"),
    height = self:_evaluateNumber(self.draggingArea.height, "y")
  }
  return Util.pointIntersectsWithRect(mousePosition, draggingArea)
end

--[[
  Public methods
]]--

--- Calls fn for each child
--  @param {Function} fn
--  @param {Boolean} recursive
--  @private
function Object:eachChild(fn, recursive)
  for _, child in pairs(self.children) do
    fn(child)
    if recursive then
      child:eachChild(fn, true)
    end
  end
end

--- Adds a child to this object
--  @param {Object} object
function Object:addChild(object)
  self.children[#self.children + 1] = object
  object.parent = self
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

-- Sets the size
function Object:setSize(width, height)
  if width ~= nil then self.size.width = width end
  if height ~= nil then self.size.height = height end
end

return Object
