require 'dxruby'
require_relative './module.rb'

module WS
  class WSButton < WSControl
    attr_accessor :caption, :fore_color
    include ButtonClickable

    def initialize(tx, ty, width, height, caption = "Button")
      super(tx, ty, width, height)
      @image = {}
      @image_flag = false
      @caption = caption
      resize(tx, ty, width, height)
    end

    def on_mouse_down(tx, ty, button)
      @image_flag = true
      super
    end

    def on_mouse_up(tx, ty, button)
      @image_flag = false
      super
    end

    def on_mouse_move(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      @image_flag = (WS.captured?(self) and @hit_cursor === self)
      super
    end

    def resize(tx, ty, width, height)
      super
      if @image.has_key?(true)
        @image[false].dispose
        @image[true].dispose
      end
      @image[false] = Image.new(width, height, [160,160,160])
                     .line(0,0,width-1,0,[240,240,240])
                     .line(0,0,0,height-1,[240,240,240])
                     .line(1,1,width-1,1,[200,200,200])
                     .line(1,1,1,height-1,[200,200,200])
                     .line(width-1,0,width-1,height-1,[80,80,80])
                     .line(0,height-1,width-1,height-1,[80,80,80])
                     .line(width-2,1,width-2,height-2,[120,120,120])
                     .line(1,height-2,width-2,height-2,[120,120,120])
      @image[true] = Image.new(width, height, [160,160,160])
                     .line(0,0,width-1,0,[80,80,80])
                     .line(0,0,0,height-1,[80,80,80])
                     .line(1,1,width-1,1,[120,120,120])
                     .line(1,1,1,height-1,[120,120,120])
                     .line(width-1,0,width-1,height-1,[200,200,200])
                     .line(0,height-1,width-1,height-1,[200,200,200])
                     .line(width-2,1,width-2,height-2,[240,240,240])
                     .line(1,height-2,width-2,height-2,[240,240,240])
       signal(:resize)
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
