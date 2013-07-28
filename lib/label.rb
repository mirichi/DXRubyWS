module WS

  class WSLabel < WSControl
    attr_accessor :caption

    def initialize(tx, ty, sx, sy, caption = "Label")
      super(tx, ty)
      @sx, @sy = sx, sy
      self.collision = [0,0,@sx-1,@sy-1]
      @caption = caption
    end

    def draw
      width = @font.get_width(@caption)
      self.target.draw_font(self.x,
                            @sy / 2 - @font.size / 2 + self.y - 1,
                            @caption, @font)
    end
  end
end
