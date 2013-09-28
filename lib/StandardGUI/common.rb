module WS
  C_GRAY = [190, 190, 190]

  class WSContainer
    def draw_border(flag)
      sx = @width
      sy = @height
      if flag
        self.image.draw_line(0,0,sx-1,0,[240,240,240])
        self.image.draw_line(0,0,0,sy-1,[240,240,240])
        self.image.draw_line(1,1,sx-1,1,[220,220,220])
        self.image.draw_line(1,1,1,sy-1,[220,220,220])
        self.image.draw_line(sx-1,0,sx-1,sy-1,[80,80,80])
        self.image.draw_line(0,sy-1,sx-1,sy-1,[80,80,80])
        self.image.draw_line(sx-2,1,sx-2,sy-2,[120,120,120])
        self.image.draw_line(1,sy-2,sx-2,sy-2,[120,120,120])
      else
        self.image.draw_line(0,0,sx-1,0,[80,80,80])
        self.image.draw_line(0,0,0,sy-1,[80,80,80])
        self.image.draw_line(1,1,sx-1,1,[120,120,120])
        self.image.draw_line(1,1,1,sy-1,[120,120,120])
        self.image.draw_line(sx-1,0,sx-1,sy-1,[240,240,240])
        self.image.draw_line(0,sy-1,sx-1,sy-1,[240,240,240])
        self.image.draw_line(sx-2,1,sx-2,sy-2,[220,220,220])
        self.image.draw_line(1,sy-2,sx-2,sy-2,[220,220,220])
      end
    end
  end
end
