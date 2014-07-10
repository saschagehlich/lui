local Tooltippable = {}

function Tooltippable:_init()
  self.tooltipDelay = 1
  self.currentTooltipDelay = nil
  self.tooltipFollowsMouse = true
  self.tooltipDistance = { x = 15, y = 15 }

  self:on("hover", self._tooltipOnHover, self)
  self:on("blur", self._tooltipOnBlur, self)
end

--- Gets called when the object is hovered
--  @private
function Tooltippable:_tooltipOnHover()
  if self.tooltip then
    self.currentTooltipDelay = self.tooltipDelay
  end
end

--- Gets called when the object is no longer hovered
--  @private
function Tooltippable:_tooltipOnBlur()
  if self.tooltip then
    self.tooltip:hide()
    self.currentTooltipDelay = nil
  end
end

--- Updates the tooltip delay, follows the cursor if needed
--  @param {Number} dt
--  @private
function Tooltippable:_updateTooltippable(dt)
  -- Tooltip delay
  if self.currentTooltipDelay ~= nil then
    self.currentTooltipDelay = self.currentTooltipDelay - dt
    if self.currentTooltipDelay <= 0 then

      print(self.currentTooltipDelay)
      self.tooltip:show()
      self.tooltip:moveToTop()

      local mouseX, mouseY = love.mouse.getPosition()
      local distX, distY = self.tooltipDistance.x, self.tooltipDistance.y
      self.tooltip:setPosition(mouseX + distX, mouseY + distY)

      self.currentTooltipDelay = nil
    end
  end

  -- Tooltip follow
  if self.tooltip and
    self.tooltip.isVisible and
    self.tooltipFollowsMouse then
      local mouseX, mouseY = love.mouse.getPosition()
      local distX, distY = self.tooltipDistance.x, self.tooltipDistance.y
      self.tooltip:setPosition(mouseX + distX, mouseY + distY)
  end
end

--- Sets the given object as the tooltip
--  @param {Object} object
--  @public
function Tooltippable:setTooltip(object)
  self.tooltip = object
  self.tooltip:hide()
end

--- Specifies the delay after which the tooltip should be displayed
--  @param {Number} delay
--  @public
function Tooltippable:setTooltipDelay(delay)
  self.tooltipDelay = delay
end

--- Specifies whether or not the tooltip should follow the mouse position
--  @param {Boolean} bool
--  @public
function Tooltippable:setTooltipFollowsMouse(bool)
  self.tooltipFollowsMouse = bool
end

--- Specifies the distance between the cursor and the tooltip
--  @param {Number} x
--  @param {Number} y
--  @public
function Tooltippable:setTooltipDistance(x, y)
  self.tooltipDistance = { x = x, y = y }
end

return Tooltippable
