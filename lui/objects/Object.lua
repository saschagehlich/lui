local pathMatch = "(.+)%.objects.Object$"
local pathBase = (...):match(pathMatch)

-- Dependencies
local Box = require(pathBase .. ".objects.Box")
local class = require(pathBase .. ".lib.middleclass")
local Util = require(pathBase .. ".lib.Util")

-- Mixins
local EventEmitter = require(pathBase .. ".objects.mixins.EventEmitter")
local Hoverable = require(pathBase .. ".objects.mixins.Hoverable")
local Clickable = require(pathBase .. ".objects.mixins.Clickable")
local Draggable = require(pathBase .. ".objects.mixins.Draggable")
local Tooltippable = require(pathBase .. ".objects.mixins.Tooltippable")

--- Object class
local Object = class("Object", Box)
Object:include(EventEmitter)
Object:include(Hoverable)
Object:include(Clickable)
Object:include(Draggable)
Object:include(Tooltippable)

--- `Object` constructor
--  @param {lui} lui
function Object:initialize(lui)
  Box.initialize(self, lui)

  self.theme = self.lui.defaultTheme
  self.scheme = self.lui.defaultScheme

  EventEmitter._init(self)
  Hoverable._init(self)
  Clickable._init(self)
  Draggable._init(self)
  Tooltippable._init(self)
end

--- Update method
--  @param {Number} dt
function Object:update(dt)
  -- Don't update if invisible!
  if not self.isVisible then return end

  self:_updateHoverable(dt)
  self:_updateClickable(dt)
  self:_updateDraggable(dt)
  self:_updateTooltippable(dt)

  Box.update(self, dt)
end

--- Draws the object
function Object:draw()
  -- Don't draw if invisible!
  if not self.isVisible then return end

  -- Draw children
  self:eachChild(function (object)
    object:draw()
  end)

  -- Draw internals
  self:eachInternal(function (object)
    object:draw()
  end)
end

--- Sets the theme of this object
--  @param {String}
--  @public
function Object:setTheme(name)
  self.theme = self.lui:getTheme(name)

  self:eachChild(function (child)
    child:setTheme(name)
  end)

  self:eachInternal(function (child)
    child:setTheme(name)
  end)
end

--- Sets the color scheme of this object
--  @param {String}
--  @public
function Object:setScheme(name)
  self.scheme = self.lui:getScheme(name)

  self:eachChild(function (child)
    child:setScheme(name)
  end)

  self:eachInternal(function (child)
    child:setScheme(name)
  end)
end

return Object
