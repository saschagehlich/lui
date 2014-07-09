local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setPosition({ bottom = "10%", left = 0 })
  window:setSize(300, 250)
  window:show()

  local button = gui:createButton("OK")
  button:setPosition({ bottom = 0, right = 0 })
  button:setToggleable(true)
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
