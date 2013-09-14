# coding: utf-8
require_relative './button'
require_relative './label'

module WS
  # システムモーダルなメッセージボックス
  class WSMessageBox < WSContainer
    # ウィンドウのタイトルバー用クラス
    class WSMessageBoxTitle < WSContainer
      include Draggable       # ウィンドウのドラッグ用
  
      def initialize(tx, ty, width, height, title="")
        super(tx, ty, width, height)
        self.image.bgcolor = [0, 0, 160]
  
        # ウィンドウタイトル
        label = WSLabel.new(0, 0, width, height, title)
        label.fore_color = C_WHITE
        label.font = Font.new(14, nil, :weight=>true)
        add_control(label)

        # オートレイアウト
        layout(:hbox) do
          self.margin_top = self.margin_right = 1
          self.margin_left = 2
          add label, true
        end
      end
    end

    class WSMessageBoxClient < WSContainer
      def add_control(obj, name=nil)
        super
        if obj.focusable
          self.parent.window_focus = obj
        end
      end
    end

    attr_accessor :border_width # ウィンドウボーダーの幅
    attr_reader :window_focus # ウィンドウ上のフォーカスを持つコントロール
    include Focusable

    def initialize(caption = "", message)
      @font = @@default_font
      size = @font.get_width(message)
      tx = WS.desktop.width / 2 - size / 2 - (20 + 6) / 2
      ty = WS.desktop.height / 2 - (@font.size + 16 + 32 + 20 + 6) / 2
      sx = size + 20 + 6
      sy = @font.size + 16 + 32 + 20 + 6
      super(tx, ty, sx, sy)
      self.image.bgcolor = [190,190,190]
      @border_width = 3
      @message = message

      window_title = WSMessageBoxTitle.new(0, 0, sx - @border_width * 2, 16, caption)
      add_control(window_title, :window_title)
      window_title.add_handler(:drag_move, self.method(:on_drag_move))
      window_title.add_handler(:drag_end){WS.capture(self, true)} # キャプチャが外れるのでしなおし

      # クライアント領域は単純なコンテナである
      client = WSMessageBoxClient.new(0, 0, sx - @border_width * 2, sy - @border_width * 2 - 16)
      add_control(client, :client)

      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add window_title, true
        add client, true, true
      end

      # Escで閉じる
      add_key_handler(K_ESCAPE){self.close}

      btn = WS::WSButton.new(self.width / 2 - 100 / 2, @font.size + 24, 100, 20, "OK")
      client.add_control(btn, :btn)
      btn.add_handler(:click){self.close}
      btn.add_handler(:click_cancel){WS.capture(self, true)} # キャプチャが外れるのでしなおし

      # マウスキャプチャする
      WS.capture(self, true)
    end

    def draw
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
      self.image.draw_font(10 + 3, 16 + 16, @message, @font, :color=>C_BLACK)
      super
    end

    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy)
    end

    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      self.parent.remove_control(self)
      WS.capture(nil)
      WS.set_focus(self.parent.childlen.last)
    end

    # キーハンドラを呼ばなかったらウィンドウフォーカスコントロールに転送
    def on_key_push(key)
      if @window_focus
        tmp = @window_focus.on_key_push(key)
        tmp = super unless tmp
        tmp
      else
        super
      end
    end

    # キーハンドラを呼ばなかったらウィンドウフォーカスコントロールに転送
    def on_key_release(key)
      if @window_focus
        tmp = @window_focus.on_key_release(key)
        tmp = super unless tmp
        tmp
      else
        super
      end
    end

    def window_focus=(obj)
      @window_focus.on_leave if @window_focus and @window_focus != obj
      @window_focus = obj
      @window_focus.on_enter if WS.focused_object == self and @window_focus
    end

    # ウィンドウがアクティブ化したときにフォーカスコントロールにon_enterを転送
    def on_enter
      @window_focus.on_enter if @window_focus
      super
    end

    # ウィンドウがノンアクティブ化したときにフォーカスコントロールにon_leaveを転送
    def on_leave
      @window_focus.on_leave if @window_focus
      super
    end
  end
end
