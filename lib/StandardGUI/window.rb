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

    ### ■ウィンドウ内容を描画するクライアント領域の定義■ ###
    class WSWindowClient < WSContainer
      def initialize(*)
        super
        self.image.bgcolor = COLOR[:base]
      end

      def add_control(obj, name=nil)
        super
        self.activate
      end
    end

    ### ■ウィンドウのクローズボタン用クラス■ ###
    class WSWindowCloseButton < WSButton
      def initialize(*args)
        super
        @focusable = false
      end

      def set_image
        super
        @image[:pushed].line(4, 4, @width-5, @height-5, C_BLACK)
                    .line(5, 4, @width-4, @height-5, C_BLACK)
                    .line(@width-5, 4, 4, @height-5, C_BLACK)
                    .line(@width-4, 4, 5, @height-5, C_BLACK)
        @image[:usual].line(4-1, 4-1, @width-5-1, @height-5-1, C_BLACK)
                    .line(5-1, 4-1, @width-4-1, @height-5-1, C_BLACK)
                    .line(@width-5-1, 4-1, 4-1, @height-5-1, C_BLACK)
                    .line(@width-4-1, 4-1, 5-1, @height-5-1, C_BLACK)
      end
    end
    
    ### ■ウィンドウのタイトルバー用クラス■ ###
    class WSWindowTitle < WSContainer
      include DoubleClickable # 最大化用
      include Draggable # ウィンドウのドラッグ用
  
      def initialize(tx, ty, width, height, title="")
        super(tx, ty, width, height)
        self.image.bgcolor = [0, 0, 160]
  
        # タイトルバーのクロースボタン
        close_button = WSWindowCloseButton.new(nil, nil, height-2, height-2, "")
        close_button.fore_color = COLOR[:font]
        add_control(close_button)
        close_button.add_handler(:click) {signal(:close)}
  
        # ウィンドウタイトル
        label = WSLabel.new(nil, nil, nil, height, title)
        label.fore_color = C_WHITE
        label.font = Font.new(14, nil, :weight=>true)
        add_control(label)

        add_handler(:doubleclick) do
          @dragging_flag = false
        end

        # オートレイアウト
        layout(:hbox) do
          self.margin_top = self.margin_right = 1
          self.margin_left = 2
          add label
          add close_button
        end
      end

      def render
        if parent.activated?
          self.image.bgcolor = [30, 30, 180]
        else
          self.image.bgcolor = COLOR[:shadow]
        end
        super
      end
    end

    def initialize(tx, ty, sx, sy, caption = "WindowTitle")
      super

      # ウィンドウタイトルはそれでひとつのコントロールを作る
      # メニューやツールバー、ステータスバーもたぶんそうなる
      window_title = WSWindowTitle.new(nil, nil, nil, 16, caption)
      add_control(window_title, :window_title)
      window_title.add_handler(:close) {self.close}
      window_title.add_handler(:drag_move, self.method(:on_drag_move))

      # タイトルバーのダブルクリックで最大化する
      @maximize_flag = false
      window_title.add_handler(:doubleclick, self.method(:on_maximize))

      # クライアント領域は単純なコンテナである
      client = WSWindowClient.new
      add_control(client, :client)

      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add window_title
        add self.obj.client
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
      super
    end

    def draw
      draw_border(true)
      (@border_width-2).times do |i|
        self.target.draw_box(self.x + i + 2, self.y + i + 2, self.x + self.width - i - 2 - 1, self.y + self.height - i - 2 - 1, self.client.image.bgcolor)
      end
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