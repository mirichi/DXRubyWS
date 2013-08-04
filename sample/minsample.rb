require 'dxruby'
require_relative '../lib/dxrubyws'

w = WS::WSWindow.new(100,100,300,100)
b = WS::WSButton.new(10,10,100,20)
l = WS::WSLabel.new(10,50,100,20)
w.client.add_control(b)
w.client.add_control(l)

image1 = Image.new(30,30,C_WHITE)
image2 = Image.new(30,30,C_BLACK)
image3 = Image.new(30,30,C_RED)
i = WS::WSImage.new(200,30, image1)
i.add_handler(:mouse_over) do |obj|
  obj.image = image2
end
i.add_handler(:mouse_out) do |obj|
  obj.image = image1
end
i.add_handler(:click) do |obj|
  obj.image = image3
end
w.client.add_control(i)

WS::desktop.add_control(w)

w = WS::WSWindow.new(400,300,300,100)
WS::desktop.add_control(w)

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
end

