require 'dxruby'
require_relative '../lib/dxrubyws'

w = WS::WSWindow.new(100,100,300,100)
b = WS::WSButton.new(10,30,100,20)
l = WS::WSLabel.new(10,70,100,20)
w.add_control(b)
w.add_control(l)
WS::desktop.add_control(w)

Window.loop do
  WS.update
end
