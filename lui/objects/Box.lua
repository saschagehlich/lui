local pathMatch = "(.+)%.objects.Box$"
local pathBase = (...):match(pathMatch)

-- Dependencies
local class = require(pathBase .. ".lib.middleclass")
local Util = require(pathBase .. ".lib.Util")

local Box = class("Box")

--- `Box` constructor
--  @param {lui} lui
function Box:initialize(lui)
  self.lui = lui

  -- `absolute` = ignore padding
  -- `relative` = add padding to position
  self.positionMode = "relative"

  -- Boxing model
  self.parent = nil
  self.children = {}
  self.internals = {}

  -- States
  self.isVisible = true
  self.isRemoved = false

  -- Defaults
  self.center = nil
  self.centerFlags = { x = false, y = false }
  self.size = { width = 0, height = 0 }
  self.position = { top = 0, left = 0 }
  self.offset = { x = 0, y = 0 }
  self.padding = {
    top = 0,
    left = 0,
    right = 0,
    bottom = 0
  }
end

--- Removes children flagged as removed
function Box:_removeDeadChildren()
  for i, child in ipairs(self.children) do
    if child.isRemoved then
      table.remove(self.children, i)
    end
  end
end


--- Removes this object and all its children
--  @public
function Box:remove()
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

--- If no argument is given, this method moves itself up in the parent's
--  children. If an object is given, it will be sorted up in this object's
--  children
--  @param {Object} [object]
--  @public
function Box:moveToTop(object)
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

