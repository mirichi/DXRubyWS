# coding: utf-8

module WS
  class WSPanel < WSLightContainer

    def initialize(sx, sy, width, height, caption="", border = true)
      super(sx + 12, sy + 20, width - 24, height - 32)
      @caption = caption
      @border  = border
    end
    
    def x=(v)
      super(v + 12)
    end
    
    def y=(v)
      super(v + 20)
    end

    def width
      super + 24
    end
    
    def height
      super + 32
    end
        
    def width=(v)
      super(v - 24)
    end
    
    def height=(v)
      super(v - 32)
    end
    
    def resize(width, height)
      super(width - 24, height - 32)
    end
    
    # 描画
    def draw
      super
      # キャプションの描画
      if @caption.length > 0
        cw = @font.get_width(@caption) + 2
        cs = 2
        self.target.draw_font( self.x - 2 , self.y - 20, @caption, @font, :color=>COLOR[:font])
      else
        cw = 0
        cs = 0
      end
      # ボーダーの描画
      if @border
        sx = self.x - 12
        sy = self.y - 12
        ex = self.x + @width + 12
        ey = self.y + @height + 12
        self.target.draw_line( sx, sy, self.x - 4 - cs, sy, COLOR[:darkshadow])
        self.target.draw_line( sx, sy + 1, self.x - 4 - cs, sy + 1, COLOR[:highlight])
        self.target.draw_line( self.x - 4 + cw, sy, ex, sy, COLOR[:darkshadow])
        self.target.draw_line( self.x - 4 + cw, sy + 1, ex, sy + 1, COLOR[:highlight])
        self.target.draw_line( sx, sy, sx, ey, COLOR[:darkshadow])
        self.target.draw_line( sx + 1, sy + 1, sx + 1, ey, COLOR[:highlight])
        self.target.draw_line( sx, ey - 1, ex, ey - 1, COLOR[:darkshadow])
        self.target.draw_line( sx, ey, ex, ey, COLOR[:highlight])
        self.target.draw_line( ex - 1, sy, ex - 1, ey, COLOR[:darkshadow])
        self.target.draw_line( ex, sy, ex, ey, COLOR[:highlight])
      end
    end
    
  end
end