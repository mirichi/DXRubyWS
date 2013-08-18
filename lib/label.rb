module WS
  class WSLabel < WSControl
    attr_accessor :caption
    def initialize(tx, ty, width, height, caption = "Label")
      super(tx, ty, width, height)
#      self.image = Image.new(width, height)
      self.collision_enable = false
      @caption = caption
    end

    def draw
      width = @font.get_width(@caption)
      self.target.draw_font(self.x,
                            self.height / 2 - @font.size / 2 + self.y - 1,
                            @caption, @font)
    end
  end
end
