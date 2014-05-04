# coding: utf-8
require_relative './common'

module WS
  class WSButtonBase < WSControl
    attr_accessor :caption, :fore_color

    def initialize(tx, ty, width, height, caption = "")
      super(tx, ty, width, height)
      @image = {}
      @caption = caption
      @fore_color = COLOR[:font]

      # 画像を作成する
      set_image
    end
    
    # キャプションの設定
    def caption=(text)
      refresh if @caption != text
      @caption = text
    end
    
    # オートレイアウトなどでサイズが変更されたときに呼ばれる
    def resize(width, height)
      super
      # 画像を作成する
      set_image
    end
     
    # set_imageで@image[true](押された絵)と@image[false](通常の絵)を設定する。
    # オーバーライドしてこのメソッドを再定義することでボタンの絵を変更することができる。
    def set_image
      # 画像を再作成する前にdisposeする
      if @image.has_key?(true)
        @image[false].dispose
        @image[true].dispose
      end
      
      # 通常時の画像を作成
      @image[false] = Image.new(@width, @height, COLOR[:base]).draw_border(true)
      # 押下時の画像を作成
      @image[true] = Image.new(@width, @height, COLOR[:base]).draw_border(false)
      # キャプションの描画
      if @caption.length > 0
        width = @font.get_width(@caption)
        @image[false].draw_font_ex(@width / 2 - width / 2 ,
                             @height / 2 - @font.size / 2 ,
                             @caption, @font, {:color => @fore_color, :aa => false})
      
        @image[true].draw_font_ex(@width / 2 - width / 2 + 1,
                             @height / 2 - @font.size / 2 + 1,
                             @caption, @font, {:color => @fore_color, :aa => false})
      end
      refreshed
    end

    def render
      set_image if refresh?
      self.image = @image[@image_flag]
    end

    def draw
      super
      return unless self.image
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

  # スピンボタン
  class WSSpinButton < WSButtonBase
      include Focusable
      include RepeatClickable # リピートクリック用モジュール
  end
end
