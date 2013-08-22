# coding: utf-8

module WS
  # メニューアイテム
  class WSMenuItem < WSControl
    attr_accessor :str, :obj, :method
    @@select_bg_pixel = Image.new(1, 1, C_BLUE)

    def initialize(str, obj=nil, method=nil, &block)
      @str, @obj, @method, @block = str, obj, method, block
      @font = Font.new(12)
      super(0, 0, @font.get_width(str), @font.size)
      @select = false
    end

    def on_mouse_down(tx, ty)
      if @obj
        @obj.__send__(@method)
      elsif @block
        @block.call(self.parent.parent.object)
      end
      super
    end
    
    def on_mouse_over
      @select = true
      super
    end

    def on_mouse_out
      @select = false
      super
    end

    def draw
      if @select
        self.target.draw_scale(self.x, self.y, @@select_bg_pixel, @width, @height, 0, 0)
        self.target.draw_font(self.x, self.y, @str, @font, :color=>C_WHITE)
      else
        self.target.draw_font(self.x, self.y, @str, @font, :color=>C_BLACK)
      end
    end
  end
end
