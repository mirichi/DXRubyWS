module WS
  C_GRAY = [190, 190, 190]
  C_DARK_GRAY = [120,120,120]
  C_LIGHT_BLACK = [80,80,80]
  C_DARK_WHITE = [240,240,240]
  C_LIGHT_GRAY = [220,220,220]

  class WSContainer
    def draw_border(flag)
      sx = @width
      sy = @height
      if flag
        self.image.draw_line(0,0,sx-1,0,C_DARK_WHITE)
        self.image.draw_line(0,0,0,sy-1,C_DARK_WHITE)
        self.image.draw_line(1,1,sx-1,1,C_LIGHT_GRAY)
        self.image.draw_line(1,1,1,sy-1,C_LIGHT_GRAY)
        self.image.draw_line(sx-1,0,sx-1,sy-1,C_LIGHT_BLACK)
        self.image.draw_line(0,sy-1,sx-1,sy-1,C_LIGHT_BLACK)
        self.image.draw_line(sx-2,1,sx-2,sy-2,C_DARK_GRAY)
        self.image.draw_line(1,sy-2,sx-2,sy-2,C_DARK_GRAY)
      else
        self.image.draw_line(0,0,sx-1,0,C_LIGHT_BLACK)
        self.image.draw_line(0,0,0,sy-1,C_LIGHT_BLACK)
        self.image.draw_line(1,1,sx-1,1,C_DARK_GRAY)
        self.image.draw_line(1,1,1,sy-1,C_DARK_GRAY)
        self.image.draw_line(sx-1,0,sx-1,sy-1,C_DARK_WHITE)
        self.image.draw_line(0,sy-1,sx-1,sy-1,C_DARK_WHITE)
        self.image.draw_line(sx-2,1,sx-2,sy-2,C_LIGHT_GRAY)
        self.image.draw_line(1,sy-2,sx-2,sy-2,C_LIGHT_GRAY)
      end
    end
  end
end

class Image
  def draw_border(flag)
    if flag
      self.line(0,0,width-1,0,WS::C_DARK_WHITE)
          .line(0,0,0,height-1,WS::C_DARK_WHITE)
          .line(1,1,width-1,1,WS::C_LIGHT_GRAY)
          .line(1,1,1,height-1,WS::C_LIGHT_GRAY)
          .line(width-1,0,width-1,height-1,WS::C_LIGHT_BLACK)
          .line(0,height-1,width-1,height-1,WS::C_LIGHT_BLACK)
          .line(width-2,1,width-2,height-2,WS::C_DARK_GRAY)
          .line(1,height-2,width-2,height-2,WS::C_DARK_GRAY)
    else
      self.line(0,0,width-1,0,WS::C_LIGHT_BLACK)
          .line(0,0,0,height-1,WS::C_LIGHT_BLACK)
          .line(1,1,width-1,1,WS::C_DARK_GRAY)
          .line(1,1,1,height-1,WS::C_DARK_GRAY)
          .line(width-1,0,width-1,height-1,WS::C_LIGHT_GRAY)
          .line(0,height-1,width-1,height-1,WS::C_LIGHT_GRAY)
          .line(width-2,1,width-2,height-2,WS::C_DARK_WHITE)
          .line(1,height-2,width-2,height-2,WS::C_DARK_WHITE)
    end
  end
end
