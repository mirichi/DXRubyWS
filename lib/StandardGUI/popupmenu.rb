# coding: utf-8
require_relative './menuitem'

module WS
  # ポップアップメニュー
  class WSPopupMenu < WSContainer
    attr_accessor :object, :submenu
    def initialize(tx, ty, menuitems)
      @menuitems = menuitems
      @font = Font.new(12)

      # メニューアイテムからサイズ算出
      width = @font.get_width(menuitems[0].str)
      height = @font.size * menuitems.size

      super(tx, ty, width + 10, height + 8)
      self.image.bgcolor = [190, 190, 190]
      
      # メニューアイテムの位置設定
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
    end

    # WSContainerでは配下オブジェクトの選択はinternalのメソッドで処理されるが、
    # PopupMenuはマウスキャプチャするため配下のオブジェクトが呼ばれないので自前で処理する
    def mouse_event(event, tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        if Array === ctl.obj # サブメニューを押した場合は無反応
          return self
        end
        # メニュー項目にヒットしていたらそっちにイベントを送ってメニューを消す
        WS.capture(nil)
        ctl.mouse_event_dispach(event, tx - ctl.x, ty - ctl.y)
        self.parent.remove_control(self)
        return ctl
      else
        # メニュー項目にヒットしていなくてもメニューウィンドウの上なら何もしない
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        if @hit_cursor === self
          return self
        end

        # メニューウィンドウ外だった場合はデスクトップにイベントを送ってメニューを消す
        # マウスボタンを離したときは送らない(操作性のため)
        if event != :mouse_release and event != :mouse_r_release and event != :mouse_m_release
          tmp = self.get_global_vertex
          if @submenu and @hit_cursor === @submenu
            hit_obj = @submenu.mouse_event_dispach(event, tmp[0] + tx - @submenu.x, tmp[1] + ty - @submenu.y)
            if hit_obj != @submenu
              self.parent.remove_control(self)
              WS.capture(nil)
            end
          else
            WS.capture(nil)
            self.parent.remove_control(self)
            WS.desktop.mouse_event_dispach(event, tmp[0] + tx, tmp[1] + ty)
          end
        end
      end
    end

    # ボタン系のイベントはすべてmouse_eventで処理する
    def on_mouse_push(tx, ty)
      mouse_event(:mouse_push, tx, ty)
      super
    end
    
    def on_mouse_m_push(tx, ty)
      mouse_event(:mouse_m_push, tx, ty)
      super
    end
    
    def on_mouse_r_push(tx, ty)
      mouse_event(:mouse_r_push, tx, ty)
      super
    end
    
    def on_mouse_release(tx, ty)
      mouse_event(:mouse_release, tx, ty)
      super
    end

    def on_mouse_m_release(tx, ty)
      mouse_event(:mouse_m_release, tx, ty)
      super
    end

    def on_mouse_r_release(tx, ty)
      mouse_event(:mouse_r_release, tx, ty)
      super
    end

    # 移動イベントだけはキャプチャをはずさないので独自に処理する
    def on_mouse_move(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        # サブメニューだった場合、もうひとつポップアップメニューを表示する
        if Array === ctl.obj and @old_ctl != ctl
          @old_ctl = ctl
          @submenu = WSPopupMenu.new(self.x + self.width, self.y + ((ty - 4) / @font.size) * @font.size, ctl.obj)
          @submenu.z = WS::default_z
        end

        ctl.mouse_event_dispach(:mouse_move, tx - ctl.x, ty - ctl.y)
        return ctl
      else
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        if @hit_cursor === self
          return self
        end

        tmp = self.get_global_vertex
        if @submenu and @hit_cursor === @submenu
          @submenu.mouse_event_dispach(:mouse_move, tmp[0] + tx - @submenu.x, tmp[1] + ty - @submenu.y)
        else
          WS.desktop.mouse_event_dispach(:mouse_move, tmp[0] + tx, tmp[1] + ty)
        end
      end
    end

    def draw
      # メニュー描画
      @menuitems.each_with_index do |s, i|
        if s == nil # nilの場合はセパレータを描画する
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

      if @submenu
        @submenu.draw
      end
    end
  end
end
