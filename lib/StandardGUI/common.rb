# coding: utf-8
module WS
  C_GRAY = [190, 190, 190]
  C_DARK_GRAY = [120,120,120]
  C_LIGHT_BLACK = [80,80,80]
  C_DARK_WHITE = [240,240,240]
  C_LIGHT_GRAY = [220,220,220]
  IMG_CACHE    = {}
    
  class WSContainer
    def render_border(flag)
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

  class WSLightContainer
    def draw_border(flag)
      sx = @width
      sy = @height
      if flag
        self.target.draw_line(basex,basey,basex+sx-1,basey,C_DARK_WHITE)
        self.target.draw_line(basex,basey,basex,basey+sy-1,C_DARK_WHITE)
        self.target.draw_line(basex+1,basey+1,basex+sx-1,basey+1,C_LIGHT_GRAY)
        self.target.draw_line(basex+1,basey+1,basex+1,basey+sy-1,C_LIGHT_GRAY)
        self.target.draw_line(basex+sx-1,basey,basex+sx-1,basey+sy-1,C_LIGHT_BLACK)
        self.target.draw_line(basex,basey+sy-1,basex+sx-1,basey+sy-1,C_LIGHT_BLACK)
        self.target.draw_line(basex+sx-2,basey+1,basex+sx-2,basey+sy-2,C_DARK_GRAY)
        self.target.draw_line(basex+1,basey+sy-2,basex+sx-2,basey+sy-2,C_DARK_GRAY)
      else
        self.target.draw_line(basex,basey,basex+sx-1,basey,C_LIGHT_BLACK)
        self.target.draw_line(basex,basey,basex,basey+sy-1,C_LIGHT_BLACK)
        self.target.draw_line(basex+1,basey+1,basex+sx-1,basey+1,C_DARK_GRAY)
        self.target.draw_line(basex+1,basey+1,basex+1,basey+sy-1,C_DARK_GRAY)
        self.target.draw_line(basex+sx-1,basey,basex+sx-1,basey+sy-1,C_DARK_WHITE)
        self.target.draw_line(basex,basey+sy-1,basex+sx-1,basey+sy-1,C_DARK_WHITE)
        self.target.draw_line(basex+sx-2,basey+1,basex+sx-2,basey+sy-2,C_LIGHT_GRAY)
        self.target.draw_line(basex+1,basey+sy-2,basex+sx-2,basey+sy-2,C_LIGHT_GRAY)
      end
    end
  end
end

class Image
  def draw_border(flag)
    if flag
      self.line(0,0,width-1,0,WS::C_DARK_WHITE)
      self.line(0,0,0,height-1,WS::C_DARK_WHITE)
      self.line(1,1,width-1,1,WS::C_LIGHT_GRAY)
      self.line(1,1,1,height-1,WS::C_LIGHT_GRAY)
      self.line(width-1,0,width-1,height-1,WS::C_LIGHT_BLACK)
      self.line(0,height-1,width-1,height-1,WS::C_LIGHT_BLACK)
      self.line(width-2,1,width-2,height-2,WS::C_DARK_GRAY)
      self.line(1,height-2,width-2,height-2,WS::C_DARK_GRAY)
    else
      self.line(0,0,width-1,0,WS::C_LIGHT_BLACK)
      self.line(0,0,0,height-1,WS::C_LIGHT_BLACK)
      self.line(1,1,width-1,1,WS::C_DARK_GRAY)
      self.line(1,1,1,height-1,WS::C_DARK_GRAY)
      self.line(width-1,0,width-1,height-1,WS::C_LIGHT_GRAY)
      self.line(0,height-1,width-1,height-1,WS::C_LIGHT_GRAY)
      self.line(width-2,1,width-2,height-2,WS::C_DARK_WHITE)
      self.line(1,height-2,width-2,height-2,WS::C_DARK_WHITE)
    end
  end
end

#元々の文字列を、指定したfontで、max_width以下にギリギリ収まるように短くする
#flagにfalseを指定すると、文字列の末尾の方を返す。
class String
  def within(font, max_width, flag = true)
    str = ""
    self.size.times do |i|
      if flag
        return str if font.getWidth(str + self[i]) > max_width
        str += self[i]
      else
        return str if font.getWidth(self[self.size - i - 1] + str) > max_width
        str = self[self.size - i - 1] + str
      end
    end
    return self
  end
end
