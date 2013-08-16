require_relative './module.rb'

module WS
  # ウィンドウぽい動きを実現してみる
  class WSWindow < WSContainer
    attr_accessor :border_width # ウィンドウボーダーの幅
    include Resizable

    def initialize(tx, ty, sx, sy, caption = "WindowTitle")
      super(tx, ty, sx, sy)
      self.image.bgcolor = [160,160,160]
      @border_width = 2
      @client = WSContainer.new(@border_width, @border_width + 16, sx - @border_width * 2, sy - @border_width * 2 - 16)
      add_control(@client, :client)

      # ウィンドウタイトルはそれでひとつのコントロールを作る
      # メニューやツールバー、ステータスバーもたぶんそうなる
      @window_title = WSWindowTitle.new(@border_width, @border_width, sx - @border_width * 2, 16, caption)
      add_control(@window_title)
      @window_title.add_handler(:close) {self.parent.remove_control(self)}
      @window_title.add_handler(:drag_move, self, :on_move)

#      add_handler(:resize_move, self, :on_resize)

      # タイトルバーのダブルクリックで最大化する
      @maximize_flag = false
      @window_title.add_handler(:doubleclick, self, :on_maximize)
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

    def resize(x1, y1, width, height)
      self.image.resize(width, height)
      @window_title.resize(@border_width, @border_width, width - @border_width * 2, 16)
      @client.image.resize(width - @border_width * 2, height - @border_width * 2 - 16)
      self.collision = [0, 0, width - 1, height - 1]
      super
    end

    def on_move(obj, dx, dy)
      unless @maximize_flag
        self.x += dx
        self.y += dy
      end
    end

    def on_maximize(obj)
      if @maximize_flag
        # 最大化状態から戻す処理
        resize(@origin_x, @origin_y, @origin_width, @origin_height)
        @maximize_flag = false
      else
        # 最大化する処理
        @origin_x = self.x
        @origin_y = self.y
        @origin_width = self.image.width
        @origin_height = self.image.height
        resize(0 - @border_width, 0 - @border_width, self.target.width + @border_width * 2, self.target.height + @border_width * 2)
        @maximize_flag = true
      end
    end

    # マウスのボタンが押されたときに手前に持ってくる処理(ちょっとアレな手)
    def on_mouse_down_internal(tx, ty, button)
      self.parent.childlen.push(self.parent.childlen.delete(self))
      super
    end
  end

  # ウィンドウのタイトルバー用クラス
  class WSWindowTitle < WSContainer
    include Draggable       # ウィンドウのドラッグ用
    include DoubleClickable # 最大化用

    def initialize(tx, ty, sx, sy, title="Title")
      super(tx, ty, sx, sy)
      self.image.bgcolor = C_BLUE

      # タイトルバーのクロースボタン
      @close_button = WSButton.new(sx-16, 1, sy-2, sy-2, "X")
      @close_button.fore_color = C_BLACK
      add_control(@close_button)
      @close_button.add_handler(:click) {signal(:close)}

      # ウィンドウタイトル
      @label = WSLabel.new(2, 0, sx, sy, title)
      add_control(@label)
    end

    def resize(x1, y1, width, height)
      self.image.resize(width, height)
      @close_button.x = width - 16
      self.collision = [0, 0, width - 1, height - 1]
      super
    end
  end
end
