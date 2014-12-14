# coding: utf-8
require_relative './popupmenu'

module WS
  # マウスの右ボタンを押したらポップアップメニューを表示する機能を追加するモジュール
  module UseRightClickMenu
    attr_accessor :r_menuitems
    def on_mouse_r_push(tx, ty)
      WS.desktop.remove_control(@rightclickmenu) if @rightclickmenu
      tmpx, tmpy = self.get_global_vertex
      @rightclickmenu = WSPopupMenu.new(tx + tmpx, ty + tmpy, @r_menuitems)
      WS.desktop.add_control(@rightclickmenu)
      @rightclickmenu.object = self
      super
      WS.capture(@rightclickmenu)
    end
  end
  
  # マウスの中ボタンを押したらポップアップメニューを表示する機能を追加するモジュール
  module UseMiddleClickMenu
    attr_accessor :m_menuitems
    def on_mouse_m_push(tx, ty)
      WS.desktop.remove_control(@middleclickmenu) if @middleclickmenu
      tmpx, tmpy = self.get_global_vertex
      @middleclickmenu = WSPopupMenu.new(tx + tmpx, ty + tmpy, @m_menuitems)
      WS.desktop.add_control(@middleclickmenu)
      @middleclickmenu.object = self
      super
      WS.capture(@middleclickmenu)
    end
  end
end
