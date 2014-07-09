local pathMatch = "(.+)%.objects.Button$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Button = class("Button", Object)

--- `Button` constructor
--  @param {lui} lui
--  @param {String} text
function Button:initialize(lui, text)
  Object.initialize(self, lui)

  self.text = text
  self.size = { width = 100, height = 50 }
  self.showPointer = true

  self.textObject = self.lui:createText(self.text)
  self.textObject:setSize("100%", "100%")
  self.textObject:setAlignment("center", "center")
  self:addChild(self.textObject)

  self:on("hover", function()
    if self.showPointer then
      local pointer = love.mouse.getSystemCursor("hand")
      love.mouse.setCursor(pointer)
    end
  end)

  self:on("blur", function()
    if self.showPointer then
      love.mouse.setCursor()
    end
  end)
end

--- Draws the Button
function Button:draw()
  self.lui.skin:drawButton(self)

  Object.draw(self)
end

--- Specifies whether the hand cursor should be shown on hovering
--  @param {Boolean} bool
--  @public
function Button:setShowPointer(bool)
  self.showPointer = bool
end

--- Sets the text
--  @param {String} text
--  @public
function Button:setText(text)
  self.text = text
  self.textObject:setText(text)
end

return Button
