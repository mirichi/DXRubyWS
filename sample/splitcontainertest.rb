# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
require_relative '../lib/fontcache'

WS.set_theme("guibasic")

module WS
  class SeparatorTest < WSWindow
    def initialize
      super(0,0,560,400)
      # 垂直配置コンテナ
      scv = WSSplitContainer.new(nil,nil,nil,nil, :v)
      scv.separator_size = 8
      scv.space = 4
      scv.add_client(WSButton.new(0,0,72,72, "ボタンA"), :c_panel_d)
      scv.add_client(WSPanel.new(0,0,72,72, "パネルE"), :c_panel_e)
      scv.c_panel_d.min_height = 72
      scv.c_panel_e.min_height = 72
      # 水平配置コンテナ
      sch = WSSplitContainer.new
      sch.separator_size = 8
      sch.space = 4
      sch.add_client(WSLightContainer.new, :c_panel_a)
      sch.add_client(WSListBox.new, :c_panel_b)
      sch.add_client(WSLightContainer.new(0,0,72,24), :c_panel_c)
      sch.add_client(scv)
      sch.c_panel_a.min_width = 72
      sch.c_panel_b.min_width = 72
      sch.c_panel_c.min_width = 72
      # コンテナ要素の追加
      scv.c_panel_e.add_control(WSLabel.new(0,0,32,22,"チェックボックス"), :label_a)
      scv.c_panel_e.add_control(WSCheckBox.new(0,0,32,"チェックボックスA"), :checkbox_a)
      scv.c_panel_e.add_control(WSCheckBox.new(0,0,32,"チェックボックスB"), :checkbox_b)
      scv.c_panel_e.add_control(WSCheckBox.new(0,0,32,"チェックボックスC"), :checkbox_c)
      scv.c_panel_e.client.layout(:vbox) do
        self.space = 4
        add obj.label_a, true, false
        add obj.checkbox_a, true, false
        add obj.checkbox_b, true, false
        add obj.checkbox_c, true, false
        layout
      end
      sch.c_panel_a.add_control(WSLabel.new(0,0,32,22,"ラベルa"), :label_b)
      sch.c_panel_a.add_control(WSLabel.new(0,0,32,22,"ラベルb"), :label_c)
      sch.c_panel_a.add_control(WSLabel.new(0,0,32,22,"ラベルc"), :label_d)
      sch.c_panel_a.layout(:vbox) do
        self.space = 32
        add obj.label_b, true, false
        add obj.label_c, true, false
        add obj.label_d, true, false
        layout
      end
      # クライアントのオートレイアウト
      client.add_control(sch)
      client.layout(:hbox) do
        set_margin(8,8,8,8)
        add sch, true, true
      end
      
      # SplitContainerのレイアウト初期化
      sch.init_layout
      scv.init_layout
      
    end
  end
end
  
w  = WS::SeparatorTest.new
WS.desktop.add_control w

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
  Window.caption = Window.get_load.to_s
end
