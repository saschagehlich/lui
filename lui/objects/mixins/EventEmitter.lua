local EventEmitter = {}

function EventEmitter:_init()
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
--  @param {String} eventNames
--  @param {Function} listener
--  @param {Table} context
function EventEmitter:on(eventNames, listener, context)
  assert(type(listener) == "function", "EventEmitter:on: Listener is not a function.")

  for eventName in eventNames:gmatch("%w+") do
    self._events[eventName] = self._events[eventName] or {}
    table.insert(self._events[eventName], {
      fn = listener,
      context = context
    })
  end
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
