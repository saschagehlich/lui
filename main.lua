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
  window:setLockedTo(gui.root)
  window:setCenter()

  local panel = gui:createPanel()
  panel:setPosition(0, 40)
  panel:setScheme("Gray")
  panel:setSize("100%", "100% - y")
  panel:setPadding(5, 5)
  window:addChild(panel)

  local list = gui:createList()
  list:setPosition(0, 40)
  list:setSize("100%", "100% - y")
  list:setPadding(10)
  panel:addChild(list)

  for i = 1, 20, 1 do
    local item = gui:createListItem()

    local text = gui:createText("Ohai " .. i)
    text:setAlignment("center", "center")
    text:setSize("100%", "100%")

    item:addChild(text)
    list:addItem(item)
  end
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
