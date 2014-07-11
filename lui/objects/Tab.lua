local pathMatch = "(.+)%.objects.Tab$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Button = require((...):match(pathMatch) .. ".objects.Button")

local Tab = class("Tab", Button)

--- `Tab` constructor
--  @param {lui} lui
function Tab:initialize(lui)
  Button.initialize(self, lui)

  self.index = nil
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
  tabs:eachTabBefore(self.index, function (tab)
    x = x + tab:getWidth() + tabs.spacing
  end)

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
