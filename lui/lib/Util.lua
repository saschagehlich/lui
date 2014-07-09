

local pathMatch = "(.+)%.Util$"
local inspect = require((...):match(pathMatch) .. ".serpent").block

local Util = {}

--- Checks whether the given point intersects with the given rectangle
--  @param {Table} point
--  @param {Table} rect
--  @returns {Boolean}
function Util.pointIntersectsWithRect(point, rect)
  return not (
    point.x < rect.x or
    point.x > rect.x + rect.width or
    point.y < rect.y or
    point.y > rect.y + rect.height
  )
end

--- Returns a stringified version of the given object (stringified using serpent)
--  @param {?} object
--  @returns {String}
function Util.inspect(object)
  return inspect(object)
end

--- Checks whether the given table contains the given value
--  @param {Table} array
--  @param {?} value
--  @returns {Boolean}
function Util.contains(array, value)
  for _, val in ipairs(array) do
    if val == value then
      return true
    end
  end
  return false
end

return Util
