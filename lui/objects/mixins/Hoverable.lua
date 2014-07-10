local Hoverable = {}

function Hoverable:_init()
  self.isHovered = false
end

--- Updates the hovering
function Hoverable:_updateHoverable(dt)
  self:_handleHover()
end

--- Handles hover states
--  @private
function Hoverable:_handleHover()
  -- Don't change hovered state when dragging
  if self.isDragging then return end

  local x, y = self:getPosition()
  local width, height = self:getSize()

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

return Hoverable
