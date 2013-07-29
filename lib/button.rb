require 'dxruby'
require_relative './module.rb'

module WS
  class WSButton < WSControl
    attr_accessor :caption, :fore_color
    include ButtonClickable

    def initialize(tx, ty, sx, sy, caption = "Button")
      super(tx, ty)
      @image = {}
      @image[false] = Image.new(sx, sy, [160,160,160])
                     .line(0,0,sx-1,0,[240,240,240])
                     .line(0,0,0,sy-1,[240,240,240])
                     .line(1,1,sx-1,1,[200,200,200])
                     .line(1,1,1,sy-1,[200,200,200])
                     .line(sx-1,0,sx-1,sy-1,[80,80,80])
                     .line(0,sy-1,sx-1,sy-1,[80,80,80])
                     .line(sx-2,1,sx-2,sy-2,[120,120,120])
                     .line(1,sy-2,sx-2,sy-2,[120,120,120])
      @image[true] = Image.new(sx, sy, [160,160,160])
                     .line(0,0,sx-1,0,[80,80,80])
                     .line(0,0,0,sy-1,[80,80,80])
                     .line(1,1,sx-1,1,[120,120,120])
                     .line(1,1,1,sy-1,[120,120,120])
                     .line(sx-1,0,sx-1,sy-1,[200,200,200])
                     .line(0,sy-1,sx-1,sy-1,[200,200,200])
                     .line(sx-2,1,sx-2,sy-2,[240,240,240])
                     .line(1,sy-2,sx-2,sy-2,[240,240,240])
      @image_flag = false
      @caption = caption
    end

    def mouse_down(tx, ty, button)
      @image_flag = true
      super
    end

    def mouse_up(tx, ty, button)
      @image_flag = false
      super
    end

    def mouse_move(tx, ty)
      @cursor.x, @cursor.y = tx + self.x, ty + self.y
      @image_flag = (@button_flag and @cursor === self)
      super
    end

    def draw
      self.image = @image[@image_flag]
      super
      width = @font.get_width(@caption)
      self.target.draw_font(self.image.width / 2 - width / 2 + self.x - 1 + (@image_flag ? 1 : 0),
                            self.image.height / 2 - @font.size / 2 + self.y - 1 + (@image_flag ? 1 : 0),
                            @caption, @font, :color=>@fore_color)
    end
  end
end
