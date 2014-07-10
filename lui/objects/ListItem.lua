local pathMatch = "(.+)%.objects.ListItem$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local ListItem = class("ListItem", Object)

--- `ListItem` constructor
--  @param {lui} lui
function ListItem:initialize(lui)
  Object.initialize(self, lui)

  self.index = nil
  self.size = { width = 100, height = 25 }
end

--- Overrides the width depending on the list type
--  @returns {Number}
--  @public
function ListItem:getWidth()
  if self.parent.type == "vertical" then
    self.size.width = "100%"
  end
  return Object.getWidth(self)
end

--- Overrides the height depending on the list type
--  @returns {Number}
--  @public
function ListItem:getHeight()
  return Object.getHeight(self)
end

--- Overrides the y position depending on the index
--  @returns {Number}
--  @public
function ListItem:getY()
  local defaultY = Object.getY(self)

  local list = self.parent
  if list.type == "vertical" then
    local y = 0
    list:eachItemBefore(self.index, function (item)
      y = y + item:getHeight() + list.spacing.y
    end)
    y = y + defaultY
    return y
  end

  return defaultY
end

--- Only for debugging. I guess.
function ListItem:draw()
  local x, y = self:getPosition()
  local width, height = self:getSize()

  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", x, y, width, height)

  Object.draw(self)
end

--- Sets the index
--  @param {Number} index
--  @public
function ListItem:setIndex(index)
  self.index = index
end

return ListItem
