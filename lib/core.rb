# ウィンドウシステム
module WS
  class WSControl < Sprite
    attr_accessor :parent, :font
    @@default_font = Font.new(16)

    def initialize(x=0, y=0, image=nil)
      super
      @signal = {}
      @cursor = Sprite.new
      @cursor.collision = [0,0]
      @font = @@default_font
    end

    def mouse_down(tx, ty, button)
    end

    def mouse_up(tx, ty, button)
    end

    def mouse_move(tx, ty)
    end

    def mouse_over
    end

    def mouse_out
    end

    def on_mouse_down(tx, ty, button)
      self.mouse_down(tx, ty, button)
      return self
    end

    def on_mouse_up(tx, ty, button)
      self.mouse_up(tx, ty, button)
      return self
    end

    def on_mouse_move(tx, ty)
      if WS.over_object != self
        WS.over_object.mouse_out if WS.over_object
        self.mouse_over
      end
      self.mouse_move(tx, ty)
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
  end

  class WSContainer < WSControl
    attr_accessor :childlen

    def initialize(tx, ty, sx, sy)
      super(tx, ty, RenderTarget.new(sx, sy))
      @childlen = []
    end

    def add_control(obj)
      obj.target = self.image
      obj.parent = self
      @childlen << obj
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
      @cursor.x, @cursor.y = tx, ty
      @cursor.check(@childlen)[0]
    end

    def on_mouse_down(tx, ty, button)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_down(tx - ctl.x, ty - ctl.y, button)
      else
        super
      end
    end

    def on_mouse_up(tx, ty, button)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_up(tx - ctl.x, ty - ctl.y, button)
      else
        super
      end
    end

    def on_mouse_move(tx, ty)
      ctl = find_hit_object(tx, ty)
      if ctl
        ctl.on_mouse_move(tx - ctl.x, ty - ctl.y)
      else
        super
      end
    end
  end
end
