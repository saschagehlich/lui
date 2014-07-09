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

  self.parent = nil
  self.children = {}

  -- Decides whether `position` should be relative to its parent
  -- or absolute (= relative to screen / window)
  -- self.positionMode = "relative"

  -- States
  self.isVisible = true
  self.isDraggable = false

  self.isDragging = false
  self.isHovering = false

  self.size = { width = 0, height = 0 }
  self.position = { x = 0, y = 0 }
  self.padding = { x = 0, y = 0 }
end

--- Update method
--  @param {Number} dt
function Object:update(dt)
  -- Don't update if invisible!
  if not self.isVisible then return end

  self:_handleMouse(dt)

  -- Update children
  self:eachChild(function (object)
    object:update(dt)
  end)
end

--- Draws the object
function Object:draw()
  -- Don't draw if invisible!
  if not self.isVisible then return end

  -- Draw children
  self:eachChild(function (object)
    object:draw()
  end)
end

--- If the given value is a string containing %, this
--  function converts it to a number. `ownSize` specifies
--  whether the pixel values should be calculated based on
--  its own size (true) or the parent's size (false)
--  @param {String|Number} value
--  @param {Number} direction
--  @param {Boolean} ownSize
--  @returns {Number}
--  @private
function Object:_evaluateNumber(value, direction, ownSize)
  assert(direction, "Object:_evaluateNumber needs a direction")

  local baseObject = self.parent
  if ownSize then
    baseObject = self
  end

  if type(value) == "string" then
    assert(string.find(value, "%%"), "Value " .. value .. " is a string, but does not contain `%`.")

    -- Remove %
    value = string.gsub(value, "%%", "")

    -- Get parent size
    if direction == "x" then
      local width = baseObject:_evaluateNumber(baseObject.size.width, "x")
      return width / 100 * value
    elseif direction == "y" then
      local height = baseObject:_evaluateNumber(baseObject.size.height, "y")
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
  -- Don't change hovered state when dragging
  if self.dragging then return end

  local x, y = self:getPosition()
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
  if mouseDown and not self.isDragging and mouseOnDraggingArea then
    -- Not dragging but mouse is down, start dragging
    local x, y = love.mouse.getPosition()
    self.lastDragPosition = {
      x = x,
      y = y
    }
    self.isDragging = true
  elseif not mouseDown and self.isDragging then
    -- Mouse is not down but dragging still active, stop dragging
    self.isDragging = false
  elseif mouseDown and self.isDragging then
    -- Dragging
    self:_updateDragging()
  end

  -- If we're dragging, we're also hovering
  if self.isDragging then
    self.isHovering = true
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
  local windowX, windowY = self:getPosition()
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

  local x, y = self:getPosition()
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

--- Gets the drawing position (considering offset etc.)
--  @returns {Number, Number}
--  @public
function Object:getPosition()
  local x = self:_evaluateNumber(self.position.x, "x")
  local y = self:_evaluateNumber(self.position.y, "y")

  if self.parent then
    -- Add parent offset
    local parentX, parentY = self.parent:getPosition()
    x = x + parentX
    y = y + parentY

    -- Add parent padding
    local parentPaddingX, parentPaddingY = self.parent:getPadding()
    x = x + parentPaddingX
    y = y + parentPaddingY
  end

  return x, y
end

--- Gets the drawing size
--  @returns {Number, Number}
--  @public
function Object:getSize()
  local width = self:_evaluateNumber(self.size.width, "x")
  local height = self:_evaluateNumber(self.size.height, "y")
  return width, height
end

--- Gets the padding
--  @returns {Number, Number}
--  @private
function Object:getPadding()
  local x = self:_evaluateNumber(self.padding.x, "x", true)
  local y = self:_evaluateNumber(self.padding.y, "y", true)
  return x, y
end

--- Calls fn for each child
--  @param {Function} fn
--  @param {Boolean} recursive
--  @public
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
--  @public
function Object:addChild(object)
  self.children[#self.children + 1] = object
  object:setParent(self)
end

--- Displays the object
--  @public
function Object:show()
  self.isVisible = true
end

--- Hides the object
--  @public
function Object:hide()
  self.isVisible = false
end

--- Sets the position
--  @param {Number|String} x
--  @param {Number|String} y
--  @public
function Object:setPosition(x, y)
  if x ~= nil then self.position.x = x end
  if y ~= nil then self.position.y = y end
end

--- Sets the size
--  @param {Number|String} width
--  @param {Number|String} height
--  @public
function Object:setSize(width, height)
  if width ~= nil then self.size.width = width end
  if height ~= nil then self.size.height = height end
end

--- Sets the padding
--  @param {Number|String} x
--  @param {Number|String} y
--  @public
function Object:setPadding(x, y)
  if x ~= nil then self.padding.x = x end
  if y ~= nil then self.padding.y = y end
end

--- Sets the parent
--  @param {Object} object
--  @public
function Object:setParent(object)
  self.parent = object
end

return Object
