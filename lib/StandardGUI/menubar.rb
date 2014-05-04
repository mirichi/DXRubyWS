# coding: utf-8
require_relative './popupmenu'
require_relative './common'

module WS
  # ウィンドウにくっつけるメニューバー
  class WSMenuBar < WSContainer
    def initialize(menuitems)
      super(0, 0, 10, 16) # 数字テキトー。オートレイアウトで設定する。
      @menuitems = menuitems
      self.image.bgcolor = COLOR[:base]
      @font = Font.new(12)
      @selected = nil
      @popup = nil
    end

    # メニュークリックでポップアップメニューを表示する
    def on_mouse_push(tx, ty)
      x = 5
      @selected = nil
      @menuitems.each_with_index do |ary, i|
        tmp = @font.get_width(ary[0])
        if x - 5 <= tx and tx < x + tmp + 5
          WS.desktop.remove_control(@popup) if @popup
          tmpx, tmpy = self.get_global_vertex
          @popup = WSPopupMenu.new(x + tmpx, 16 + tmpy, ary[1])
          WS.desktop.add_control(@popup)
          @popup.object = self
          super
          WS.capture(@popup)
        end
        x += tmp + 10
      end
      super
    end

    # マウスの移動でどのメニューが選択されているかを判定し、選択する
    def on_mouse_move(tx, ty)
      x = 5
      @selected = nil
      @menuitems.each_with_index do |ary, i|
        tmp = @font.get_width(ary[0])
        if x - 5 <= tx and tx < x + tmp + 5
          @selected = i
          if @popup and WS.captured?(@popup)
            WS.desktop.remove_control(@popup) if @popup
            tmpx, tmpy = self.get_global_vertex
            @popup = WSPopupMenu.new(x + tmpx, 16 + tmpy, ary[1])
            WS.desktop.add_control(@popup)
            @popup.object = self
            super
            WS.capture(@popup)
          end
        end
        x += tmp + 10
      end
      super
    end

    def on_mouse_out
      @selected = nil
      super
    end

    def render
      x = 5
      @menuitems.each_with_index do |ary, i|
        tmp = @font.get_width(ary[0])
        if @selected == i
          image = Image.new(tmp + 2, 16, [150, 150, 150])
          self.image.draw(x - 1, 0, image)
        end
        self.image.draw_font(x, 2, ary[0], @font, :color=>COLOR[:font])
        x += tmp + 10
      end
      super
    end
  end
end
