# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
WS.set_theme("guibasic")

module WS
  class LayoutTest < WSWindow
    def initialize
      super(20,100,300,320)

      self.client.add_control(b1 = WSButton.new(nil, nil, 100), :b1)
      self.client.add_control(b2 = WSButton.new, :b2)
      self.client.add_control(b3 = WSButton.new, :b3)
      b1.min_height = 40
      b2.min_height = 120
      b3.min_height = 120
      self.client.layout(:vbox) do
        add b1
        add b2
        add b3
      end
    end
  end
  class LayoutTest2 < WSWindow
    def initialize
      super(330,100,300,320)

      self.client.add_control(b1 = WSButton.new, :b1)
      self.client.add_control(b2 = WSButton.new, :b2)
      self.client.add_control(b3 = WSButton.new, :b3)
      b1.min_width = 40
      b2.min_width = 120
      b3.min_width = 120
      self.client.layout(:hbox) do
        add b1
        add b2
        add b3
      end
    end
  end
end

w = WS::LayoutTest.new
WS.desktop.add_control w

w2 = WS::LayoutTest2.new
WS.desktop.add_control w2

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
  Window.caption = Window.get_load.to_s
end

