local pathMatch = "(.+)%.objects.Text$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Util = require((...):match(pathMatch) .. ".lib.Util")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Text = class("Text", Object)

--- `Text` constructor
--  @param {lui} lui
--  @param {String} text
function Text:initialize(lui, text)
  Object.initialize(self, lui)

  self.text = text
  self.alignment = {
    x = "left",
    y = "top"
  }
end

--- Draws the Text
function Text:draw()
  local x, y = self:getPosition()
  local width, height = self:getSize()
  local font = self.lui.skin.buttonFont

  local lineHeight = font:getLineHeight() * font:getHeight()

  local textWidth, lines = font:getWrap(self.text, width)
  local totalTextHeight = lines * lineHeight

  love.graphics.setFont(font)

  if self.alignment.y == "center" then
    y = y + height / 2 - totalTextHeight / 2
  elseif self.alignment.y == "bottom" then
    y = y + (height - totalTextHeight)
  end

  love.graphics.printf(self.text, x, y, width, self.alignment.x)

  Object.draw(self)
end

--- Sets the text alignment
--  @param {String} x
--  @param {String} y
function Text:setAlignment(x, y)
  assert(
    Util.contains({ "left", "center", "right" }, x),
    "Invalid horizontal alignment: " .. x .. ". Possible values: left, center, right."
  )
  assert(
    Util.contains({ "top", "center", "bottom" }, y),
    "Invalid vertical alignment: " .. y .. ". Possible values: top, center, bottom."
  )

  self.alignment.x = x
  self.alignment.y = y
end

--- Sets the text
--  @param {String} text
--  @public
function Text:setText(text)
  self.text = text
end

return Text
