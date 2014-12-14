# coding: utf-8

module WS
  class WSCheckBox < WSControl
    
    # 公開インスタンス
    attr_accessor :fore_color
    attr_reader :caption, :checked
    
    # Mix-In
    include Focusable
    
    def initialize(tx, ty, width, caption = "")
      super(tx, ty, width, 22)
      @image = {}
      @checked = false
      self.caption = caption
      @fore_color = COLOR[:font]
      # 画像を作成する
      set_image
    end
    
    # コントロールの値を参照
    def value
      @checked
    end
    
    # コントロールに値を設定
    def value=(v)
      self.checked = v
    end
    
    def checked=(v)
      @checked = v
      refresh
    end
    
    # 画像をセット
    def set_image
      unless @image.has_key?(true)
        @image[false] = image_checkbox_false
        @image[true]  = image_checkbox_true
      end
      # 画像の張りなおし
      self.image.dispose if self.image
      self.image = Image.new(self.width, self.height)
      render_checkbox
    end
    
    ### チェックボックス画像(true) ###
    def image_checkbox_true
      unless IMG_CACHE[:checkbox_true]
        sx = 1
        sy = 1
        ex = 14
        ey = 14
        IMG_CACHE[:checkbox_true] = Image.new(16, 16)
        .line(sx, sy, sx, ey, COLOR[:darkshadow])
        .line(sx, sy+1 , ex, sy+1 , COLOR[:darkshadow])
        .line(sx, sy , ex, sy, COLOR[:darkshadow])
        .line(sx+1, sy ,sx+1, ey, COLOR[:darkshadow])
        .line(sx+1,ey-1,ex-1,ey-1, COLOR[:shadow])
        .line(sx, ey, ex, ey, COLOR[:highlight])
        .line(ex-1, sy+1, ex-1, ey-1, COLOR[:base])
        .line(ex, sy, ex, ey, COLOR[:highlight])
        .box_fill(sx+2, sy+2, ex-2, ey-2, COLOR[:background])
        .line(sx+3, ey-5, sx+5, ey-3, COLOR[:marker])
        .line(sx+3, ey-6, sx+5, ey-4, COLOR[:marker])
        .line(sx+3, ey-7, sx+5, ey-5, COLOR[:marker])
        .line(sx+3, ey-8, sx+5, ey-6, COLOR[:marker])
        .line(sx+6, ey-4, ex-3, ey-8, COLOR[:marker])
        .line(sx+6, ey-5, ex-3, ey-9, COLOR[:marker])
        .line(sx+6, ey-6, ex-3, ey-10, COLOR[:marker])
        .line(sx+6, ey-7, ex-3, ey-11, COLOR[:marker])
      end
      IMG_CACHE[:checkbox_true]
    end
    
    ### チェックボックス画像(false) ###
    def image_checkbox_false
      unless IMG_CACHE[:checkbox_false]
        sx = 1
        sy = 1
        ex = 14
        ey = 14
        IMG_CACHE[:checkbox_false] = Image.new(16, 16)
        .line(sx, sy, sx, ey, COLOR[:darkshadow])
        .line(sx, sy+1 , ex, sy+1 , COLOR[:darkshadow])
        .line(sx, sy , ex, sy, COLOR[:darkshadow])
        .line(sx+1, sy ,sx+1, ey, COLOR[:darkshadow])
        .line(sx+1,ey-1,ex-1,ey-1, COLOR[:shadow])
        .line(sx, ey, ex, ey, COLOR[:highlight])
        .line(ex-1, sy+1, ex-1, ey-1, COLOR[:base])
        .line(ex, sy, ex, ey, COLOR[:highlight])
        .box_fill(sx+2, sy+2, ex-2, ey-2, COLOR[:background])
      end
      IMG_CACHE[:checkbox_false]
    end
    
    ### イベント ###
    # クリックされた場合真偽値を入れ替える
    def on_mouse_push(tx, ty)
      self.checked = !@checked
      signal(:change, @checked)
      super
    end
    
    def on_key_push(key)
      if key == K_SPACE
        self.checked = !@checked
        signal(:change, @checked)
      end
      super
    end
    
    ### caption設定 ###
    def caption=(c)
      @caption = c
      self.resize(@font.get_width(c) + 20, 22)
    end
    
    def resize(width, height)
      super(width, height)
      set_image
    end
    
    ### 描画 ###
    def render_checkbox
      # コントロールの状態を参照して画像を変更
      self.image.clear
      self.image.draw(0, self.height / 2 - 7, @image[@checked])
      # キャプションを描画
      if @caption.length > 0
        width = @font.get_width(@caption)
        ty = self.height / 2 - @font.size / 2 + 1
        self.image.draw_font_ex(20 , ty, @caption, @font, {:aa =>false, :color=>@fore_color})
      end
      refreshed
    end
    
    def render
      render_checkbox if refresh?
      super
    end
    
    def draw
      super
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
