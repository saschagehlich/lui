local pathMatch = "(.+)%.objects.Object$"
local pathBase = (...):match(pathMatch)
local class = require(pathBase .. ".lib.middleclass")
local calc = require(pathBase .. ".lib.calc")
local Util = require(pathBase .. ".lib.Util")

-- Mixins
local EventEmitter = require(pathBase .. ".objects.mixins.EventEmitter")
local Hoverable = require(pathBase .. ".objects.mixins.Hoverable")
local Clickable = require(pathBase .. ".objects.mixins.Clickable")
local Draggable = require(pathBase .. ".objects.mixins.Draggable")
local Tooltippable = require(pathBase .. ".objects.mixins.Tooltippable")

local Object = class("Object")
Object:include(EventEmitter)
Object:include(Hoverable)
Object:include(Clickable)
Object:include(Draggable)
Object:include(Tooltippable)

--- `Object` constructor
--  @param {lui} lui
function Object:initialize(lui)
  self.lui = lui

  self.parent = nil
  self.center = nil
  self.lockedToObject = nil
  self.centerFlags = { x = false, y = false }
  self.children = {}
  self.internals = {}

  -- `absolute` = ignore padding
  -- `relative` = add padding to position
  self.positionMode = "relative"

  -- States
  self.isRemoved = false
  self.isVisible = true

  self.size = { width = 0, height = 0 }
  self.position = { top = 0, left = 0 }
  self.padding = {
    top = 0,
    left = 0,
    right = 0,
    bottom = 0
  }

  EventEmitter._init(self)
  Hoverable._init(self)
  Clickable._init(self)
  Draggable._init(self)
  Tooltippable._init(self)
end

