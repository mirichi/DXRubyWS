# coding: utf-8
require_relative './button'
require_relative './label'
require_relative './common'

module WS
  # システムモーダルなメッセージボックス
  class WSMessageBox < WSLightContainer
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
      def initialize(*)
        super
        self.image.bgcolor = COLOR[:base]
      end
      
      def add_control(obj, name=nil)
        super
        self.parent.set_focus(obj) if obj.focusable
      end

      def render
        self.image.draw_font(10, 16, @parent.message, @parent.font, :color=>COLOR[:font])
        super
      end
    end

    attr_accessor :border_width # ウィンドウボーダーの幅
    attr_reader :window_focus, :message # ウィンドウ上のフォーカスを持つコントロール
    include WindowFocus
    include Focusable

    def initialize(caption = "", message)
      @font = @@default_font
      size = @font.get_width(message)
      tx = WS.desktop.width / 2 - size / 2 - (20 + 6) / 2
      ty = WS.desktop.height / 2 - (@font.size + 16 + 32 + 20 + 6) / 2
      sx = size + 20 + 6
      sy = @font.size + 16 + 32 + 20 + 6
      super(tx, ty, sx, sy)
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
      super
      draw_border(true)
    end

    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy)
    end

    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      WS.capture(nil)
      super
    end
  end
end
