local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setPosition("10%", "10%")
  window:setSize("80%", "80%")
  window:show()

  local button = gui:createButton("OK")
  button:setPosition({ bottom = 0, right = 0 })
  window:addChild(button)
end

function love.update(dt)
  gui:update(dt)
end

function love.draw()
  gui:draw()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
