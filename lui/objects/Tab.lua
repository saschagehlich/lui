local pathMatch = "(.+)%.objects.Tab$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Button = require((...):match(pathMatch) .. ".objects.Button")

local Tab = class("Tab", Button)

-- When the user calls Tabs:addTab(), we don't want to
-- add it to the tab's children
Tab.static.addToCreator = false

--- `Tab` constructor
--  @param {lui} lui
function Tab:initialize(lui, text)
  Button.initialize(self, lui, text)

  self.index = 0
  self.tabs = nil

  self.isToggleable = true
  self.contentObject = nil
end

--- Draws the tab
function Tab:draw()
  self.theme:drawTab(self)

  Button.draw(self)
end

--- Overrides the x position depending on the index
--  @param {Boolean} relative
--  @returns {Number}
--  @public
function Tab:getX(relative)
  local defaultX = Button.getX(self, relative)

  local tabs = self.tabs
  local x = 0
  if tabs then
    tabs:eachTabBefore(self.index, function (tab)
      x = x + tab:getWidth() + tabs.spacing
    end)
  end

  return x + defaultX
end

--- Sets the given object as the content object
--  @param {Object} object
--  @public
function Tab:setContent(object)
  self.contentObject = object
end

--- Sets the index of this tab
--  @param {Number} index
--  @public
function Tab:setIndex(index)
  self.index = index
end

--- Sets the tabs object for this tab
--  @param {Tabs} tabs
--  @public
function Tab:setTabs(tabs)
  self.tabs = tabs
end

return Tab
