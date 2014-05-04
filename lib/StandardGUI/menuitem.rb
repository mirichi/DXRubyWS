# coding: utf-8

module WS
  # メニューアイテム
  class WSMenuItem < WSControl
    attr_accessor :str, :obj
    @@select_bg_pixel = Image.new(1, 1, C_BLUE)

    def initialize(str, obj=nil, &block)
      @str, @obj, @block = str, obj, block
      @font = Font.new(12)
      super(0, 0, @font.get_width(str), @font.size)
      @select = false
    end

    def mouse_event_dispatch(event, tx, ty)
      if event != :mouse_move
        @obj.call if @obj.respond_to?(:call)
        @block.call(self.parent.object) if @block
      end
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
        self.target.draw_font(self.x, self.y, @str, @font, :color=>COLOR[:font_reverse])
      else
        self.target.draw_font(self.x, self.y, @str, @font, :color=>COLOR[:font])
      end
    end
  end
end
