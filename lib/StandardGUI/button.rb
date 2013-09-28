# coding: utf-8
require_relative './common'

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
      @image[false] = Image.new(@width, @height, C_GRAY).draw_border(true)
      @image[true] = Image.new(@width, @height, C_GRAY).draw_border(false)
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
      if self.activated?
        self.target.draw_line(self.x - 1, self.y - 1, self.x + @width, self.y - 1, C_BLACK)
        self.target.draw_line(self.x - 1, self.y - 1, self.x - 1, self.y + @height, C_BLACK)
        self.target.draw_line(self.x + @width, self.y - 1, self.x + @width, self.y + @height, C_BLACK)
        self.target.draw_line(self.x - 1, self.y + @height, self.x + @width, self.y + @height, C_BLACK)
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
        on_click(0, 0)
      end
    end
  end
end
