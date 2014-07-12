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
    
    # コントロールの状態を判定しシンボルを返す
    def state
      if @pushed
        :pushed
      else  
        super
      end
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
      if @image.has_key?(:usual)
        @image[:usual].dispose
        @image[:pushed].dispose
      end
      
      # 通常時の画像を作成
      @image[:usual] = Image.new(@width, @height, COLOR[:base]).draw_border(true)
      # 押下時の画像を作成
      @image[:pushed] = Image.new(@width, @height, COLOR[:base]).draw_border(false)
      # キャプションの描画
      if @caption.length > 0
        width = @font.get_width(@caption)
        @image[:usual].draw_font_ex(@width / 2 - width / 2 ,
                             @height / 2 - @font.size / 2 ,
                             @caption, @font, {:color => @fore_color, :aa => false})
      
        @image[:pushed].draw_font_ex(@width / 2 - width / 2 + 1,
                             @height / 2 - @font.size / 2 + 1,
                             @caption, @font, {:color => @fore_color, :aa => false})
      end
      refreshed
    end

    def render
      set_image if refresh?
      self.image = @image[state]
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
        @pushed = true
      end
    end

    def on_key_release(key)
      if key == K_SPACE
        @pushed = false
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
