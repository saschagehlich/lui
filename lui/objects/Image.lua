local pathMatch = "(.+)%.objects.Image$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Image = class("Image", Object)

--- `Image` constructor
--  @param {lui} lui
--  @param {String} imageFileName
function Image:initialize(lui, imageFileName)
  Object.initialize(self, lui)

  self:setImage(imageFileName)
end

--- Draws the Image
function Image:draw()
  local x, y = self:getPosition()
  love.graphics.draw(self.image, x, y)

  Object.draw(self)
end

--- Sets the image
--  @param {Image|String} image
--  @public
function Image:setImage(image)
  if type(image) == "string" then
    self.image = love.graphics.newImage(image)
  else
    self.image = image
  end

  self:setSize(self.image:getWidth(), self.image:getHeight())
end

return Image