--- Update method
--  @param {Number} dt
function Object:update(dt)
  -- Don't update if invisible!
  if not self.isVisible then return end

  self:_removeDeadChildren() -- :(

  self:_updateHoverable(dt)
  self:_updateClickable(dt)
  self:_updateDraggable(dt)
  self:_updateTooltippable(dt)

  -- Update children
  self:eachChild(function (object)
    object:update(dt)
  end)

  -- Update internals
  self:eachInternal(function (object)
    object:update(dt)
  end)
end

--- Removes children flagged as removed
function Object:_removeDeadChildren()
  for i, child in ipairs(self.children) do
    if child.isRemoved then
      table.remove(self.children, i)
    end
  end
end

--- Draws the object
function Object:draw()
  -- Don't draw if invisible!
  if not self.isVisible then return end

  -- Draw children
  self:eachChild(function (object)
    object:draw()
  end)

  -- Draw internals
  self:eachInternal(function (object)
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
    local ignorePadding = self.positionMode == "absolute"
    local baseWidth, baseHeight = baseObject:getInnerSize(ignorePadding)

    -- Get parent size
    local baseValue
    if coordinate == "x" then
      baseValue = baseWidth
    elseif coordinate == "y" then
      baseValue = baseHeight
    end

    for percentage in value:gmatch("%d+%%") do
      local num = percentage:match("(%d+)")
      local newNum = math.floor(baseValue / 100 * num)
      value = value:gsub("%d+%%", newNum)
    end

    for variable in value:gmatch("%a+") do
      local name = variable:match("%a+")
      local num = 0

      if name == "y" then
        num = self:getY(true)
      elseif name == "x" then
        num = self:getX(true)
      elseif name == "width" then
        num = self:getWidth()
      elseif name == "height" then
        num = self:getHeight()
      else
        error("Unknown variable in formula: " .. name)
      end

      value = value:gsub(name, num)
    end

    return calc(value)
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
  local ignorePadding = self.positionMode == "absolute"
  if coordinate == "x" then
    if position.left then
      return self:_evaluateNumber(position.left, "x")
    elseif position.right then
      local parentWidth = self.parent:getInnerWidth(ignorePadding)
      local width = self:getInnerWidth()
      local right = self:_evaluateNumber(position.right, "x")

      return parentWidth - width - right
    end
  else
    if position.top then
      return self:_evaluateNumber(position.top, "y")
    elseif position.bottom then
      local parentWidth, parentHeight = self.parent:getInnerSize(ignorePadding)
      local width, height = self:getInnerSize()
      local bottom = self:_evaluateNumber(position.bottom, "y")

      return parentHeight - height - bottom
    end
  end
end

--[[
  Public methods
]]--

--- Gets the drawing position (considering offset etc.)
--  @param {Boolean} relative
--  @returns {Number, Number}
--  @public
function Object:getPosition(relative)
  return self:getX(relative), self:getY(relative)
end

--- Gets the X position of this object
--  @param {Boolean} relative
--  @returns {Number}
--  @public
function Object:getX(relative)
  local x = self:_evaluatePosition(self.position, "x")

  if self.parent and not relative then
    -- Add parent offset
    local parentX, parentY = self.parent:getPosition()
    x = x + parentX

    -- Add parent padding
    if self.positionMode == "relative" then
      local top, right, bottom, left = self.parent:getPadding()
      x = x + left
    end
  end

  -- If centering is enabled for x or y, set the position to
  -- the center
  if self.center and self.centerFlags.x then
    local centerX, centerY = self:getPositionByCenter()
    local width = self:getWidth()
    x = centerX - width / 2
  end

  return Util.round(x)
end

--- Gets the Y position of this object
--  @param {Boolean} relative
--  @returns {Number}
--  @public
function Object:getY(relative)
  local y = self:_evaluatePosition(self.position, "y")

  if self.parent and not relative then
    -- Add parent offset
    local parentX, parentY = self.parent:getPosition()
    y = y + parentY

    -- Add parent padding
    if self.positionMode == "relative" then
      local top, right, bottom, left = self.parent:getPadding()
      y = y + top
    end
  end

  -- If centering is enabled for x or y, set the position to
  -- the center
  if self.center then
    local centerX, centerY = self:getPositionByCenter()
    local height = self:getHeight()
    if self.centerFlags.y then
      y = centerY - height / 2
    end
  end

  return Util.round(y)
end

--- Gets the position by the currently set `center` object / position
--  @returns {Number, Number}
--  @public
function Object:getPositionByCenter()
  local center = self.center
  local width, height = self:getSize()

  -- Find current center positions
  local centerX, centerY
  if center.class then
    centerX, centerY = center:getCenterPosition()
  else
    centerX, centerY = self.center.x, self.center.y
  end

  return centerX, centerY
end

--- Returns the center position of this object
--  @returns {Number, Number}
--  @public
function Object:getCenterPosition()
  local x, y = self:getPosition()
  local width, height = self:getSize()

  return math.floor(x + width / 2), math.floor(y + height / 2)
end

--- Gets the drawing size
--  @returns {Number, Number}
--  @public
function Object:getSize()
  local width = self:getWidth()
  local height = self:getHeight()
  return width, height
end

--- Gets the drawing width
--  @returns {Number}
--  @public
function Object:getWidth()
  return self:_evaluateNumber(self.size.width, "x")
end

--- Gets the drawing height
--  @returns {Number}
--  @public
function Object:getHeight()
  return self:_evaluateNumber(self.size.height, "y")
end

--- Gets the inner size
--  @param {Boolean} ignorePadding
--  @returns {Number, Number}
--  @public
function Object:getInnerSize(ignorePadding)
  return self:getInnerWidth(ignorePadding), self:getInnerHeight(ignorePadding)
end


--- Gets the inner width
--  @param {Boolean} ignorePadding
--  @returns {Number}
--  @public
function Object:getInnerWidth(ignorePadding)
  local width = self:getWidth()
  local paddingX = 0
  if self.positionMode == "relative" and not ignorePadding then
    local top, right, bottom, left = self:getPadding()
    paddingX = left + right
  end

  return width - paddingX
end

--- Gets the inner height
--  @param {Boolean} ignorePadding
--  @returns {Number}
--  @public
function Object:getInnerHeight(ignorePadding)
  local height = self:getHeight()
  local paddingY = 0
  if self.positionMode == "relative" and not ignorePadding then
    local top, right, bottom, left = self:getPadding()
    paddingY = top + bottom
  end

  return height - paddingY
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

--- Calls fn for each internal
--  @param {Function} fn
--  @param {Boolean} recursive
--  @public
function Object:eachInternal(fn, recursive)
  for _, child in pairs(self.internals) do
    fn(child)
    if recursive then
      child:eachInternal(fn, true)
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

--- Adds an internal to this object
--  @param {Object} object
--  @public
function Object:addInternal(object)
  self.internals[#self.internals + 1] = object
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

--- Centers this object
--  @param {Number} x
--  @param {Number} y
--  @param {Boolean} centerX
--  @param {Boolean} centerY
--  @public
--
--  Possible signatures:
--    Object:setCenter([Boolean centerX, Boolean centerY])
--      Moves to the center of the parent. `centerX` and `centerY` specify
--      if object should be centered on the x or y axis
--    Object:setCenter(Number x, Number y[, Boolean centerX, Boolean centerY])
--      Same as above with fixed center point (x,y)
--    Object:setCenter(Object[, Boolean centerX, centerY])
--      Same as above with fixed center object
function Object:setCenter(x, y, centerX, centerY)
  local centerPoint

  -- setCenter(number, number)
  if type(x) == "number" then
    centerPoint = { x = x, y = y }
  end

  -- setCenter(Object)
  if type(x) == "table" then
    centerPoint = x
    centerX = y
    centerY = centerX
  end

  -- setCenter() / setCenter(bool, bool)
  if type(x) == "boolean" or x == nil then
    centerPoint = self.parent
    centerX = x
    centerY = y
  end

  if centerX == nil then centerX = true end
  if centerY == nil then centerY = true end

  self.center = centerPoint
  self.centerFlags = { x = centerX, y = centerY }
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

  -- Unset center object when moving
  self.center = nil
end

--- Sets the size
--  @param {Number|String} width
--  @param {Number|String} height
--  @public
function Object:setSize(width, height)
  self.size.width = width
  self.size.height = height
end

--- Sets the inner size (the given size + paddings)
--  @param {Number} width
--  @param {Number} height
--  @public
function Object:setInnerSize(width, height)
  assert(
    (type(width) == "number" and type(height) == "number"),
    "Right now, arguments passed to Object:setInnerSize have to be numbers."
  )

  local top, right, bottom, left = self:getPadding()
  self:setSize(width + left + right, height + top + bottom)
end

--- Sets the padding
--  @param {Number|String} top
--  @param {Number|String} right
--  @param {Number|String} bottom (optional)
--  @param {Number|String} left (optional)
--  @public
function Object:setPadding(top, right, bottom, left)
  if bottom == nil and left == nil then
    local vertical, horizontal = top, right
    self.padding.top = vertical
    self.padding.right = horizontal
    self.padding.bottom = vertical
    self.padding.left = horizontal
  else
    self.padding.top = top
    self.padding.right = right
    self.padding.bottom = bottom
    self.padding.left = left
  end
end

--- Sets the position mode
--  @param {String} positionMode (absolute|relative)
--  @public
function Object:setPositionMode(positionMode)
  assert(
    Util.contains({ "absolute", "relative" }, positionMode),
    "Object:setPositionMode: Invalid mode: " .. positionMode ..
    " (available options: relative, absolute)"
  )

  self.positionMode = positionMode
end

--- Sets the parent
--  @param {Object} object
--  @public
function Object:setParent(object)
  self.parent = object
end

--- Removes this object and all its children
--  @public
function Object:remove()
  self.isRemoved = true

  self:eachChild(function (child)
    child:remove()
  end)

  self:eachInternal(function (child)
    child:remove()
  end)

  self:emit("removed")
  if self.tooltip then
    self.tooltip:remove()
  end
end

--- Sets the object that this object is locked to. If this object is
--  draggable, the user won't be able to drag it outside the given object.
--  @param {Object} object
function Object:setLockedTo(object)
  self.lockedToObject = object
end

--- Sets the given object as the tooltip
--  @param {Object} object
--  @public
function Object:setTooltip(object)
  self.tooltip = object
  self.tooltip:hide()
end

--- Specifies the delay after which the tooltip should be displayed
--  @param {Number} delay
--  @public
function Object:setTooltipDelay(delay)
  self.tooltipDelay = delay
end

--- Specifies whether or not the tooltip should follow the mouse position
--  @param {Boolean} bool
--  @public
function Object:setTooltipFollowsMouse(bool)
  self.tooltipFollowsMouse = bool
end

--- Specifies the distance between the cursor and the tooltip
--  @param {Number} x
--  @param {Number} y
--  @public
function Object:setTooltipDistance(x, y)
  self.tooltipDistance = { x = x, y = y }
end

--- If no argument is given, this method moves itself up in the parent's
--  children. If an object is given, it will be sorted up in this object's
--  children
--  @param {Object} [object]
--  @public
function Object:moveToTop(object)
  if object then
    table.sort(self.children, function (a, b)
      if a == object then
        return false
      elseif b == object then
        return true
      else
        return nil
      end
    end)
  else
    self.parent:moveToTop(self)
  end
end

return Object
