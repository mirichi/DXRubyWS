# ウィンドウシステム
module WS
  class WSControl < Sprite
    attr_accessor :parent, :font, :width, :height
    @@default_font = Font.new(16)

    def initialize(tx, ty, width, height)
      super(tx, ty)
      @width, @height = width, height
      self.collision = [0, 0, width - 1, height - 1]
      @signal = {}
      @hit_cursor = Sprite.new
      @hit_cursor.collision = [0,0]
      @font = @@default_font
    end

    def on_mouse_down(tx, ty, button)
    end

    def on_mouse_up(tx, ty, button)
    end

    def on_mouse_move(tx, ty)
      return self
    end

    def on_mouse_over
    end

    def on_mouse_out
    end

    def on_mouse_down_internal(tx, ty, button)
      self.on_mouse_down(tx, ty, button)
      return self
    end

    def on_mouse_up_internal(tx, ty, button)
      self.on_mouse_up(tx, ty, button)
      return self
    end

    def on_mouse_move_internal(tx, ty)
      self.on_mouse_move(tx, ty)
      return self
    end

    def add_handler(signal, obj=nil, handler=nil, &block)
      if obj
        tmp = [obj, handler]
      else
        tmp = [block, :call]
      end

      if @signal.has_key?(signal)
        @signal[signal] << tmp
      else
        @signal[signal] = [tmp]
      end
    end

    def signal(s, *args)
      if @signal.has_key?(s)
        @signal[s].each do |tmp|
          tmp[0].__send__(tmp[1], self, *args)
        end
      end
    end

    def get_global_vertex
      return [self.x, self.y] unless self.parent
      tx, ty = self.parent.get_global_vertex
      [self.x + tx, self.y + ty]
    end

    def resize(x, y, width, height)
      self.x, self.y, @width, @height = x, y, width, height
    end
  end

  class WSContainer < WSControl
    attr_accessor :childlen

    def initialize(tx, ty, width, height)
      super(tx, ty, width, height)
      self.image = RenderTarget.new(width, height)
      @childlen = []
    end

    def add_control(obj, name=nil)
      obj.target = self.image
      obj.parent = self
      @childlen << obj
      if name.class == Symbol
        tmp = class << self;self;end
        tmp.class_eval do
          define_method(name) do
            obj
          end
        end
      end
    end

    def remove_control(obj)
      @childlen.delete(obj)
    end

    def update
      Sprite.update(@childlen)
      super
    end

    def draw
      Sprite.draw(@childlen)
      super
    end

    def find_hit_object(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx, ty
      @hit_cursor.check(@childlen.reverse)[0]
    end

    def on_mouse_down_internal(tx, ty, button)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_down_internal(tx - ctl.x, ty - ctl.y, button)
      else
        super
      end
    end

    def on_mouse_up_internal(tx, ty, button)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_up_internal(tx - ctl.x, ty - ctl.y, button)
      else
        super
      end
    end

    def on_mouse_move_internal(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_move_internal(tx - ctl.x, ty - ctl.y)
      else
        super
      end
    end
  end
end
