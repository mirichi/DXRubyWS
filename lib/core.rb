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

    def resize(x, y, width, height)
      self.x, self.y, @width, @height = x, y, width, height
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

    def resize(tx, ty, width, height)
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

    def auto_layout
      undef_size_count = 0

      case @type
      when :hbox # 水平に並べる
        @data.each do |o|
          # サイズ未定のもの
          if o.resizable_width
            undef_size_count += 1
          end
        end

        case undef_size_count
        when 0 # 均等
          h_total = 0
          @data.each do |o| # オブジェクトのサイズ合計
            h_total += o.width unless o.resizable_width
          end
          h = self.width - h_total # あまったサイズ
          tmp = h / (@data.size + 1)
          old = self.x
          @data.each do |o|
            o.x = old + tmp
            old = o.x + o.width
            o.y = self.height / 2 - o.height / 2 + self.y
            if o.resizable_height
              o.height = self.height     
            end
          end
        when 1 # ひとつだけ最大
          h_total = 0
          @data.each do |o| # オブジェクトのサイズ合計
            h_total += o.width unless o.resizable_width
          end
          h = self.width - h_total # あまったサイズ
          tmp = self.x
          @data.each do |o|
            if o.resizable_width
              o.x = tmp
              o.width = h
            else
              o.x = tmp
            end
            o.y = self.height / 2 - o.height / 2 + self.y
            if o.resizable_height
              o.height = self.height     
            end
            tmp += o.width
          end
        else # サイズ未定のものを同じサイズに
          h_total = 0
          @data.each do |o| # オブジェクトのサイズ合計
            h_total += o.width unless o.resizable_width
          end
          h = (self.width - h_total) / undef_size_count # 可変オブジェクトのサイズ
          tmp = self.x
          @data.each do |o|
            if o.resizable_width
              o.x = tmp
              o.width = h
            else
              o.x = tmp
            end
            o.y = self.height / 2 - o.height / 2 + self.y
            if o.resizable_height
              o.height = self.height     
            end
            tmp += o.width
          end
        end

      when :vbox # 垂直に並べる
        @data.each do |o|
          # サイズ未定のもの
          if o.resizable_height
            undef_size_count += 1
          end
        end
        case undef_size_count
        when 0 # 均等
          v_total = 0
          @data.each do |o| # オブジェクトのサイズ合計
            v_total += o.height unless o.resizable_height
          end
          v = self.height - v_total # あまったサイズ
          tmp = v / (@data.size + 1)
          old = self.y
          @data.each do |o|
            o.y = old + tmp
            old = o.y + o.height
            o.x = self.width / 2 - o.width / 2 + self.x
            if o.resizable_width
              o.width = self.width
            end
          end
        when 1 # ひとつだけ最大
          v_total = 0
          @data.each do |o| # オブジェクトのサイズ合計
            v_total += o.height unless o.resizable_height
          end
          v = self.height - v_total # あまったサイズ
          tmp = self.y
          @data.each do |o|
            if o.resizable_height
              o.y = tmp
              o.height = v
            else
              o.y = tmp
            end
            o.x = self.width / 2 - o.width / 2 + self.x
            if o.resizable_width
              o.width = self.width
            end
            tmp += o.height
          end
        else # サイズ未定のものを同じサイズに
          v_total = 0
          @data.each do |o| # オブジェクトのサイズ合計
            v_total += o.height unless o.resizable_height
          end
          v = (self.height - v_total) / undef_size_count # 可変オブジェクトのサイズ
          tmp = self.y
          @data.each do |o|
            if o.resizable_height
              o.y = tmp
              o.height = v
            else
              o.y = tmp
            end
            o.x = self.width / 2 - o.width / 2 + self.x
            if o.resizable_width
              o.width = self.width
            end
            tmp += o.height
          end
        end
      end
      @data.each do |o|
        o.auto_layout if Layout === o
      end
    end
  end
end
