module WS
  module Clickable
    def mouse_down(tx, ty, button)
      signal(:click)
      super
    end
  end

  module ButtonClickable
    def initialize(tx=0, ty=0, image=nil)
      super
    end

    def mouse_down(tx, ty, button)
      WS.capture(self)
      super
    end

    def mouse_up(tx, ty, button)
      WS.capture(nil)
      @cursor.x, @cursor.y = tx + self.x, ty + self.y
      signal(:click) if @cursor === self
      super
    end
  end

  module Draggable
    def initialize(*args)
      super
      @dragging_flag = false
    end

    def mouse_down(tx, ty, button)
      @dragging_flag = true
      WS.capture(self)
      super
      @drag_old_x = tx
      @drag_old_y = ty
      signal(:drag_start)
    end

    def mouse_up(tx, ty, button)
      @dragging_flag = false
      WS.capture(nil)
      super
      signal(:drag_end)
    end

    def mouse_move(tx, ty)
      signal(:drag_move, tx - @drag_old_x, ty - @drag_old_y) if @dragging_flag
    end
  end

  module MouseOver
    def mouse_over
      signal(:mouse_over)
      super
    end

    def mouse_out
      signal(:mouse_out)
      super
    end
  end
end
