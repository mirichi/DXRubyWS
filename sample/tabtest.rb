# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
require_relative '../lib/fontcache'


module WS
  class TabTest < WSWindow
    def initialize
      super(100,100,400,300)
      tab = WSTab.new(30,30,300, 200)
      
      client.add_control tab
      panel1 = tab.create_tab_set :test1, "テスト１"
      panel2 = tab.create_tab_set :test2, "テスト２"
      
      panel1.add_control(b1 = WSButton.new(50,50,100,20))
      panel2.add_control(b2 = WSButton.new(100,100,100,20))
      b1.add_handler(:click) {|obj, tx, ty|self.button1_click(tx, ty)}
      b2.add_handler(:click) {|obj, tx, ty|self.button2_click(tx, ty)}
      
      panel1.add_control(b1 = WSTextBox.new(50,130,100,20))
      
      tab.select_tab :test1
      
    end
    
    def button1_click(tx, ty)
      WS.desktop.add_control(WS::WSMessageBox.new("MessageBoxTest", "メッセージボックステスト1"))
    end
    def button2_click(tx, ty)
      WS.desktop.add_control(WS::WSMessageBox.new("MessageBoxTest", "メッセージボックステスト2"))
    end
  end
end

w = WS::TabTest.new
WS.desktop.add_control w

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
  Window.caption = Window.get_load.to_s
end
