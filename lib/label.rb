module WS
  class WSLabel < WSControl
    attr_accessor :caption, :fore_color
    def initialize(tx, ty, width, height, caption = "Label")
      super(tx, ty, width, height)
      self.collision_enable = false
      @caption = caption
      @fore_color = C_BLACK
    end

    def draw
      width = @font.get_width(@caption)
      self.target.draw_font(self.x,
                            self.height / 2 - @font.size / 2 + self.y - 1,
                            @caption, @font, :color=>@fore_color)
    end
  end
end
