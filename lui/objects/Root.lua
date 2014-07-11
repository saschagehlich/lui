local pathMatch = "(.+)%.objects.Root$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local Object = require((...):match(pathMatch) .. ".objects.Object")

local Root = class("Root", Object)

Root.static.addToCreator = false

--- `Root` constructor
--  @param {lui} lui
function Root:initialize(lui)
  Object.initialize(self, lui)

  self:_updateSize()
end

--- Update function
--  @param {Number} dt
function Root:update(dt)
  Object.update(self, dt)

  self:_updateSize()
end

--- Updates the size to the window size
--  @private
function Root:_updateSize()
  self.size = {
    width = love.window:getWidth(),
    height = love.window:getHeight()
  }
end

return Root
