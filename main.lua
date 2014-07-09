local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setSize(300, 250)
  window:show()
  window:setLockedTo(gui.root)
  window:setCenter()

  local button = gui:createButton("OK")
  button:setPosition({ bottom = 0, right = 0 })
  button:on("click", function()
    window:remove()
  end)
  window:addChild(button)

  local text = gui:createText("Yo sup?")
  text:setAlignment("center", "center")
  text:setSize("100%", "100%")
  window:addChild(text)
  text:setCenter()

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
