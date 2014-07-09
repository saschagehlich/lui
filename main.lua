local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setSize("90%", "90%")
  window:show()
  window:setLockedTo(gui.root)
  window:setCenter()

  local panel = gui:createPanel()
  panel:setPositionMode("absolute")
  panel:setPosition(0, 60)
  panel:setSize("100%", "100% - y")
  window:addChild(panel)

  local text = gui:createText("This is some random text which is kinda long yo.")
  window:addChild(text)
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
