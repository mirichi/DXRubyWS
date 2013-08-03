module WS
  module Clickable
    def mouse_down(tx, ty, button)
      signal(:click)
      super
    end
  end

  module ButtonClickable
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
      @drag_old_x = tx
      @drag_old_y = ty
      signal(:drag_start)
      super
    end

    def mouse_up(tx, ty, button)
      @dragging_flag = false
      WS.capture(nil)
      signal(:drag_end)
      super
    end

    def mouse_move(tx, ty)
      signal(:drag_move, tx - @drag_old_x, ty - @drag_old_y) if @dragging_flag
      super
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

  module Resizable
    def mouse_down(tx, ty, button)
      WS.capture(self)
      @drag_old_x = tx
      @drag_old_y = ty
      signal(:resize_start)
      super
    end

    def mouse_up(tx, ty, button)
      WS.capture(nil)
      Input.set_cursor(IDC_ARROW)
      signal(:resize_end)
      super
    end

    def mouse_move(tx, ty)
      if WS.captured?(self)
        x1, y1, width, height = self.x, self.y, self.image.width, self.image.height

        if @resize_left
          width += @drag_old_x - tx
          x1 += tx - @drag_old_x
          tx -= tx - @drag_old_x
        end

        if @resize_top
          height += @drag_old_y - ty
          y1 += ty - @drag_old_y
          ty -= ty - @drag_old_y
        end

        if @resize_right
          width += tx - @drag_old_x
        end

        if @resize_bottom
          height += ty - @drag_old_y
        end

        if width > 16
          @drag_old_x = tx
        else
          width = 16
          x1 = self.x
        end
        if height > 16
          @drag_old_y = ty
        else
          height = 16
          y1 = self.y
        end
        signal(:resize_move, x1, y1, width, height)
      else
        border_width = @border_width ? @border_width : 2
        @resize_top = ty < border_width
        @resize_left = tx < border_width
        @resize_right = self.image.width - tx <= border_width
        @resize_bottom = self.image.height - ty <= border_width
        case true
        when @resize_top
          case true
          when @resize_left
            Input.set_cursor(IDC_SIZENWSE)
          when @resize_right
            Input.set_cursor(IDC_SIZENESW)
          else
            Input.set_cursor(IDC_SIZENS)
          end
        when @resize_bottom
          case true
          when @resize_left
            Input.set_cursor(IDC_SIZENESW)
          when @resize_right
            Input.set_cursor(IDC_SIZENWSE)
          else
            Input.set_cursor(IDC_SIZENS)
          end
        when @resize_left
          Input.set_cursor(IDC_SIZEWE)
        when @resize_right
          Input.set_cursor(IDC_SIZEWE)
        else
          Input.set_cursor(IDC_ARROW)
        end
      end
      super
    end

    def mouse_out
      Input.set_cursor(IDC_ARROW)
      super
    end
  end
end
