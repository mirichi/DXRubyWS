# coding: utf-8
require_relative './label'

module WS
  class WSPanel < WSContainer
    C_WS_LINES = [120,120,120]
    C_WS_LINEH = [240,240,240]
    
    def initialize(sx, sy, width, height, caption="", border = true)
      super(sx + 12, sy + 20, width - 24, height - 32)
      @caption = caption
      @border  = border
    end
    
    # 描画
    def draw
      super
      # キャプションの描画
      if @caption.length > 0
        cw = @font.get_width(@caption) + 2
        cs = 2
        self.target.draw_font( self.x - 2 , self.y - 20, @caption, @font, :color=>C_BLACK)
      else
        cw = 0
        cs = 0
      end
      # ボーダーの描画
      if @border
        sx = self.x - 12 
        sy = self.y - 12
        ex = self.x + @width  + 12
        ey = self.y + @height + 12
        self.target.draw_line( sx,  sy, self.x - 4 - cs,  sy, C_WS_LINES)
        self.target.draw_line( sx,  sy + 1, self.x - 4 - cs,  sy + 1, C_WS_LINEH)
        self.target.draw_line( self.x - 4 + cw,  sy, ex,  sy, C_WS_LINES)
        self.target.draw_line( self.x - 4 + cw,  sy + 1, ex,  sy + 1, C_WS_LINEH)
        self.target.draw_line( sx,  sy,  sx, ey, C_WS_LINES)
        self.target.draw_line( sx + 1,  sy + 1,  sx + 1, ey, C_WS_LINEH)
        self.target.draw_line( sx,  ey - 1, ex,  ey - 1, C_WS_LINES)
        self.target.draw_line( sx,  ey, ex, ey, C_WS_LINEH)
        self.target.draw_line( ex - 1,  sy, ex - 1, ey, C_WS_LINES)
        self.target.draw_line( ex,  sy, ex,  ey, C_WS_LINEH)
      end
    end
    
  end
end