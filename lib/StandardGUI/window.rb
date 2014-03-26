# coding: utf-8
require_relative './windowbase'
require_relative './menubar'

module WS
  # ウィンドウぽい動きを実現してみる
  class WSWindow < WSWindowBase
    attr_accessor :border_width # ウィンドウボーダーの幅
    attr_reader :window_focus # ウィンドウ上のフォーカスを持つコントロール
    include WindowFocus
    include Resizable
    include Focusable

    def initialize(tx, ty, sx, sy, caption = "WindowTitle")
      super

      # ウィンドウタイトルはそれでひとつのコントロールを作る
      # メニューやツールバー、ステータスバーもたぶんそうなる
      window_title = WSWindowTitle.new(0, 0, sx - @border_width * 2, 16, caption)
      add_control(window_title, :window_title)
      window_title.add_handler(:close) {self.close}
      window_title.add_handler(:drag_move, self.method(:on_drag_move))

      # タイトルバーのダブルクリックで最大化する
      @maximize_flag = false
      window_title.add_handler(:doubleclick, self.method(:on_maximize))

      # クライアント領域は単純なコンテナである
      client = WSWindowClient.new(0, 0, sx - @border_width * 2, sy - @border_width * 2 - 16)
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

    end

    def add_menubar(menuitems)
      add_control(WSMenuBar.new(menuitems), :menubar)
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add obj.window_title, true
        add obj.menubar, true
        add obj.client, true, true
      end
    end

    # コントロール画像の描画
    def render
      draw_border(true)
      super
    end

    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy) unless @maximize_flag
    end

    def on_maximize(obj, dx, dy)
      if @maximize_flag
        # 最大化状態から戻す処理
        move(@origin_x, @origin_y)
        resize(@origin_width, @origin_height)
        @maximize_flag = false
      else
        # 最大化する処理
        @origin_x, @origin_y = self.x, self.y
        @origin_width, @origin_height = self.width, self.height
        move(-@border_width, -@border_width)
        resize(self.target.width + @border_width * 2, self.target.height + @border_width * 2)
        @maximize_flag = true
      end
    end
  end
end