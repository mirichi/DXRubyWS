# coding: utf-8

module WS
  class WSButton < WSControl
    attr_accessor :caption, :fore_color
    include ButtonClickable

    def initialize(tx, ty, width, height, caption = "Button")
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
      width = @font.get_width(@caption)
      self.target.draw_font(self.image.width / 2 - width / 2 + self.x - 1 + (@image_flag ? 1 : 0),
                            self.image.height / 2 - @font.size / 2 + self.y - 1 + (@image_flag ? 1 : 0),
                            @caption, @font, :color=>@fore_color)
    end
  end
end
