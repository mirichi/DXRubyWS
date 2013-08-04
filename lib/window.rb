require_relative './module.rb'

module WS
  class WSWindow < WSContainer
    attr_accessor :border_width
    include Resizable

    def initialize(tx, ty, sx, sy)
      super(tx, ty, sx, sy)
      self.image.bgcolor = [160,160,160]
      @border_width = 2
      @window_title = WSWindowTitle.new(@border_width, @border_width, sx - @border_width * 2, 16)
      add_control(@window_title)
      @window_title.add_handler(:close, self, :close)
      @window_title.add_handler(:drag_move, self, :move)
      add_handler(:resize_move, self, :resize)
    end

    # RenderTarget#draw_lineは現在バグってて右/下が1ピクセル短くなる。
    def draw
      sx = self.image.width
      sy = self.image.height
      self.image.draw_line(0,0,sx-1,0,[240,240,240])
      self.image.draw_line(0,0,0,sy-1,[240,240,240])
      self.image.draw_line(1,1,sx-1,1,[200,200,200])
      self.image.draw_line(1,1,1,sy-1,[200,200,200])
      self.image.draw_line(sx-1,0,sx-1,sy-1,[80,80,80])
      self.image.draw_line(0,sy-1,sx-1,sy-1,[80,80,80])
      self.image.draw_line(sx-2,1,sx-2,sy-2,[120,120,120])
      self.image.draw_line(1,sy-2,sx-2,sy-2,[120,120,120])
      super
    end

    def close(obj)
      self.parent.remove_control(self)
    end

    def move(obj, dx, dy)
      self.x += dx
      self.y += dy
    end

    def resize(obj, x1, y1, width, height)
      obj.x, obj.y = x1, y1
      obj.image.resize(width, height)
      @window_title.resize(obj, @border_width, @border_width, width - @border_width * 2, 16)
    end

    def on_mouse_down(tx, ty, button)
      self.parent.childlen.push(self.parent.childlen.delete(self))
      super
    end

  end

  class WSWindowTitle < WSContainer
    include Draggable

    def initialize(tx, ty, sx, sy, title="Title")
      super(tx, ty, sx, sy)
      self.image.bgcolor = C_BLUE

      @close_button = WSButton.new(sx-16, 1, sy-2, sy-2, "X")
      @close_button.fore_color = C_BLACK
      add_control(@close_button)
      @close_button.add_handler(:click) {signal(:close)}

      @label = WSLabel.new(2, 2, sx, sy, title)
      add_control(@label)
    end

    def resize(obj, x1, y1, width, height)
      self.x, self.y = x1, y1
      self.image.resize(width, height)
      @close_button.x = width - 16
    end
  end
end
