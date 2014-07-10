local pathMatch = "(.+)%.objects.mixins.Draggable$"
local pathBase = (...):match(pathMatch)

local Util = require(pathBase .. ".lib.Util")

local Draggable = {}

function Draggable:_init()
  self.isDraggable = false
  self.isDragging = false
  self.lockedToParent = false
end

function Draggable:_updateDraggable(dt)
  if self.isDraggable then
    self:_handleDragging()
    if self.isDragging then
      self:_updateDragging()
    end
  end
end

--- Handles object dragging
--  @private
function Draggable:_handleDragging()
  -- Handle dragging state
  local mouseDown = love.mouse.isDown("l")
  local mouseOnDraggingArea = self:_isMouseOnDraggingArea()
  if mouseDown and
    not self.lui.isDragging and
    not self.isDragging and
    mouseOnDraggingArea then
      -- Not dragging but mouse is down, start dragging
      local x, y = love.mouse.getPosition()

      self.startDragPosition = {
        x = x,
        y = y
      }

      local startX, startY = self:getPosition(true)
      self.startPosition = {
        x = startX,
        y = startY
      }

      self.isDragging = true
      self:emit("dragstart", self)
  elseif not mouseDown and self.isDragging then
    -- Mouse is not down but dragging still active, stop dragging
    self.isDragging = false
    self:emit("dragend", self)
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
function Draggable:_updateDragging()
  local x, y = love.mouse:getPosition()
  local startDragX, startDragY =
    self.startDragPosition.x,
    self.startDragPosition.y
  local startX, startY =
    self.startPosition.x,
    self.startPosition.y

  -- Calculate distance
  local distX, distY = x - startDragX, y - startDragY

  if distX == 0 and distY == 0 then
    return
  end

  -- Add distance to current position
  local posX, posY = startX + distX, startY + distY
  local width, height = self:getSize()

  -- If this object is locked to another object, make sure we can't drag
  -- it outside
  if self.lockedToParent then
    local parentWidth, parentHeight = self.parent:getSize()

    local clampedX = math.max(0, posX) -- left boundary
    clampedX = math.min(clampedX, parentWidth - width) -- right boundary
    local clampedY = math.max(0, posY) -- top boundary
    clampedY = math.min(clampedY, parentHeight - height) -- bottom boundary

    distX = clampedX - startX
    distY = clampedY - startY

    posX = clampedX
    posY = clampedY
  end

  self:setPosition(posX, posY)

  self:emit("drag", self, distX, distY)
end

--- Is the mouse on the title bar?
--  @returns {Boolean}
--  @private
function Draggable:_isMouseOnDraggingArea()
  -- Quit early if not hovering
  if not self.isHovered then
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

--- Specifies whether the object should be locked to its parent (so
--  that it can't be dragged outside of it)
--  @param {Boolean} bool
--  @public
function Draggable:setLockedToParent(bool)
  self.lockedToParent = bool
end

--- Sets the objects dragging area
--  @param {Table} draggingArea
--  @public
function Draggable:setDraggingArea(draggingArea)
  self.draggingArea = draggingArea
end

--- Sets the object to be draggable
--  @param {Boolean} draggable
--  @public
function Draggable:setDraggable(draggable)
  assert(self.draggingArea, "Object set as draggable, but not draggingArea set.")
  self.isDraggable = draggable
end

return Draggable
