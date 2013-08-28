# coding: utf-8

module WS
  # スクロールバークラス
  class WSScrollBar < WSContainer
    # スクロールバーのスライダークラス
    class WSScrollBarSlider < WSControl
      include Draggable

      def initialize(tx, ty, width, height)
        super
        add_handler(:drag_move) do |obj, dx, dy|
          self.y = (self.y + dy).clamp(16, @parent.height - 16 - @height)
          signal(:slide, self.y)
        end
      end

      def draw
        # スライダーの高さが変更された場合に画像を再生成する
        if @old_height != @height
          self.image.dispose if self.image
          self.image = Image.new(@width, @height, [190,190,190])
                            .line(0,0,@width-1,0,[240,240,240])
                            .line(0,0,0,@height-1,[240,240,240])
                            .line(1,1,@width-1,1,[200,200,200])
                            .line(1,1,1,@height-1,[200,200,200])
                            .line(@width-1,0,@width-1,@height-1,[80,80,80])
                            .line(0,@height-1,@width-1,@height-1,[80,80,80])
                            .line(@width-2,1,@width-2,@height-2,[120,120,120])
                            .line(1,@height-2,@width-2,@height-2,[120,120,120])
          self.collision = [0, 0, @width-1, @height-1]
        end
        @old_height = @height
        super
      end
    end

    # 押しっぱなしでリピートするボタンクラス
    class WSRepeatButton < WSControl
      attr_accessor :caption, :fore_color
      include RepeatClickable # リピートクリック用モジュール
                              # 普通のボタンと違うのはここだけ。コードが無駄なのでなんとかならんかな。
  
      def initialize(tx, ty, width, height, caption = "Button")
        super(tx, ty, width, height)
        @image = {}
        @image[false] = Image.new(width, height, [190,190,190])
                       .line(0,0,width-1,0,[240,240,240])
                       .line(0,0,0,height-1,[240,240,240])
                       .line(1,1,width-1,1,[200,200,200])
                       .line(1,1,1,height-1,[200,200,200])
                       .line(width-1,0,width-1,height-1,[80,80,80])
                       .line(0,height-1,width-1,height-1,[80,80,80])
                       .line(width-2,1,width-2,height-2,[120,120,120])
                       .line(1,height-2,width-2,height-2,[120,120,120])
        @image[true] = Image.new(width, height, [190,190,190])
                       .line(0,0,width-1,0,[80,80,80])
                       .line(0,0,0,height-1,[80,80,80])
                       .line(1,1,width-1,1,[120,120,120])
                       .line(1,1,1,height-1,[120,120,120])
                       .line(width-1,0,width-1,height-1,[200,200,200])
                       .line(0,height-1,width-1,height-1,[200,200,200])
                       .line(width-2,1,width-2,height-2,[240,240,240])
                       .line(1,height-2,width-2,height-2,[240,240,240])
        @image_flag = false
        @caption = caption
      end

      def on_mouse_push(tx, ty)
        @image_flag = true
        super
      end
  
      def on_mouse_release(tx, ty)
        @image_flag = false
        super
      end
  
      def on_mouse_move(tx, ty)
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        @image_flag = (WS.captured?(self) and @hit_cursor === self)
        super
      end
  
      def draw
        self.image = @image[@image_flag]
        super
        width = @font.get_width(@caption)
        self.target.draw_font(self.image.width / 2 - width / 2 + self.x + (@image_flag ? 1 : 0),
                              self.image.height / 2 - @font.size / 2 + self.y + (@image_flag ? 1 : 0),
                              @caption, @font, :color=>@fore_color)
      end
    end
  
    attr_accessor :screen_length, :total, :unit_quantity, :position
    include RepeatClickable

    def initialize(tx, ty, width, height)
      super
      self.image.bgcolor = [220, 220, 220]
      font = Font.new(12)
      @position = 0

      slider = WSScrollBarSlider.new(0, 16, width, 16)
      slider.add_handler(:slide) do |obj, ty|
        @position = (@total - @screen_length) * ((ty - 16).quo(@height - 32 - slider.height))
        signal(:slide, @position)
      end
      add_control(slider, :slider)

      ub = WSRepeatButton.new(0, 0, width, 16, "▲")
      ub.fore_color = C_BLACK
      ub.font = font
      add_control(ub, :btn_up)
      ub.add_handler(:click) do
        @position = @position - @unit_quantity
        @position = 0 if @position < 0
        signal(:slide, @position)
      end

      db = WSRepeatButton.new(0, 0, width, 16, "▼")
      db.fore_color = C_BLACK
      db.font = font
      add_control(db, :btn_down)
      db.add_handler(:click) do
        max = @total - @screen_length
        @position += @unit_quantity
        @position = max if @position > max
        signal(:slide, @position)
      end

      layout(:vbox) do
        add ub
        layout
        add db
      end
    end

    def resize(width, height)
      super
      @position = @position.clamp(0, (@total - @screen_length < 0 ? 0 : @total - @screen_length))
      signal(:slide, @position)
    end

    # 描画時にスライダーのサイズを再計算する
    def draw
      if self.visible # DXRubyのバグ回避
        self.slider.height = (@total > 0 ? @screen_length / @total * (@height - 32) : 0)
        self.slider.height = self.slider.height.clamp(8, @height - 32)
        self.slider.y = (@height - 32 - slider.height) * (@position / (@total - @screen_length)) + 16
      end
      super
    end

    def slide(dy)
      @position += dy
      @position = @position.clamp(0, (@total - @screen_length < 0 ? 0 : @total - @screen_length))
      signal(:slide, @position)
    end

    def on_click(obj, tx, ty)
      if ty < self.slider.y
        @position -= @screen_length
        @position = 0 if @position < 0
        signal(:slide, @position)
      elsif ty >= self.slider.y + self.slider.height
        max = @total - @screen_length
        @position += @screen_length
        @position = max if @position > max
        signal(:slide, @position)
      end
    end
  end
end
