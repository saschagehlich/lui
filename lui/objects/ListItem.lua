local pathMatch = "(.+)%.objects.ListItem$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local ListItem = class("ListItem", Object)

--- `ListItem` constructor
--  @param {lui} lui
function ListItem:initialize(lui)
  Object.initialize(self, lui)

  self.index = nil
  self.list = nil
  self.size = { width = 100, height = 25 }
end

--- Overrides the width depending on the list type
--  @returns {Number}
--  @public
function ListItem:getWidth()
  if self.list.type == "vertical" then
    self.size.width = self.lui.percent(100)
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
--  @param {Boolean} relative
--  @returns {Number}
--  @public
function ListItem:getY(relative)
  local defaultY = Object.getY(self, relative)

  local list = self.list
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
  self.theme:drawListItem(self)

  local x, y = self:getPosition()
  local width, height = self:getSize()

  -- Don't draw items that are outside the viewport
  local relativeY = self:getY(relative)
  local listTop = self.list:getY(relative)
  local listBottom = listTop + self.list:getHeight()
  if relativeY > listBottom or relativeY + height < listTop then
    return
  end

  Object.draw(self)
end

--- Sets the index
--  @param {Number} index
--  @public
function ListItem:setIndex(index)
  self.index = index
end

--- Sets the list
--  @param {List} list
--  @public
function ListItem:setList(list)
  self.list = list
end

return ListItem
