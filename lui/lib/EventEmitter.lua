local pathMatch = "(.+)%.lib.EventEmitter$"

local class = require((...):match(pathMatch) .. ".lib.middleclass")
local EventEmitter = class("EventEmitter")

function EventEmitter:initialize()
  self._events = {}
end

--- Iterates through all listeners, calls them with the
--  given arguments
--  @param {String} eventName
function EventEmitter:emit(eventName, ...)
  local listeners = self._events[eventName] or {}
  for i, listener in pairs(listeners) do
    if listener.context then
      listener.fn(listener.context, ...)
    else
      listener.fn(...)
    end
  end
end

--- Adds a new listener for the given event name
--  @param {String} eventName
--  @param {Table} context
--  @param {Function} listener
function EventEmitter:on(eventName, context, listener)
  if type(context) == "function" then
    listener = context
    context = nil
  end
  assert(type(listener) == "function", "EventEmitter:on: Listener is not a function.")

  self._events[eventName] = self._events[eventName] or {}
  table.insert(self._events[eventName], {
    fn = listener,
    context = context
  })
end

--- Removes an event listener
--  @param {String} eventName
--  @param {Function} listener
function EventEmitter:off(eventName, listener)
  self._events = _.filter(self._events, function (event)
    return event.fn == listener
  end)
end

return EventEmitter
