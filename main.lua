local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setSize(300, 250)
  window:setPosition(0, "10%")
  window:setCenter(true, false)
  window:setShowCloseButton(true)
  window:show()

  local button = gui:createButton("OK")
  button:setPosition({ bottom = 0, right = 0 })
  button:setToggleable(true)
  window:addChild(button)

  button:setCenter(true, false)
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
