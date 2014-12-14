# coding: utf-8
require_relative './common'

module WS
  class WSButtonBase < WSControl
    attr_accessor :caption, :fore_color
    
    def initialize(tx=nil, ty=nil, width=nil, height=nil, caption = "")
      super(tx, ty, width, height)
      @image = {}
      @caption = caption
      @fore_color = COLOR[:font]
      
      # 画像を作成する
      refresh
    end
    
    # キャプションの設定
    def caption=(text)
      refresh if @caption != text
      @caption = text
    end
    
    # コントロールの状態を判定しシンボルを返す
    def state
      @pushed ? :pushed : super
    end
    
    # オートレイアウトなどでサイズが変更されたときに呼ばれる
    def resize(width, height)
      super
      # 画像を作成する
      refresh
    end
    
    # set_imageで@image[true](押された絵)と@image[false](通常の絵)を設定する。
    # オーバーライドしてこのメソッドを再定義することでボタンの絵を変更することができる。
    def set_image
      # 画像を再作成する前にdisposeする
      @image.each_value{|image| image.dispose if image.disposed?}
      
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
      change_image
    end
    
    def change_image
      self.image = @image[state] || @image[:usual]
    end
    
    def draw
      super
      if self.image && self.activated?
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
  
  # 画像ボタン
  class WSImageButton < WSButton
    include HoverTextDisplayable
    
    def initialize(tx, ty, image, width = nil, height = nil, caption = "")
      width ||= image.width + 4
      height ||= image.height + 4
      @origin = image
      super(tx, ty, width, height, caption)
      self.hover_text = caption
    end
    
    # set_imageで@image[true](押された絵)と@image[false](通常の絵)を設定する。
    # オーバーライドしてこのメソッドを再定義することでボタンの絵を変更することができる。
    def set_image
      # 画像を再作成する前にdisposeする
      @image.each_value{|image| image.dispose if image.disposed?}
      
      # 通常時の画像を作成
      @image[:usual] = Image.new(@width, @height).draw((@width - @origin.width) / 2, (@height - @origin.height) / 2, @origin).draw_border(true)
      # 押下時の画像を作成
      @image[:pushed] = Image.new(@width, @height).draw((@width - @origin.width) / 2, (@height - @origin.height) / 2, @origin).draw_border(false)
      
      refreshed
    end
    
  end
  
  
  
  
  # スピンボタン
  class WSSpinButton < WSButtonBase
    include Focusable
    include RepeatClickable # リピートクリック用モジュール
  end
end
