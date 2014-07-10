local pathMatch = "(.+)%.objects.mixins.Draggable$"
local pathBase = (...):match(pathMatch)

local Util = require(pathBase .. ".lib.Util")

local Draggable = {}

function Draggable:_init()
  self.isDraggable = false
  self.isDragging = false
  self.lockedToObject = nil
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
  if mouseDown and not self.isDragging and mouseOnDraggingArea then
    -- Not dragging but mouse is down, start dragging
    local x, y = love.mouse.getPosition()

    self.startDragPosition = {
      x = x,
      y = y
    }

    local startX, startY = self:getPosition()
    self.startPosition = {
      x = startX,
      y = startY
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

  -- Add distance to current position
  local posX, posY = startX + distX, startY + distY
  local width, height = self:getSize()

  -- If this object is locked to another object, make sure we can't drag
  -- it outside
  if self.lockedToObject then
    local lockedX, lockedY = self.lockedToObject:getPosition()
    local lockedWidth, lockedHeight = self.lockedToObject:getSize()

    posX = math.max(lockedX, posX) -- left boundary
    posX = math.min(posX, lockedX + lockedWidth - width) -- right boundary
    posY = math.max(lockedY, posY) -- top boundary
    posY = math.min(posY, lockedY + lockedHeight - height) -- bottom boundary
  end

  self:setPosition(posX, posY)
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

--- Sets the object that this object is locked to. If this object is
--  draggable, the user won't be able to drag it outside the given object.
--  @param {Object} object
function Draggable:setLockedTo(object)
  self.lockedToObject = object
end

return Draggable
