local lui = require("lui")

local gui = lui()

local window = gui:createWindow("This is the title")
window:show()

function love:update(dt)
  gui:update(dt)
end

function love:draw()
  gui:draw()
end
