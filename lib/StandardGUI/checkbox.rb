# coding: utf-8

module WS
  class WSCheckBox < WSControl
    
    # 定数
    C_CBBASE  = [255,255,255]
    C_CBLINES = [80,80,80]
    C_CBLINEM = [160,160,160]
    C_CBLINEH = [240,240,240]
    C_CHECK   = [  0,  0,  0]
    
    # 公開インスタンス
    attr_accessor :fore_color, :checked
    attr_reader :caption

    # Mix-In
    include Focusable
    
    def initialize(tx, ty, width, caption = "")
      super(tx, ty, width, @@default_font.size)
      @image       = {}
      @checked     = false
      self.caption = caption
      @fore_color  = C_BLACK
      # 画像を作成する
      set_image
    end
    
    # チェックボックスの画像を設定
    def set_image
      sx = 1
      sy = 1
      ex = 14
      ey = 14
      @image[false] = Image.new(16, 16)
                     .line(sx, sy, sx, ey, C_CBLINES)
                     .line(sx, sy+1 , ex, sy+1 , C_CBLINES)
                     .line(sx, sy , ex, sy, C_CBLINES)
                     .line(sx+1, sy ,sx+1, ey, C_CBLINES)
                     .line(sx+1,ey-1,ex-1,ey-1, C_CBLINEM)
                     .line(sx, ey, ex, ey, C_CBLINEH)
                     .line(ex-1, sy+1, ex-1, ey-1, C_CBLINEM)
                     .line(ex, sy, ex, ey, C_CBLINEH)
                     .box_fill(sx+2, sy+2, ex-2, ey-2, C_CBBASE)
                     
      @image[true] = Image.new(16, 16)
                     .line(sx, sy, sx, ey, C_CBLINES)
                     .line(sx, sy+1 , ex, sy+1 , C_CBLINES)
                     .line(sx, sy , ex, sy, C_CBLINES)
                     .line(sx+1, sy ,sx+1, ey, C_CBLINES)
                     .line(sx+1,ey-1,ex-1,ey-1, C_CBLINEM)
                     .line(sx, ey, ex, ey, C_CBLINEH)
                     .line(ex-1, sy+1, ex-1, ey-1, C_CBLINEM)
                     .line(ex, sy, ex, ey, C_CBLINEH)
                     .box_fill(sx+2, sy+2, ex-2, ey-2, C_CBBASE)
                     .line(sx+3, ey-5, sx+5, ey-3, C_CHECK)
                     .line(sx+3, ey-6, sx+5, ey-4, C_CHECK)
                     .line(sx+3, ey-7, sx+5, ey-5, C_CHECK)
                     .line(sx+3, ey-8, sx+5, ey-6, C_CHECK)
                     .line(sx+6, ey-4, ex-3, ey-8, C_CHECK)
                     .line(sx+6, ey-5, ex-3, ey-9, C_CHECK)
                     .line(sx+6, ey-6, ex-3, ey-10, C_CHECK)
                     .line(sx+6, ey-7, ex-3, ey-11, C_CHECK)
    end
    
    ### イベント ###
    # クリックされた場合真偽値を入れ替える
    def on_mouse_push(tx, ty)
      @checked = !@checked
      signal(:changed, @checked)
      super
    end 

    def on_key_push(key)
      if key == K_SPACE
        @checked = !@checked
        signal(:changed, @checked)
      end
      super
    end

    ### caption設定 ###
    def caption=(c)
      @caption = c
      self.resize(@font.get_width(c) + 16, @font.size)
    end

    ### 描画 ###    
    def draw
      # コントロールの状態を参照して画像を変更
      self.image = @image[@checked]
      super
      # キャプションを描画
      if @caption.length > 0
        width = @font.get_width(@caption)
        self.target.draw_font(self.x + 20 , self.y , @caption, @font, :color=>@fore_color)
      end
      if self.activated?
        tmp = @font.get_width(@caption)
        self.target.draw_line(self.x + 18, self.y - 2, self.x + tmp + 20, self.y - 2, C_BLACK)
        self.target.draw_line(self.x + 18, self.y - 2, self.x + 18, self.y + @font.size + 2, C_BLACK)
        self.target.draw_line(self.x + tmp + 20, self.y - 2, self.x + tmp + 20, self.y + @font.size + 2, C_BLACK)
        self.target.draw_line(self.x + 18, self.y + @font.size + 2, self.x + tmp + 20, self.y + @font.size + 2, C_BLACK)
      end
    end
  end
end
