local pathMatch = "(.+)%.objects.Tabs$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Tabs = class("Tabs", Object)

--- `Tabs` constructor
--  @param {lui} lui
function Tabs:initialize(lui)
  Object.initialize(self, lui)

  self.tabs = {}
  self.spacing = 5

  -- Create tabs group
  self.tabsGroup = self.lui:createGroup()
  self:addChild(self.tabsGroup)

  -- Create content group
  self.contentGroup = self.lui:createGroup()
  self.contentGroup:setSize(lui.percent(100), lui.percent(100))
  self:addChild(self.contentGroup)

  self.tabSize = { width = 0, height = 0 }
  self:setTabSize(50, 15)
end

--- Sets the tab size, updates the content offset
--  @param {Number} width
--  @param {Number} height
--  @public
function Tabs:setTabSize(width, height)
  self.tabSize.width = width
  self.tabSize.height = height

  self.tabsGroup:setSize(self.lui.percent(100), height)
  self.contentGroup:setMargin(0, self.tabSize.height)

  self:eachTab(function (tab)
    tab:setSize(self.tabSize.width, self.tabSize.height)
  end)
end

--- Adds the given tab to the tabs
--  @param {Tab} tab
--  @public
function Tabs:addTab(tab)
  self.tabs[#self.tabs + 1] = tab
  tab:setTabs(self)
  tab:setIndex(#self.tabs)
  tab:setSize(self.tabSize.width, self.tabSize.height)
  self.tabsGroup:addChild(tab)

  tab:on("click", self._onTabClick, self)

  -- Enable first tab
  if #self.tabs == 1 then
    self:_onTabClick(tab)
  end
end

--- Gets called when a tab has been clicked. Untoggles
--  all tabs, sets the givenone to toggled
--  @param {Tab} tab
--  @private
function Tabs:_onTabClick(tab)
  self:eachTab(function(tab)
    tab:setToggle(false)
  end)
  tab:setToggle(true)
end

--- Calls fn for every existing tab
--  @param {Function} tab
--  @public
function Tabs:eachTab(fn)
  for i, tab in ipairs(self.tabs) do
    fn(tab)
  end
end

--- Calls fn for each tab before index
--  @param {Number} index
--  @param {Function} fn
--  @public
function Tabs:eachTabBefore(index, fn)
  for i = 1, index - 1, 1 do
    fn(self.tabs[i])
  end
end

--- Sets the spacing
--  @param {Number} spacing
--  @public
function Tabs:setSpacing(spacing)
  self.spacing = spaciong
end

return Tabs
