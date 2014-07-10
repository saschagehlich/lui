local Clickable = {}

function Clickable:_init()
  self.isPressed = false
end

function Clickable:_updateClickable(dt)
  self:_handleClick()
end

--- Handles object clicking
--  @private
function Clickable:_handleClick()
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

return Clickable
