module WS

  class WSWindow < WSContainer
    def initialize(tx, ty, sx, sy)
      super(tx, ty, sx, sy)
      self.image.bgcolor = [160,160,160]
      @window_title = WSWindowTitle.new(2,2,sx-4,16)
      add_control(@window_title)
      @window_title.add_handler(:close, self, :close)
    end

    # RenderTarget#draw_line‚ÍŒ»ÝƒoƒO‚Á‚Ä‚¢‚é‚Ì‚ÅãY—í‚ÉŒ©‚¦‚È‚¢B
    def draw
      sx = self.image.width
      sy = self.image.height
      self.image.draw_line(0,0,sx-1,0,[240,240,240])
      self.image.draw_line(0,0,0,sy-1,[240,240,240])
      self.image.draw_line(1,1,sx-1,1,[200,200,200])
      self.image.draw_line(1,1,1,sy-1,[200,200,200])
      self.image.draw_line(sx-1,0,sx-1,sy-1,[80,80,80])
      self.image.draw_line(0,sy-1,sx-1,sy-1,[80,80,80])
      self.image.draw_line(sx-2,1,sx-2,sy-2,[120,120,120])
      self.image.draw_line(1,sy-2,sx-2,sy-2,[120,120,120])
      super
    end

    def close
      self.parent.remove_control(self)
    end
  end

  class WSWindowTitle < WSContainer
    def initialize(tx, ty, sx, sy, title="Title")
      super(tx, ty, sx, sy)
      self.image.bgcolor = C_BLUE

      @button = WSButton.new(sx-16, 1, sy-2, sy-2, "X")
      @button.fore_color = C_BLACK
      add_control(@button)
      @button.add_handler(:click, self, :click)

      @label = WSLabel.new(2, 2, sx, sy, title)
      add_control(@label)
    end

    def click
      signal(:close)
    end
  end
end
