function love.conf(t)
  t.window.title = "lui example app"
  t.window.resizable = true

  t.window.width = 1024
  t.window.height = 768

  io.stdout:setvbuf("no")
end
