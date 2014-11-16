# coding: utf-8

module WS
  
  ### ■ラジオボタン■###
  class WSRadioButton < WSControl
    
    # 公開インスタンス
    attr_accessor :fore_color, :margin

    # Mix-In
    include Focusable
    include ButtonClickable
    
    # 初期化
    # listにはラジオボタンの見出しを入れた配列を入れる(要素はString)
    def initialize(cx, cy, width, items=[], margin = 32)
      ch = [(@@default_font.size + margin) * items.size, 24].max
      super(cx, cy, width, ch)
      @items = items
      @index = 0
      @margin = margin
      @fore_color = COLOR[:font]
      @image = {}

      # キーボードイベント
      add_key_handler(K_UP) do
        @index -= 1 if @index > 0
        refresh
      end
      add_key_handler(K_LEFT) do
        @index -= 1 if @index > 0
        refresh
      end

      add_key_handler(K_DOWN) do
        @index += 1 if @index < @items.size - 1
        refresh
      end
      add_key_handler(K_RIGHT) do
        @index += 1 if @index < @items.size - 1
        refresh
      end

      # 画像を作成する
      set_image
    end

    # コントロールの値を参照
    def value
      @index
    end
    
    # コントロールに値を設定
    def value=(v)
      @index = v
      refresh
    end
        
    # ラジオボタンの画像を作成
    def set_image
      unless @image.has_key?(true)
        @image[false] = image_radiobutton_false
        @image[true]  = image_radiobutton_true
      end
            
      self.image.dispose if self.image
      self.image = Image.new(self.width, self.height)
      
      refresh
    end

    ### ラジオボタン画像(true) ###
    def image_radiobutton_true
      unless IMG_CACHE[:radiobutton_true]
        sx,sy,ex,ey = 2,2,13,13
        IMG_CACHE[:radiobutton_true] = IMG_CACHE[:radiobutton_false].dup
        IMG_CACHE[:radiobutton_true].box_fill(sx+5, sy+4, ex-5, ey-4, COLOR[:marker])
                                    .box_fill(sx+4, sy+5, ex-4, ey-5, COLOR[:marker])
      end
      IMG_CACHE[:radiobutton_true]
    end
        
    ### ラジオボタン画像(false) ###
    def image_radiobutton_false
      unless IMG_CACHE[:radiobutton_false]
        sx,sy,ex,ey = 2,2,13,13
        IMG_CACHE[:radiobutton_false] = Image.new(16, 16)
                             .box_fill(sx+2, sy+2, ex-2, ey-2, COLOR[:background])
                             .line(sx+4, sy, ex-4, sy, COLOR[:shadow])
                             .line(sx+2, sy+1, sx+3, sy+1, COLOR[:shadow])
                             .line(ex-3, sy+1, ex-2, sy+1, COLOR[:shadow])
                             .line(sx, sy+4, sx, ey-4, COLOR[:shadow])
                             .line(sx+1, sy+2, sx+1, sy+3, COLOR[:shadow])
                             .line(sx+1, ey-3, sx+1, ey-2, COLOR[:shadow])
                             .line(sx+4, sy+1, ex-4, sy+1, COLOR[:darkshadow])
                             .line(sx+2, sy+2, sx+3, sy+2, COLOR[:darkshadow])
                             .line(ex-3, sy+2, ex-2, sy+2, COLOR[:darkshadow])
                             .line(sx+1, sy+4, sx+1, ey-4, COLOR[:darkshadow])
                             .line(sx+2, sy+2, sx+2, sy+3, COLOR[:darkshadow])
                             .line(sx+2, ey-3, sx+2, ey-2, COLOR[:darkshadow])
                             .line(sx+4, ey, ex-4, ey, COLOR[:highlight])
                             .line(sx+2, ey-1, sx+3, ey-1, COLOR[:highlight])
                             .line(ex-3, ey-1, ex-2, ey-1, COLOR[:highlight])
                             .line(ex, sy+4, ex, ey-4, COLOR[:highlight])
                             .line(ex-1, sy+2, ex-1, sy+3, COLOR[:highlight])
                             .line(ex-1, ey-3, ex-1, ey-2, COLOR[:highlight])
                             .line(sx+4, ey-1, ex-4, ey-1,COLOR[:base])
                             .line(sx+2, ey-2, sx+3, ey-2, COLOR[:base])
                             .line(ex-3, ey-2, ex-2, ey-2, COLOR[:base])
                             .line(ex-1, sy+4, ex-1, ey-4, COLOR[:base])
                             .line(ex-2, sy+3, ex-2, sy+3, COLOR[:base])
                             .line(ex-2, ey-3, ex-2, ey-2, COLOR[:base])
      end
      IMG_CACHE[:radiobutton_false]
    end
    
    ### イベント ###
    # クリックされた場合真偽値を入れ替える
    def on_mouse_push(tx, ty)
      th = @font.size + @margin
      mr = (th - font.size) / 2
      if !@items.empty? && ty % th >= mr && ty % th <= th - mr
        @index = ty / th
        signal(:change, @index)
        refresh
      end
      
      super
      
    end
    
    ### 描画 ###
    def render_radio_button
      @items.each_index do |i|
        th = (@font.size + @margin)
        cy = th * i + th / 2 - 16 / 2
        ty = th * i + th / 2 - @font.size / 2 + 1
        self.image.draw(0, ty, @image[i == @index])
        self.image.draw_font_ex(20, ty, @items[i], @font, {:aa => false, :color => @fore_color})
      end
      refreshed
    end
    
    def render
      render_radio_button if refresh?
      super
    end
    
  end
end