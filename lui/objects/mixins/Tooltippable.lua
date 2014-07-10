local Tooltippable = {}

function Tooltippable:_init()
  self.tooltipDelay = 1
  self.currentTooltipDelay = nil
  self.tooltipFollowsMouse = true
  self.tooltipDistance = { x = 15, y = 15 }

  self:on("hover", self._tooltipOnHover, self)
  self:on("blur", self._tooltipOnBlur, self)
end

function Tooltippable:_tooltipOnHover()
  if self.tooltip then
    self.currentTooltipDelay = self.tooltipDelay
  end
end

function Tooltippable:_tooltipOnBlur()
  if self.tooltip then
    self.tooltip:hide()
    self.currentTooltipDelay = nil
  end
end

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

return Tooltippable
