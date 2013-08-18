require_relative './module.rb'

module WS
  # ウィンドウぽい動きを実現してみる
  class WSWindow < WSContainer
    
    # ウィンドウのタイトルバー用クラス
    class WSWindowTitle < WSContainer
      include Draggable       # ウィンドウのドラッグ用
      include DoubleClickable # 最大化用
  
      def initialize(tx, ty, width, height, title="Title")
        super(tx, ty, width, height)
        self.image.bgcolor = C_BLUE
  
        # タイトルバーのクロースボタン
        close_button = WSButton.new(0, 0, height-2, height-2, "X")
        close_button.fore_color = C_BLACK
        add_control(close_button)
        close_button.add_handler(:click) {signal(:close)}
  
        # ウィンドウタイトル
        label = WSLabel.new(0, 0, width, height, title)
        label.resizable_width = true
        add_control(label)

        # オートレイアウト
        layout(:hbox) do
          self.margin_top = self.margin_right = 1
          self.margin_left = 2
          add label
          add close_button
        end
      end
    end

    attr_accessor :border_width # ウィンドウボーダーの幅
    include Resizable

    def initialize(tx, ty, sx, sy, caption = "WindowTitle")
      super(tx, ty, sx, sy)
      self.image.bgcolor = [160,160,160]
      @border_width = 2

      # ウィンドウタイトルはそれでひとつのコントロールを作る
      # メニューやツールバー、ステータスバーもたぶんそうなる
      window_title = WSWindowTitle.new(0, 0, sx - @border_width * 2, 16, caption)
      window_title.resizable_width = true
      add_control(window_title)
      window_title.add_handler(:close) {self.parent.remove_control(self)}
      window_title.add_handler(:drag_move, self, :on_drag_move)

      # タイトルバーのダブルクリックで最大化する
      @maximize_flag = false
      window_title.add_handler(:doubleclick, self, :on_maximize)

      # クライアント領域は単純なコンテナである
      client = WSContainer.new(0, 0, sx - @border_width * 2, sy - @border_width * 2 - 16)
      client.resizable_width = client.resizable_height = true
      add_control(client, :client)

      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add window_title
        add client
      end

      # ↑ではWSWindow自身のlayoutを呼びたいので呼んだあとに特異メソッドを定義して上書きする
      # 外部からWSWindow#layoutしたときはクライアント領域のレイアウト設定になるように。
      def self.layout(type=nil, &b)
        self.client.layout(type, &b)
      end
    end

    def draw
      sx = self.image.width
      sy = self.image.height
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

    # マウスのボタンが押されたときに手前に持ってくる処理(ちょっとアレな手)
    def on_mouse_down_internal(tx, ty, button)
      self.parent.childlen.push(self.parent.childlen.delete(self))
      super
    end
  end
end
