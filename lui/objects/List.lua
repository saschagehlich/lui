local pathMatch = "(.+)%.objects.List$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Util = require((...):match(pathMatch) .. ".lib.Util")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local List = class("List", Object)

--- `List` constructor
--  @param {lui} lui
function List:initialize(lui)
  Object.initialize(self, lui)

  self.type = "vertical"
  self.items = {}
  self.spacing = { x = 10, y = 10 }

  self.verticalScrollBar = lui:createScrollBar("vertical")
  self.verticalScrollBar:setPositionMode("absolute")
  self.verticalScrollBar:setPosition({ right = 0, top = 0 })
  self.verticalScrollBar:setHeight("100%")
  self.verticalScrollBar:setVisibleSize(self:getHeight())

  self:addChild(self.verticalScrollBar)
end

--- Draws the list
function List:draw()
  self.theme:drawList(self)

  local x, y = self:getPosition()
  local width, height = self:getSize()

  -- Draw children
  -- love.graphics.setStencil(function ()
  --   love.graphics.rectangle("fill", x, y, width, height)
  -- end)
  Object.draw(self)
  -- love.graphics.setStencil() -- unset stencil
end

--- Override padding in case a scrollbar is visible
--  @returns {Number, Number, Number, Number}
--  @public
function List:getPadding()
  local top, right, bottom, left = Object.getPadding(self)

  if self.verticalScrollBar.isVisible then
    right = right + self.verticalScrollBar:getWidth()
  end

  return top, right, bottom, left
end

--- Adds an item to this list
--  @param {ListItem} item
--  @public
function List:addItem(item)
  self.items[#self.items + 1] = item
  item:setIndex(#self.items)
  self:addChild(item)

  self.verticalScrollBar:setContentSize(self:getContentHeight())
end

--- Returns the total height of the list
function List:getContentHeight()
  -- Get the last object
  local item = self.items[#self.items]
  if not item then return 0 end -- No items == no height

  local y, height = item:getY(), item:getHeight()
  return y + height
end

--- Sets the list type
--  @param {ListType} listType
--  @public
function List:setType(listType)
  assert(
    Util.contains({ "horizontal", "vertical" }),
    "Invalid list type " .. listType .. ". Available options: horizontal, vertical"
  )
  self.type = listType
end

--- Sets the spacing
--  @param {Number} x
--  @param {Number} [y]
--  @public
function List:setSpacing(x, y)
  if y == nil then
    self.spacing = { x = x, y = x }
  else
    self.spacing = { x = x, y = y }
  end
end

--- Calls fn for each item before index
--  @param {Number} index
--  @param {Function} fn
--  @public
function List:eachItemBefore(index, fn)
  for i = 1, index - 1, 1 do
    fn(self.items[i])
  end
end

return List