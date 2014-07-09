local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setPosition("10%", "10%")
  window:setSize("80%", "80%")
  window:on("hover", function (object)
    print("Hovering", object)
  end)
  window:on("blur", function (object)
    print("Not hovering anymore", object)
  end)
  window:show()
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
