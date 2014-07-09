local pathMatch = "(.+)%.objects.Tooltip$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Tooltip = class("Tooltip", Object)

--- `Tooltip` constructor
--  @param {lui} lui
--  @param {String} text
function Tooltip:initialize(lui, text)
  Object.initialize(self, lui)

  self.sizeDynamic = true
  self.text = text or ""

  self.textObject = self.lui:createText(self.text)
  self.textObject:setAlignment("center", "center")
  self:addChild(self.textObject)

  self:setMaxWidth(150)
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
  self:setSize(width, height)
end

function Tooltip:setMaxWidth()

return Tooltip
