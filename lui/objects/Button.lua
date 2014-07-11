local pathMatch = "(.+)%.objects.Button$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Button = class("Button", Object)

--- `Button` constructor
--  @param {lui} lui
--  @param {String} text
function Button:initialize(lui, text)
  Object.initialize(self, lui)

  self.isClickable = true

  self.text = text or ""
  self.size = { width = 100, height = 30 }
  self.showPointer = true

  self.isToggleable = false
  self.isToggled = false

  self.repeatClick = false
  self.repeatDelay = 1
  self.repeatInterval = 0.1
  self.repeatCooldown = nil

  self.textObject = self.lui:createText(self.text)
  self.textObject:setSize(lui.percent(100), lui.percent(100))
  self.textObject:setAlignment("center", "center")
  self:addChild(self.textObject)

  self:on("hover", self.onHover, self)
  self:on("blur", self.onBlur, self)
  self:on("click", self.onClick, self)
  self:on("mousepressed", self.onMousePressed, self)
end

--- Gets called when the mouse is hovering above the button
--  @public
function Button:onHover()
  if self.lui.isDragging then return end
  if self.showPointer then
    self.lui:setCursor("hand", self)
  end
end

--- Gets called when the mouse is no longer hovering above the button
--  @public
function Button:onBlur()
  if self.lui.isDragging then return end
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

--- Gets called when the user is pressing the mouse button on this object
--  @public
function Button:onMousePressed()
  self.pressedAt = os.clock()
  self.repeatCooldown = self.repeatInterval
end

--- Handles repeating
function Button:update(dt)

  if self.repeatClick and
    self.isPressed and
    os.clock() - self.pressedAt >= self.repeatDelay then
      self.repeatCooldown = self.repeatCooldown - dt

      if self.repeatCooldown <= 0 then
        self.repeatCooldown = self.repeatInterval - self.repeatCooldown

        self:emit("repeat")
      end
  end

  Object.update(self, dt)
end

--- Draws the Button
function Button:draw()
  if self.isVisible then
    self.theme:drawButton(self)
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

--- Sets the toggle state
--  @param {Boolean} bool
--  @public
function Button:setToggle(bool)
  self.isToggled = bool
end

--- Sets the text
--  @param {String} text
--  @public
function Button:setText(text)
  self.text = text
  self.textObject:setText(text)
end

--- Specifies whether the button should automatically repeat clicking
--  if the user is holding it down.
--  @param {Number} delay
--  @param {Number} interval
--  @public
function Button:setRepeat(delay, interval)
  if delay == false or delay == nil then
    self.repeatClick = false
    return
  end

  self.repeatClick = true
  self.repeatDelay = delay
  self.repeatInterval = interval
end

return Button
