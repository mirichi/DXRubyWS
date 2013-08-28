# coding: utf-8
require_relative './popupmenu'

module WS
  # マウスの右ボタンを押したらポップアップメニューを表示する機能を追加するモジュール
  module UseRightClickMenu
    attr_accessor :menuitems
    def on_mouse_r_push(tx, ty)
      WS.desktop.remove_control(@rightclickmenu) if @rightclickmenu
      tmpx, tmpy = self.get_global_vertex
      @rightclickmenu = WSRightClickMenu.new(tx + tmpx, ty + tmpy, @menuitems)
      WS.desktop.add_control(@rightclickmenu)
      @rightclickmenu.object = self
      super
    end
  end

  class WSRightClickMenu < WSContainer
    attr_accessor :object

    def initialize(tx, ty, menuitems)
      super(0, 0, Window.width - 1, Window.height - 1)
      self.image.dispose
      self.image = nil # RenderTargetは持たない
      add_control(WSPopupMenu.new(tx+1, ty+1, menuitems), :popupmenu)
      self.popupmenu.z = WS.default_z
      WS.capture(self)
    end

    # WSContainerでは配下オブジェクトの選択はinternalのメソッドで処理されるが、
    # PopupMenuはマウスキャプチャするため配下のオブジェクトが呼ばれないのでここで自前で処理する
    def on_mouse_push(tx, ty)
      ctl = find_hit_object(tx, ty)
      ctl.mouse_event_dispach(:mouse_push, tx - ctl.x, ty - ctl.y) if ctl
      self.parent.remove_control(self)
      WS.capture(nil)
    end

    def on_mouse_r_push(tx, ty)
      on_mouse_push(tx, ty)
    end
    
    def on_mouse_r_release(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.mouse_event_dispach(:mouse_push, tx - ctl.x, ty - ctl.y)
        self.parent.remove_control(self)
        WS.capture(nil)
      end
    end
    
    def on_mouse_move(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.mouse_event_dispach(:mouse_move, tx - ctl.x, ty - ctl.y)
      else
        super
      end
    end
  end
end
