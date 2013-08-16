require 'dxruby'
require_relative '../lib/dxrubyws'

w = WS::WSWindow.new(100, 100, 300, 100, "Test")
b = WS::WSButton.new(10, 10, 100, 20)
l = WS::WSLabel.new(10, 50, 100, 20)
w.client.add_control(b)
w.client.add_control(l)

image1 = Image.new(30, 30, C_WHITE)
image2 = Image.new(30, 30, C_BLACK)
image3 = Image.new(30, 30, C_RED)
i = WS::WSImage.new(200, 30, 30, 30)
i.image = image1
i.add_handler(:mouse_over){|obj|obj.image = image2}
i.add_handler(:mouse_out){|obj|obj.image = image1}
i.add_handler(:click){|obj|obj.image = image3}
w.client.add_control(i)

WS.desktop.add_control(w)

w = WS::WSWindow.new(400, 100, 200, 250, "ListBoxTest")
lbx = WS::WSListBox.new(50, 30, 100, 160)
lbx.items.concat(String.instance_methods(false))
w.client.add_control(lbx)
lbl = WS::WSLabel.new(0, 0, 100, 16)
lbl.caption = lbx.items[lbx.cursor].to_s
lbx.add_handler(:select){|obj, cursor| lbl.caption = obj.items[cursor].to_s}
w.client.add_control(lbl)

WS::desktop.add_control(w)

class Test < WS::WSWindow
  def initialize
    super(100, 300, 300, 100, "LayoutTest")
    self.image.bgcolor = [160,160,160]

    b1 = WS::WSButton.new(10, 10, 100, 20, "btn1")
    self.client.add_control(b1)
    b2 = WS::WSButton.new(10, 30, 100, 20, "btn2")
    self.client.add_control(b2)
    b3 = WS::WSButton.new(10, 50, 100, 20, "btn3")
    self.client.add_control(b3)

    layout(:hbox) do
      layout(:vbox) do
        add b1
        add b2
      end
      layout(:vbox) do
        add b3
      end
    end
  end
end

t = Test.new
WS.desktop.add_control(t)

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
end

