# ウィンドウシステム
module WS
  class WSControl < Sprite
    attr_accessor :parent, :font, :width, :height, :resizable_width, :resizable_height
    @@default_font = Font.new(16)

    def initialize(tx, ty, width, height)
      super(tx, ty)
      @width, @height = width, height
      self.collision = [0, 0, width - 1, height - 1]
      @signal = {}
      @hit_cursor = Sprite.new
      @hit_cursor.collision = [0,0]
      @font = @@default_font
      @layout = nil
      @resizable_width = false
      @resizable_height = false
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

    def move(tx, ty)
      self.x, self.y = tx, ty
      signal(:move, tx, ty)
    end

    def resize(width, height)
      @width, @height = width, height
      self.collision = [0, 0, width - 1, height - 1]
      signal(:resize)
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

    def layout(type=nil, &b)
      @layout = Layout.new(type, self, &b)
      @layout.auto_layout
    end

    def resize(width, height)
      super
      if @layout
        @layout.width, @layout.height = width, height
        @layout.auto_layout
      end
    end
  end

  class Layout
    attr_accessor :type, :x, :y, :width, :height, :resizable_width, :resizable_height

    def initialize(type, obj, &b)
      @type, @obj = type, obj
      @x = @y = 0
      @width = obj.width
      @height = obj.height
      @data = []
      @resizable_width = true
      @resizable_height = true
      self.instance_eval &b
    end

    def layout(type=nil, &b)
      @data << Layout.new(type, self, &b)
      self
    end
    
    def add(o)
      @data << o
    end

    def adjust_x
      @data.each do |o|
        old_x, old_y = o.x, o.y
        old_width, old_height = o.width, o.height
        yield o
        # 直交位置サイズ調整
        if o.resizable_height
          # いっぱいに広げる
          o.y = self.y
          o.height = self.height
        else
          # 真ん中にする
          o.y = self.height / 2 - o.height / 2 + self.y
        end

        # 変わってたらmoveを呼び出す
        if old_x != o.x or old_y != o.y
          o.move(o.x, o.y)
        end

        # 変わってたらresizeを呼び出す
        if old_width != o.width or old_height != o.height
          o.resize(o.width, o.height)
        end
      end
    end

    def adjust_y
      @data.each do |o|
        old_x, old_y = o.x, o.y
        old_width, old_height = o.width, o.height
        yield o
        # 直交位置サイズ調整
        if o.resizable_width
          # いっぱいに広げる
          o.x = self.x
          o.width = self.width
        else
          # 真ん中にする
          o.x = self.width / 2 - o.width / 2 + self.x
        end

        # 変わってたらmoveを呼び出す
        if old_x != o.x or old_y != o.y
          o.move(o.x, o.y)
        end

        # 変わってたらresizeを呼び出す
        if old_width != o.width or old_height != o.height
          o.resize(o.width, o.height)
        end
      end
    end

    def auto_layout
      case @type
      when :hbox # 水平に並べる
        # サイズ未定のものをカウント
        undef_size_count = @data.count {|o| o.resizable_width }

        # サイズ確定オブジェクトのサイズ合計
        total = @data.inject(0) {|t, o| t += (o.resizable_width ? 0 : o.width)}

        # 座標開始位置
        point = self.x

        case undef_size_count
        when 0 # 均等
          # 座標調整
          adjust_x do |o|
            point += (self.width - total) / (@data.size + 1) # オブジェクトの間隔を足す
            o.x = point
            point += o.width
          end

        else # 最大化するものを含む
          # 座標調整
          adjust_x do |o|
            o.x = point
            o.width = (self.width - total) / undef_size_count if o.resizable_width # 最大化するオブジェクトを最大化
            point += o.width
          end
        end

      when :vbox # 垂直に並べる
        # サイズ未定のものをカウント
        undef_size_count = @data.count {|o| o.resizable_height }

        # サイズ確定オブジェクトのサイズ合計
        total = @data.inject(0) {|t, o| t += (o.resizable_height ? 0 : o.height)}

        # 座標開始位置
        point = self.y

        case undef_size_count
        when 0 # 均等
          # 座標調整
          adjust_y do |o|
            point += (self.height - total) / (@data.size + 1) # オブジェクトの間隔を足す
            o.y = point
            point += o.height
          end

        else # 最大化するものを含む
          # 座標調整
          adjust_y do |o|
            o.y = point
            o.height = (self.height - total) / undef_size_count if o.resizable_height # 最大化するオブジェクトを最大化
            point += o.height
          end
        end
      end

      @data.each do |o|
        o.auto_layout if Layout === o
      end
    end

    def move(tx, ty)
      @x, @y = tx, ty
    end

    def resize(width, height)
      @width, @height = width, height
    end
  end
end
