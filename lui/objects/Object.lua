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
  self.isPressed = false

  self.isDragging = false
  self.isHovered = false

  self.size = { width = 0, height = 0 }
  self.position = { top = 0, left = 0 }
  self.padding = {
    top = 0,
    left = 0,
    right = 0,
    bottom = 0
  }
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
--  @param {String} coordinate
--  @param {Boolean} ownSize
--  @returns {Number}
--  @private
function Object:_evaluateNumber(value, coordinate, ownSize)
  assert(coordinate, "Object:_evaluateNumber needs a coordinate")

  local baseObject = self.parent
  if ownSize then
    baseObject = self
  end

  if type(value) == "string" then
    local baseWidth, baseHeight = baseObject:getInnerSize()

    assert(string.find(value, "%%"), "Value " .. value .. " is a string, but does not contain `%`.")

    -- Remove %
    value = string.gsub(value, "%%", "")

    -- Get parent size
    if coordinate == "x" then
      local width = baseWidth
      return width / 100 * value
    elseif coordinate == "y" then
      local height = baseHeight
      return height / 100 * value
    end
  else
    return value
  end
end

--- Returns the x or y position for the given positions table
--  @param {Table} positions
--  @param {String} coordinate
--  @returns {Number}
--  @private
function Object:_evaluatePosition(position, coordinate)
  if coordinate == "x" then
    if position.left then
      return self:_evaluateNumber(position.left, "x")
    elseif position.right then
      local parentWidth, parentHeight = self.parent:getSize()
      local width, height = self:getSize()
      local right = self:_evaluateNumber(position.right, "x")

      return parentWidth - width - right
    end
  else
    if position.top then
      return self:_evaluateNumber(position.top, "y")
    elseif position.bottom then
      local parentWidth, parentHeight = self.parent:getSize()
      local width, height = self:getSize()
      local bottom = self:_evaluateNumber(position.bottom, "y")

      return parentHeight - height - bottom
    end
  end
end

--- Handles mouse interaction
--  @param {Number} dt
--  @private
function Object:_handleMouse(dt)
  self:_handleHover()
  self:_handleClick()

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
      if not self.isHovered then
        self:emit("hover", self)
        self.isHovered = true
      end
  else
    -- Update hovered state, emit `blur` event
    if self.isHovered then
      self.isHovered = false
      self:emit("blur", self)
    end
  end
end

--- Handles object clicking
--  @private
function Object:_handleClick()
  local mouseDown = love.mouse.isDown("l")
  if self.isHovered and mouseDown and not self.isPressed then
    self:emit("mousepressed")
    self.isPressed = true
  else
    if not mouseDown and self.isPressed then
      self:emit("mousereleased")
      self.isPressed = false
      if self.isHovered then
        self:emit("click")
      end
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
    self.isHovered = true
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
  local x = self:_evaluatePosition(self.position, "x")
  local y = self:_evaluatePosition(self.position, "y")

  if self.parent then
    -- Add parent offset
    local parentX, parentY = self.parent:getPosition()
    x = x + parentX
    y = y + parentY

    -- Add parent padding
    local top, right, bottom, left = self.parent:getPadding()
    x = x + left
    y = y + top
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

--- Gets the inner size
--  @returns {Number, Number}
--  @public
function Object:getInnerSize()
  local width, height = self:getSize()

  local top, right, bottom, left = 0, 0, 0, 0
  if self.parent then
    top, right, bottom, left = self.parent:getPadding()
  end

  local paddingX = left + right
  local paddingY = top + bottom

  return width - paddingX, height - paddingY
end

--- Gets the padding
--  @returns {Number, Number}
--  @private
function Object:getPadding()
  local top = self:_evaluateNumber(self.padding.top, "y", true)
  local right = self:_evaluateNumber(self.padding.right, "x", true)
  local bottom = self:_evaluateNumber(self.padding.bottom, "y", true)
  local left = self:_evaluateNumber(self.padding.left, "x", true)
  return top, right, bottom, left
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
--  Object:setPosition(x, y)
--    @param {Number|String} x
--    @param {Number|String} y
--  Object:setPosition(positions)
--    @param {Table} positions
--  @public
function Object:setPosition(x, y)
  if type(x) == "table" then
    assert(
      not (self.position.left and self.position.right),
      "setPosition: `left` and `right` must not be set at the same time."
    )
    assert(
      not (self.position.top and self.position.bottom),
      "setPosition: `top` and `bottom` must not be set at the same time."
    )
    self.position = x
  else
    self.position = {
      left = x,
      top = y
    }
  end
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
--  @param {Number|String} top
--  @param {Number|String} right
--  @param {Number|String} bottom
--  @param {Number|String} left
--  @public
function Object:setPadding(top, right, bottom, left)
  if top ~= nil then self.padding.top = top end
  if right ~= nil then self.padding.right = right end
  if bottom ~= nil then self.padding.bottom = bottom end
  if left ~= nil then self.padding.left = left end
end

--- Sets the parent
--  @param {Object} object
--  @public
function Object:setParent(object)
  self.parent = object
end

return Object
