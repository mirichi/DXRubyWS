# coding: utf-8
require_relative './menuitem'

module WS
  # マウスの右ボタンを押したらポップアップメニューを表示する機能を追加するモジュール
  module UsePopupMenu
    attr_accessor :menuitems
    def on_mouse_r_down(tx, ty)
      WS.desktop.remove_control(@popupmenu) if @popupmenu
      tmpx, tmpy = self.get_global_vertex
      @popupmenu = WSPopupMenu.new(tx + tmpx, ty + tmpy, @menuitems)
      WS.desktop.add_control(@popupmenu)
      @popupmenu.object = self
      super
    end
  end

  # ポップアップメニュー
  class WSPopupMenu < WSContainer
    attr_accessor :object
    def initialize(tx, ty, menuitems)
      @menuitems = menuitems
      @font = Font.new(12)
      width = @font.get_width(menuitems[0].str)
      height = @font.size * menuitems.size
      super(tx, ty, width + 10, height + 8)
      self.image.bgcolor = [190, 190, 190]
      menuitems.each_with_index do |o, i|
        if o
          o.x = 5
          o.y = i * @font.size + 4
          o.width = width
          o.height = @font.size
          o.collision = [0, 0, o.width-1, o.height-1]
          add_control(o)
        end
      end
      WS.capture(self)
    end

    # WSContainerでは配下オブジェクトの選択はinternalのメソッドで処理されるが、
    # PopupMenuはマウスキャプチャするため直接マウスイベントが呼ばれる可能性があり、ここで処理する
    def on_mouse_down(tx, ty)
      ctl = find_hit_object(tx, ty)
      ctl.on_mouse_down_internal(tx - ctl.x, ty - ctl.y) if ctl
      self.parent.remove_control(self)
      WS.capture(nil)
    end

    def on_mouse_r_down(tx, ty)
      on_mouse_down(tx, ty)
    end
    
    def on_mouse_r_up(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_down_internal(tx - ctl.x, ty - ctl.y)
        self.parent.remove_control(self)
        WS.capture(nil)
      end
    end
    
    def on_mouse_move(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_move_internal(tx - ctl.x, ty - ctl.y)
      else
        super
      end
    end
    
    def draw
      # メニュー描画
      @menuitems.each_with_index do |s, i|
        if s == nil
          tmp = i * @font.size + @font.size * 0.5 + 3
          self.image.draw_line(5, tmp,  @width - 7, tmp,[80,80,80])
          self.image.draw_line(5, tmp + 1,  @width - 7, tmp + 1,[240,240,240])
        else         
          s.draw
        end
      end

      # ボーダーライン
      sx = @width
      sy = @height
      self.image.draw_line(0,0,sx-1,0,[240,240,240])
      self.image.draw_line(0,0,0,sy-1,[240,240,240])
      self.image.draw_line(1,1,sx-1,1,[200,200,200])
      self.image.draw_line(1,1,1,sy-1,[200,200,200])
      self.image.draw_line(sx-1,0,sx-1,sy-1,[80,80,80])
      self.image.draw_line(0,sy-1,sx-1,sy-1,[80,80,80])
      self.image.draw_line(sx-2,1,sx-2,sy-2,[120,120,120])
      self.image.draw_line(1,sy-2,sx-2,sy-2,[120,120,120])

      super
    end
  end
end
