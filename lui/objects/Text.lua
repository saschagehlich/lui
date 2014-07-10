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

  self.size = { width = nil, height = nil }
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

  local textWidth, textHeight = self:getTextSize()

  if self.alignment.y == "center" then
    y = y + height / 2 - textHeight / 2
  elseif self.alignment.y == "bottom" then
    y = y + (height - textHeight)
  end

  love.graphics.setColor(0, 0, 0)
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

--- If size.width is set to nil, this will return the text width
--  @returns {Number}
--  @public
function Text:getWidth()
  if self.size.width ~= nil then
    return Object.getWidth(self)
  else
    local width, height = self:getTextSize()
    return width
  end
end

--- If size.height is set to nil, this will return the text height
--  @returns {Number}
--  @public
function Text:getHeight()
  if self.size.height ~= nil then
    return Object.getHeight(self)
  else
    local width, height = self:getTextSize()
    return height
  end
end

function Text:getTextSize()
  local width
  if self.size.width then
    width = self:getWidth()
  else
    width = self.maxWidth
  end

  local font = self.theme.buttonFont
  local lineHeight = font:getLineHeight() * font:getHeight()

  love.graphics.setFont(font)

  local textWidth
  if width then
    textWidth, lines = font:getWrap(self.text, width)
    totalTextHeight = lines * lineHeight
  else
    textWidth = font:getWidth(self.text)
    totalTextHeight = lineHeight
  end

  return textWidth, totalTextHeight
end

return Text
