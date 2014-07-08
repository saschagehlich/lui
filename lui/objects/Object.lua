local pathMatch = "(.+)%.objects.Object$"
local class = require((...):match(pathMatch) .. ".lib.middleclass")
local EventEmitter = require((...):match(pathMatch) .. ".lib.EventEmitter")

local Object = class("Object", EventEmitter)

--- `Object` constructor
--  @param {lui} lui
function Object:initialize(lui)
  self.lui = lui

  EventEmitter.initialize(self)

  self.children = {}

  -- Decides whether `position` should be relative to its parent
  -- or absolute (= relative to screen / window)
  self.positionMode = "relative"

  self.size = { width = 0, height = 0 }
  self.position = { x = 0, y = 0 }
  self.padding = { x = 0, y = 0 }

  self.isVisible = false
end

--- Update method
--  @param {Number} dt
function Object:update(dt)
  self:_handleMouse(dt)

  -- Update children
  self:eachChild(function (object)
    object:update(dt)
  end)
end

--- Draws the object
function Object:draw()
  -- Draw children
  self:eachChild(function (object)
    object:draw()
  end)
end

--- Gets the drawing position (considering positionMode, offset etc.)
--  @returns {Number, Number}
--  @private
function Object:_getRealPosition()
  return self.position.x, self.position.y
end

--- Handles mouse interaction
--  @param {Number} dt
--  @private
function Object:_handleMouse(dt)
  local x, y = self:_getRealPosition()
  local width, height = self.size.width, self.size.height

  -- Rectangular intersection
  local mouseX, mouseY = love.mouse.getPosition()
  if not (mouseX < x or
    mouseX > x + width or
    mouseY < y or
    mouseY > y + height) then

      -- Update hovered state, emit `hover` event
      if not self.hovered then
        self:emit("hover", self)
        self.hovered = true
      end

  else

    -- Update hovered state, emit `blur` event
    if self.hovered then
      self.hovered = false
      self:emit("blur", self)
    end

  end
end

--[[
  Public methods
]]--

--- Calls fn for each child
--  @param {Function} fn
--  @param {Boolean} recursive
--  @private
function Object:eachChild(fn, recursive)
  for _, child in pairs(self.children) do
    fn(child)
    if recursive then
      child:eachChild(fn, true)
    end
  end
end

--- Adds a child to this object
--  @param {Object} object
function Object:addChild(object)
  self.children[#self.children + 1] = object
  object.parent = self
end

--- Displays the object
function Object:show()
  self.isVisible = true
end

--- Hides the object
function Object:hide()
  self.isVisible = false
end

-- Sets the position
function Object:setPosition(x, y)
  if x ~= nil then self.position.x = x end
  if y ~= nil then self.position.y = y end
end

return Object
