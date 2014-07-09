local pathMatch = "(.+)%.objects.Button$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Button = class("Button", Object)

--- `Button` constructor
--  @param {lui} lui
--  @param {String} text
function Button:initialize(lui, text)
  Object.initialize(self, lui)

  self.text = text or ""
  self.size = { width = 100, height = 30 }
  self.showPointer = true

  self.isToggleable = false
  self.isToggled = false

  self.textObject = self.lui:createText(self.text)
  self.textObject:setSize("100%", "100%")
  self.textObject:setAlignment("center", "center")
  self:addChild(self.textObject)

  self:on("hover", self.onHover, self)
  self:on("blur", self.onBlur, self)
  self:on("click", self.onClick, self)
end

--- Gets called when the mouse is hovering above the button
--  @public
function Button:onHover()
  if self.showPointer then
    self.lui:setCursor("hand", self)
  end
end

--- Gets called when the mouse is no longer hovering above the button
--  @public
function Button:onBlur()
  if self.showPointer then
    self.lui:resetCursor()
  end
end

--- Gets called when the user clicked on the button
--  @public
function Button:onClick()
  if self.isToggleable then
    self.isToggled = not self.isToggled
    self:emit("toggle", self.isToggled)
  end
end

--- Draws the Button
function Button:draw()
  if self.isVisible then
    self.lui.skin:drawButton(self)
  end

  Object.draw(self)
end

--- Specifies whether the hand cursor should be shown on hovering
--  @param {Boolean} bool
--  @public
function Button:setShowPointer(bool)
  self.showPointer = bool
end

--- Specifies whether the button should be toggleable
--  @param {Boolean} bool
--  @public
function Button:setToggleable(bool)
  self.isToggleable = bool
end

--- Sets the text
--  @param {String} text
--  @public
function Button:setText(text)
  self.text = text
  self.textObject:setText(text)
end

return Button
