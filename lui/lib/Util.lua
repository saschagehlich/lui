

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

return Util
