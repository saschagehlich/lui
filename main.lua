local lui = require("lui")

local gui = nil

function love.load()
  print("Ohai!")

  gui = lui()

  local window = gui:createWindow("Window title")
  window:setSize(640, 480)
  window:show()
  window:setScheme("Red")
  window:setPadding(40, 0, 0, 0)
  window:setLockedToParent(true)
  gui:addChild(window)
  window:setCenter()

  local panel = window:createPanel()
  panel:setPosition(0, 40)
  panel:setScheme("Gray")
  panel:setSize(lui.percent(100), lui.percent(100))
  panel:setPadding(5, 5)

  local tabs = panel:createTabs()
  tabs:setTabSize(100, 25)
  tabs:setSize(lui.percent(100), lui.percent(100))

  -- Add tabs
  local tab1 = tabs:createTab()
  tab1:setContent(tab1Panel)
  tabs:addTab(tab1)

  local tab2 = tabs:createTab()
  tab2:setContent(tab2Panel)
  tabs:addTab(tab2)
end

function love.update(dt)
  gui:update(dt)
end

function love.draw()
  gui:draw()

  love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)
end

function love.mousepressed(x, y, btn)
  gui:mousepressed(x, y, btn)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
