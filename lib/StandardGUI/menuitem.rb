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

    def mouse_event(tx, ty)
      @obj.call if @obj
      @block.call(self.parent.object) if @block
    end

    def on_mouse_push(tx, ty)
      mouse_event(tx, ty)
      super
    end
    def on_mouse_release(tx, ty)
      mouse_event(tx, ty)
      super
    end
    def on_mouse_m_push(tx, ty)
      mouse_event(tx, ty)
      super
    end
    def on_mouse_m_release(tx, ty)
      mouse_event(tx, ty)
      super
    end
    def on_mouse_r_push(tx, ty)
      mouse_event(tx, ty)
      super
    end
    def on_mouse_r_release(tx, ty)
      mouse_event(tx, ty)
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
