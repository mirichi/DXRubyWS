# coding: utf-8

module WS
  class WSButtonBase < WSControl
    attr_accessor :caption, :fore_color

    def initialize(tx, ty, width, height, caption = "")
      super(tx, ty, width, height)
      @image = {}
      @caption = caption
      @fore_color = C_BLACK

      # 画像を作成する
      set_image
    end

    # オートレイアウトなどでサイズが変更されたときに呼ばれる
    def resize(width, height)
      super

      # 画像を再作成する前にdisposeする
      if @image.has_key?(true)
        @image[false].dispose
        @image[true].dispose
      end

      # 画像を作成する
      set_image
    end

    # set_imageで@image[true](押された絵)と@image[false](通常の絵)を設定する。
    # オーバーライドしてこのメソッドを再定義することでボタンの絵を変更することができる。
    def set_image
      @image[false] = Image.new(@width, @height, [190,190,190])
                     .line(0,0,@width-1,0,[240,240,240])
                     .line(0,0,0,@height-1,[240,240,240])
                     .line(1,1,@width-1,1,[200,200,200])
                     .line(1,1,1,@height-1,[200,200,200])
                     .line(@width-1,0,@width-1,@height-1,[80,80,80])
                     .line(0,@height-1,@width-1,@height-1,[80,80,80])
                     .line(@width-2,1,@width-2,@height-2,[120,120,120])
                     .line(1,@height-2,@width-2,@height-2,[120,120,120])
      @image[true] = Image.new(@width, @height, [190,190,190])
                     .line(0,0,@width-1,0,[80,80,80])
                     .line(0,0,0,@height-1,[80,80,80])
                     .line(1,1,@width-1,1,[120,120,120])
                     .line(1,1,1,@height-1,[120,120,120])
                     .line(@width-1,0,@width-1,@height-1,[200,200,200])
                     .line(0,@height-1,@width-1,@height-1,[200,200,200])
                     .line(@width-2,1,@width-2,@height-2,[240,240,240])
                     .line(1,@height-2,@width-2,@height-2,[240,240,240])
    end

    def draw
      self.image = @image[@image_flag]
      super
      if @caption.length > 0
        width = @font.get_width(@caption)
        self.target.draw_font(self.image.width / 2 - width / 2 + self.x - 1 + (@image_flag ? 1 : 0),
                              self.image.height / 2 - @font.size / 2 + self.y - 1 + (@image_flag ? 1 : 0),
                              @caption, @font, :color=>@fore_color)
      end
      if @active
        self.target.draw_line(self.x - 1, self.y - 1, self.x + @width, self.y - 1, C_BLACK)
                   .draw_line(self.x - 1, self.y - 1, self.x - 1, self.y + @height, C_BLACK)
                   .draw_line(self.x + @width, self.y - 1, self.x + @width, self.y + @height, C_BLACK)
                   .draw_line(self.x - 1, self.y + @height, self.x + @width, self.y + @height, C_BLACK)
      end
    end
  end

  # 普通のボタン
  class WSButton < WSButtonBase
    include Focusable
    include ButtonClickable # 普通のクリック用モジュール

    def on_key_push(key)
      if key == K_SPACE
        @image_flag = true
      end
    end

    def on_key_release(key)
      if key == K_SPACE
        @image_flag = false
        on_click(self, 0, 0)
      end
    end
  end
end
