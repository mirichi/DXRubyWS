# coding: utf-8
require_relative './menuitem'
require_relative './common'

module WS
  # ポップアップメニュー
  class WSPopupMenu < WSContainer
    attr_accessor :object, :submenu
    def initialize(tx, ty, menuitems)
      @menuitems = menuitems
      @font = Font.new(12)

      # メニューアイテムからサイズ算出
      width = menuitems.map{|o| @font.get_width(o.str)}.max
      height = @font.size * menuitems.size

      super(tx, ty, width + 10, height + 8)
      self.image.bgcolor = COLOR[:base]
      
      # メニューアイテムの位置設定
      menuitems.each_with_index do |o, i|
        if o
          o.x = 5
          o.y = i * @font.size + 4
          o.resize(width, @font.size)
          add_control(o)
        end
      end
    end

    # WSContainerでは配下オブジェクトの選択はinternalのメソッドで処理されるが、
    # PopupMenuはマウスキャプチャするため配下のオブジェクトが呼ばれないので自前で処理する
    def mouse_event_dispatch(event, tx, ty)
      if event == :mouse_move
        ctl = find_hit_object(tx, ty)
        if ctl
          # サブメニューだった場合、もうひとつポップアップメニューを表示する
          if Array === ctl.obj and @old_ctl != ctl
            @old_ctl = ctl
            @submenu = WSPopupMenu.new(self.x + self.width, self.y + ((ty - 4) / @font.size) * @font.size, ctl.obj)
            @submenu.z = WS::default_z
          else
            ctl.mouse_event_dispatch(:mouse_move, tx - ctl.x, ty - ctl.y)
          end
  
          return ctl
        else
          @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
          if @hit_cursor === self
            return self
          end

          if @submenu
            @submenu.mouse_event_dispatch(:mouse_move, self.x + tx - @submenu.x, self.y + ty - @submenu.y)
          else
            WS.desktop.mouse_event_dispatch(:mouse_move, self.x + tx, self.y + ty)
          end
        end
      else
        ctl = find_hit_object(tx, ty)
        if ctl
          if Array === ctl.obj # サブメニューを押した場合は無反応
            return self
          end
          # メニュー項目にヒットしていたらそっちにイベントを送ってメニューを消す
          WS.capture(nil)
          ctl.mouse_event_dispatch(event, tx - ctl.x, ty - ctl.y)
          self.parent.remove_control(self) if self.parent
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
            if @submenu
              hit_obj = @submenu.mouse_event_dispatch(event, self.x + tx - @submenu.x, self.y + ty - @submenu.y)
              if hit_obj != @submenu
                self.parent.remove_control(self) if self.parent
              end
            else
              WS.capture(nil)
              self.parent.remove_control(self) if self.parent
              WS.desktop.mouse_event_dispatch(event, self.x + tx, self.y + ty)
            end
          end
        end
      end
    end

    def render
      # メニュー描画
      @menuitems.each_with_index do |s, i|
        if s == nil # nilの場合はセパレータを描画する
          tmp = i * @font.size + @font.size * 0.5 + 3
          self.image.draw_line(5, tmp,  @width - 7, tmp,[80,80,80])
          self.image.draw_line(5, tmp + 1,  @width - 7, tmp + 1,[240,240,240])
        else         
          s.render
          s.draw
        end
      end

      # ボーダーライン
      render_border(true)

    super
    end

    def draw
      if @submenu
        @submenu.render
        @submenu.draw
      end
      super
    end
  end
end
