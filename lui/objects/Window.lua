local pathMatch = "(.+)%.objects.Window$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Window = class("Window", Object)

--- `Window` constructor
--  @param {lui} lui
--  @param {String} title
function Window:initialize(lui, title)
  Object.initialize(self, lui)

  self.title = title or "New Window"
  self.size = { width = 250, height = 200 }
  self.padding = self.lui.skin.windowPadding

  self.titleHitboxHeight = self.lui.skin.windowTitleBarHitboxHeight

  self.dragging = false

  -- Window objects are automatically added to root
  self.lui.root:addChild(self)
end

--- Handles mouse interaction
--  @param {Number} dt
--  @private
function Window:_handleMouse(dt)
  Object._handleMouse(self, dt)

  self:_handleDragging()
end

--- Handles window dragging
--  @private
function Window:_handleDragging()
  -- Handle dragging state
  local mouseDown = love.mouse.isDown("l")
  local mouseOnTitleBar = self:_isMouseOnTitleBar()
  if mouseDown and not self.dragging and mouseOnTitleBar then
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
function Window:_updateDragging()
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
function Window:_isMouseOnTitleBar()
  -- Quit early if not hovering
  if not self.hovered then
    return false
  end

  -- Check Y position
  local mouseY = love.mouse.getY()
  local _, y = self:_getRealPosition()
  return mouseY < y + self.titleHitboxHeight
end

--- Draws the window
function Window:draw()
  self.lui.skin:drawWindow(self)
end

return Window
