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
  self.verticalScrollBar:setHeight(lui.percent(100))
  self.verticalScrollBar:on("scroll", self._onVerticalScroll, self)
  self:addChild(self.verticalScrollBar)

  self.itemsGroup = self.lui:createGroup()
  self.itemsGroup:setSize(lui.percent(100), lui.percent(100))
  self:addChild(self.itemsGroup)

  self.lui:on("mousepressed", self._onMousePressed, self)
end

function List:update(dt)
  self.verticalScrollBar:setVisibleSize(self:getHeight())

  Object.update(self, dt)
end

--- Draws the list
function List:draw()
  self.theme:drawList(self)

  local x, y = self:getPosition()
  local width, height = self:getSize()

  -- Draw children
  love.graphics.setStencil(function ()
    love.graphics.rectangle("fill", x, y, width, height)
  end)
  Object.draw(self)
  love.graphics.setStencil() -- unset stencil
end

--- Gets called when a mouse button has been pressed. We
--  are using this for scrolling behavior
function List:_onMousePressed(x, y, button)
  if self.isHovered then
    if button == "wu" then
      self:_scrollUp()
    elseif button == "wd" then
      self:_scrollDown()
    end
  end
end

--- Gets called when the scrollbar is scrolling
--  @param {ScrollBar} object
--  @param {Number} progress
--  @private
function List:_onVerticalScroll(object, progress)
  local contentHeight = self.verticalScrollBar.contentSize
  local visibleHeight = self.verticalScrollBar.visibleSize
  local invisibleHeight = contentHeight - visibleHeight

  self.itemsGroup:setMargin(-invisibleHeight * progress, 0, 0, 0)
end

--- Gets called when the user scrolls up inside the list
--  @private
function List:_scrollUp()
  self.verticalScrollBar:scrollUp()
end

--- Gets called when the user scrolls down inside the list
--  @private
function List:_scrollDown()
  self.verticalScrollBar:scrollDown()
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
  item:setList(self)
  self.itemsGroup:addChild(item)

  self.verticalScrollBar:setContentSize(self:getContentHeight())
end

--- Returns the total height of the list
function List:getContentHeight()
  -- Get the last object
  local item = self.items[#self.items]
  if not item then return 0 end -- No items == no height

  local y, height = item:getY(true), item:getHeight()
  local top, right, bottom, left = self:getPadding()

  return y + height + top + bottom
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