--- Update method
--  @param {Number} dt
function Box:update(dt)
  self:_removeDeadChildren() -- :(

  -- Update children
  self:eachChild(function (object)
    object:update(dt)
  end)

  -- Update internals
  self:eachInternal(function (object)
    object:update(dt)
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
function Box:_evaluateNumber(value, coordinate, ownSize)
  assert(coordinate, "Box:_evaluateNumber needs a coordinate")

  local baseObject = self.parent
  if ownSize then
    baseObject = self
  end

  if type(value) == "table" then
    local ignorePadding = self.positionMode == "absolute"
    local baseWidth, baseHeight = baseObject:getInnerSize(ignorePadding)

    -- Get parent size
    local baseValue
    if coordinate == "x" then
      baseValue = baseWidth
    elseif coordinate == "y" then
      baseValue = baseHeight
    end

    return baseValue / 100 * value.value
  else
    return value
  end
end

--- Returns the x or y position for the given positions table
--  @param {Table} positions
--  @param {String} coordinate
--  @returns {Number}
--  @private
function Box:_evaluatePosition(position, coordinate)
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
function Box:getPosition(relative)
  return self:getX(relative), self:getY(relative)
end

--- Gets the X position of this object
--  @param {Boolean} relative
--  @returns {Number}
--  @public
function Box:getX(relative)
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

  x = x - self.offset.x

  return Util.round(x)
end

--- Gets the Y position of this object
--  @param {Boolean} relative
--  @returns {Number}
--  @public
function Box:getY(relative)
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

  y = y - self.offset.y

  return Util.round(y)
end

--- Gets the position by the currently set `center` object / position
--  @returns {Number, Number}
--  @public
function Box:getPositionByCenter()
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
function Box:getCenterPosition()
  local x, y = self:getPosition()
  local width, height = self:getSize()

  return math.floor(x + width / 2), math.floor(y + height / 2)
end

--- Gets the drawing size
--  @returns {Number, Number}
--  @public
function Box:getSize()
  local width = self:getWidth()
  local height = self:getHeight()
  return width, height
end

--- Gets the drawing width
--  @returns {Number}
--  @public
function Box:getWidth()
  return self:_evaluateNumber(self.size.width, "x")
end

--- Gets the drawing height
--  @returns {Number}
--  @public
function Box:getHeight()
  return self:_evaluateNumber(self.size.height, "y")
end

--- Gets the inner size
--  @param {Boolean} ignorePadding
--  @returns {Number, Number}
--  @public
function Box:getInnerSize(ignorePadding)
  return self:getInnerWidth(ignorePadding), self:getInnerHeight(ignorePadding)
end


--- Gets the inner width
--  @param {Boolean} ignorePadding
--  @returns {Number}
--  @public
function Box:getInnerWidth(ignorePadding)
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
function Box:getInnerHeight(ignorePadding)
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
function Box:getPadding()
  local top = self:_evaluateNumber(self.padding.top, "y", true)
  local right = self:_evaluateNumber(self.padding.right, "x", true)
  local bottom = self:_evaluateNumber(self.padding.bottom, "y", true)
  local left = self:_evaluateNumber(self.padding.left, "x", true)

  return top, right, bottom, left
end

--- Centers this object
--  @param {Number} x
--  @param {Number} y
--  @param {Boolean} centerX
--  @param {Boolean} centerY
--  @public
--
--  Possible signatures:
--    Box:setCenter([Boolean centerX, Boolean centerY])
--      Moves to the center of the parent. `centerX` and `centerY` specify
--      if object should be centered on the x or y axis
--    Box:setCenter(Number x, Number y[, Boolean centerX, Boolean centerY])
--      Same as above with fixed center point (x,y)
--    Box:setCenter(Object[, Boolean centerX, centerY])
--      Same as above with fixed center object
function Box:setCenter(x, y, centerX, centerY)
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
--  Box:setPosition(x, y)
--    @param {Number|String} x
--    @param {Number|String} y
--  Box:setPosition(positions)
--    @param {Table} positions
--  @public
function Box:setPosition(x, y)
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

--- Sets the X position
--  @param {Number} x
--  @public
function Box:setX(x)
  self.position.left = x

  -- Unset center object when moving
  self.center = nil
end

--- Sets the Y position
--  @param {Number} y
--  @public
function Box:setY(y)
  self.position.top = y

  -- Unset center object when moving
  self.center = nil
end

--- Sets the size
--  @param {Number|Percent} width
--  @param {Number|Percent} height
--  @public
function Box:setSize(width, height)
  self.size.width = width
  self.size.height = height
end

--- Sets the inner size (the given size + paddings)
--  @param {Number} width
--  @param {Number} height
--  @public
function Box:setInnerSize(width, height)
  assert(
    (type(width) == "number" and type(height) == "number"),
    "Right now, arguments passed to Box:setInnerSize have to be numbers."
  )

  local top, right, bottom, left = self:getPadding()
  self:setSize(width + left + right, height + top + bottom)
end

--- Sets the offset for this box
--  @param {Number} x
--  @param {Number} y
--  @public
function Box:setOffset(x, y)
  self.offset.x = x
  self.offset.y = y
end

--- Sets the padding
--  @param {Number|String} top
--  @param {Number|String} right
--  @param {Number|String} bottom (optional)
--  @param {Number|String} left (optional)
--  @public
function Box:setPadding(top, right, bottom, left)
  if top ~= nil and right ~= nil and bottom ~= nil and left ~= nil then
    self.padding.top = top
    self.padding.right = right
    self.padding.bottom = bottom
    self.padding.left = left
  elseif top ~= nil and right ~= nil then
    local vertical, horizontal = top, right
    self.padding.top = vertical
    self.padding.right = horizontal
    self.padding.bottom = vertical
    self.padding.left = horizontal
  elseif top ~= nil then
    local padding = top
    self.padding.top = padding
    self.padding.right = padding
    self.padding.bottom = padding
    self.padding.left = padding
  end
end

--- Sets the position mode
--  @param {String} positionMode (absolute|relative)
--  @public
function Box:setPositionMode(positionMode)
  assert(
    Util.contains({ "absolute", "relative" }, positionMode),
    "Box:setPositionMode: Invalid mode: " .. positionMode ..
    " (available options: relative, absolute)"
  )

  self.positionMode = positionMode
end

--- Sets the parent
--  @param {Object} object
--  @public
function Box:setParent(object)
  self.parent = object
end

--- Calls fn for each child
--  @param {Function} fn
--  @param {Boolean} recursive
--  @public
function Box:eachChild(fn, recursive)
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
function Box:eachInternal(fn, recursive)
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
function Box:addChild(object)
  assert(object, "Box:addChild: No object given.")
  self.children[#self.children + 1] = object
  object:setParent(self)
end

--- Adds an internal to this object
--  @param {Object} object
--  @public
function Box:addInternal(object)
  assert(object, "Box:addInternal: No object given.")
  self.internals[#self.internals + 1] = object
  object:setParent(self)
end

--- Sets the width
--  @param {Number} width
--  @public
function Box:setWidth(width)
  self.size.width = width
end

--- Sets the height
--  @param {Number} height
--  @public
function Box:setHeight(height)
  self.size.height = height
end

--- Displays the object
--  @public
function Box:show()
  self.isVisible = true
end

--- Hides the object
--  @public
function Box:hide()
  self.isVisible = false
end

return Box
