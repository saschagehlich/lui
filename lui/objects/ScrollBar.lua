local pathMatch = "(.+)%.objects.ScrollBar$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local ScrollBar = class("ScrollBar", Object)

--- `ScrollBar` constructor
--  @param {lui} lui
function ScrollBar:initialize(lui, type)
  Object.initialize(self, lui)

  self.type = type

  self.size = {
    width = self.theme.scrollbarSize,
    height = self.theme.scrollbarSize
  }

  self.contentSize = 0
  self.visibleSize = 0
  self.scrollProgress = 0

  local buttonWidth = self.theme.scrollbarSize
  local buttonHeight = self.theme.scrollbarSize

  if self.type == "vertical" then
    buttonWidth = "100%"
  else
    buttonHeight = "100%"
  end

  -- The lower boundary button (scroll up or scroll left)
  self.lowerButton = self.lui:createButton()
  self.lowerButton:setSize(buttonWidth, buttonHeight)
  self.lowerButton:setPosition({ top = 0, left = 0 })
  self:addInternal(self.lowerButton)

  -- The upper boundary button (scroll down or scroll right)
  self.upperButton = self.lui:createButton()
  self.upperButton:setSize(buttonWidth, buttonHeight)
  self.upperButton:setPosition({ bottom = 0, right = 0 })
  self:addInternal(self.upperButton)

  -- The area where the scroll button will be in
  local scrollAreaWidth = self:getWidth()
  local scrollAreaHeight = self:getHeight()
  self.scrollArea = self.lui:createGroup()
  if self.type == "vertical" then
    self.scrollArea:setSize(scrollAreaWidth, "100% - " .. buttonHeight * 2)
    self.scrollArea:setPosition(0, buttonHeight)
  else
    self.scrollArea:setPosition(buttonWidth, 0)
    self.scrollArea:setSize("100% - " .. buttonWidth * 2, scrollAreaHeight)
  end
  self:addInternal(self.scrollArea)

  -- The button that will be dragged to scroll
  self.scrollerButton = self.lui:createButton()
  self.scrollerButton:setSize(buttonWidth, buttonHeight)
  self.scrollerButton:setLockedToParent(true)
  self.scrollerButton:setDraggingArea({
    x = 0,
    y = 0,
    width = "100%",
    height = "100%"
  })
  self.scrollerButton:setDraggable(true)
  self.scrollArea:addChild(self.scrollerButton)

  self.scrollerButton:on("drag", self._onScrollerDrag, self)
end

function ScrollBar:update(dt)
  -- Let the scrollerButton size represent the visible / content ratio
  local ratio = self.visibleSize / self.contentSize

  if self.type == "vertical" then
    local scrollAreaHeight = self.scrollArea:getHeight()
    self.scrollerButton:setHeight(scrollAreaHeight * ratio)
  else
    local scrollAreaWidth = self.scrollArea:getWidth()
    self.scrollerButton:setWidth(scrollAreaWidth * ratio)
  end

  Object.update(self)
end

--- Draws the scroll bar
function ScrollBar:draw()
  self.theme:drawScrollBar(self)

  Object.draw(self)
end

--- Gets called when the scroller button has been dragged. Updates
--  the scrollProgress respectively.
--  @param {Object} object
--  @param {Number} x
--  @param {Number} y
--  @private
function ScrollBar:_onScrollerDrag(object, x, y)
  local freeAreaSize, objectPosition
  if self.type == "vertical" then
    freeAreaSize = self.scrollArea:getHeight() - self.scrollerButton:getHeight()
    objectPosition = self.scrollerButton:getY(true)
  else
    freeAreaSize = self.scrollArea:getWidth() - self.scrollerButton:getWidth()
    objectPosition = self.scrollerButton:getX(true)
  end

  self.scrollProgress = objectPosition / freeAreaSize
  self:emit("scroll", self, self.scrollProgress)
end

--- Sets the visible size
--  @param {Number} visibleSize
--  @public
function ScrollBar:setVisibleSize(visibleSize)
  self.visibleSize = visibleSize
end

--- Sets the content size
--  @param {Number} contentSize
--  @public
function ScrollBar:setContentSize(contentSize)
  if self.contentSize <= self.visibleSize and
    contentSize > self.visibleSize then
      -- No scrollbar necessary before, now we need it
      self:emit("enabled")
  elseif self.contentSize > self.visibleSize and
    contentSize <= self.visibleSize then
      -- Needed the scrollbar before, not anymore
      self:emit("disabled")
  end

  self.contentSize = contentSize
end

return ScrollBar
