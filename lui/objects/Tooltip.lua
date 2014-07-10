local pathMatch = "(.+)%.objects.Tooltip$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Tooltip = class("Tooltip", Object)

--- `Tooltip` constructor
--  @param {lui} lui
--  @param {String} text
function Tooltip:initialize(lui, text)
  Object.initialize(self, lui)

  self:setPadding(5, 10)
  self.textObject = self.lui:createText(self.text)
  self.textObject:setAlignment("center", "center")
  self:addChild(self.textObject)

  self:setText(text)

  -- Automatically add to root
  self.lui.root:addChild(self)
end

--- Draws the Tooltip
function Tooltip:draw()
  if self.isVisible then
    self.lui.skin:drawTooltip(self)
  end

  Object.draw(self)
end

--- Sets the text
--  @param {String} text
--  @public
function Tooltip:setText(text)
  self.text = text
  self.textObject:setText(text)

  local width, height = self.textObject:getSize()
  self:setInnerSize(width, height)
end

return Tooltip
