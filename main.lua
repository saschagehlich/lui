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

  local leftPanel = gui:createPanel()
  leftPanel:setPosition(0, 0)
  leftPanel:setSize("50%", "max")
  window:addChild(leftPanel)

  local rightPanel = gui:createPanel()
  rightPanel:setPosition({ right = 0, top = 0 })
  rightPanel:setSize("50%", "max")
  window:addChild(rightPanel)

  local bottomPanel = gui:createPanel()
  bottomPanel:setPosition({ bottom = 0, left = 0 })
  bottomPanel:setSize("100%", 100)
  window:addChild(bottomPanel)

  -- local text = gui:createText("Yo sup?")
  -- text:setAlignment("center", "center")
  -- text:setSize("100%", "100%")
  -- window:addChild(text)
  -- text:setCenter()

  -- button:setCenter(true, false)
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
