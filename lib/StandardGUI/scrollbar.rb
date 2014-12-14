# coding: utf-8
require_relative './common'

module WS
  # 縦スクロールバークラス
  class WSVScrollBar < WSContainer
    # スクロールバーのスライダークラス
    class WSVScrollBarSlider < WSControl
      include Draggable
      
      def initialize(tx=nil, ty=nil, width=nil, height=nil)
        super
        add_handler(:drag_move) do |obj, dx, dy|
          self.y = (self.y + dy).clamp(16, @parent.height - 16 - @height)
          signal(:slide, self.y)
        end
      end
      
      def render
        # スライダーの高さが変更された場合に画像を再生成する
        if @old_height != @height
          self.image.dispose if self.image
          self.image = Image.new(@width, @height, COLOR[:base]).draw_border(true)
          self.collision = [0, 0, @width-1, @height-1]
        end
        @old_height = @height
        super
      end
    end
    
    class WSScrollBarUpButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(7, 3, 3, 10, 11, 10, COLOR[:font])
        @image[:pushed].triangle_fill(8, 4, 4, 11, 12, 11, COLOR[:font])
      end
    end
    
    class WSScrollBarDownButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(7, 11, 3, 4, 11, 4, COLOR[:font])
        @image[:pushed].triangle_fill(8, 12, 4, 5, 12, 5, COLOR[:font])
      end
    end
    
    attr_accessor :view_size, :total_size, :shift_qty, :pos
    include RepeatClickable
    
    def initialize(tx=nil, ty=nil, width=16, height=nil)
      super
      self.image.bgcolor = COLOR[:light]
      @pos = 0
      @view_size = 0
      @total_size = 0
      @shift_qty = 1
      
      slider = WSVScrollBarSlider.new(0, 16, width, 16)
      slider.add_handler(:slide) do |obj, ty|
        if @height - 32 - slider.height == 0
          @pos = 0
        else
          @pos = (@total_size - @view_size) * ((ty - 16).quo(@height - 32 - slider.height))
        end
        signal(:slide, @pos)
      end
      add_control(slider, :slider)
      
      ub = WSScrollBarUpButton.new(0, 0, 16, 16)
      add_control(ub, :btn_up)
      ub.add_handler(:click) do
        @pos -= @shift_qty
        @pos = 0 if @pos < 0
        signal(:slide, @pos)
      end
      
      db = WSScrollBarDownButton.new(0, 0, 16, 16)
      add_control(db, :btn_down)
      db.add_handler(:click) do
        max = @total_size - @view_size
        if max >= 0
          @pos += @shift_qty
          @pos = max if @pos > max
          signal(:slide, @pos)
        end
      end
      
      layout(:vbox) do
        add ub
        layout
        add db
      end
    end
    
    def resize(width, height)
      super
      @pos = @pos.clamp(0, (@total_size - @view_size < 0 ? 0 : @total_size - @view_size))
      signal(:slide, @pos)
    end
    
    # 描画時にスライダーのサイズを再計算する
    def render
      if self.visible # DXRubyのバグ回避
        self.slider.height = (@total_size > 0 ? @view_size.quo(@total_size) * (@height - 32) : 0).clamp(8, @height - 32)
        if @total_size > @view_size
          self.slider.y = (@height - 32 - slider.height) * (@pos.quo((@total_size - @view_size))) + 16
        else
          self.slider.y = 16
        end
      end
      super
    end
    
    def slide(dy)
      @pos += dy
      @pos = @pos.clamp(0, (@total_size - @view_size < 0 ? 0 : @total_size - @view_size))
      signal(:slide, @pos)
    end
    
    def on_click(tx, ty)
      if ty < self.slider.y
        @pos -= @view_size
        @pos = 0 if @pos < 0
        signal(:slide, @pos)
      elsif ty >= self.slider.y + self.slider.height
        max = @total_size - @view_size
        @pos += @view_size
        @pos = max if @pos > max
        signal(:slide, @pos)
      end
    end
  end
  
  # 横スクロールバークラス
  class WSHScrollBar < WSContainer
    # スクロールバーのスライダークラス
    class WSHScrollBarSlider < WSControl
      include Draggable
      
      def initialize(tx=nil, ty=nil, width=nil, height=nil)
        super
        add_handler(:drag_move) do |obj, dx, dy|
          self.x = (self.x + dx).clamp(16, @parent.width - 16 - @width)
          signal(:slide, self.x)
        end
      end
      
      def render
        # スライダーの幅が変更された場合に画像を再生成する
        if @old_width != @width
          self.image.dispose if self.image
          self.image = Image.new(@width, @height, COLOR[:base]).draw_border(true)
          self.collision = [0, 0, @width-1, @height-1]
        end
        @old_width = @width
        super
      end
    end
    
    class WSScrollBarLeftButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(3, 8, 10, 4, 10, 11, COLOR[:font])
        @image[:pushed].triangle_fill(4, 9, 11, 5, 11, 12, COLOR[:font])
      end
    end
    
    class WSScrollBarRightButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(11, 8, 4, 4, 4, 11, COLOR[:font])
        @image[:pushed].triangle_fill(12, 9, 5, 5, 5, 12, COLOR[:font])
      end
    end
    
    attr_accessor :view_size, :total_size, :shift_qty, :pos
    include RepeatClickable
    
    def initialize(tx=nil, ty=nil, width=nil, height=16)
      super
      self.image.bgcolor = COLOR[:light]
      @pos = 0
      @view_size = 0
      @total_size = 0
      @shift_qty = 1
      
      slider = WSHScrollBarSlider.new(16, 0, 16, height)
      slider.add_handler(:slide) do |obj, tx|
        if @width - 32 - slider.width == 0
          @pos = 0
        else
          @pos = (@total_size - @view_size) * ((tx - 16).quo(@width - 32 - slider.width))
        end
        signal(:slide, @pos)
      end
      add_control(slider, :slider)
      
      lb = WSScrollBarLeftButton.new(0, 0, 16, 16)
      add_control(lb, :btn_left)
      lb.add_handler(:click) do
        @pos -= @shift_qty
        @pos = 0 if @pos < 0
        signal(:slide, @pos)
      end
      
      rb = WSScrollBarRightButton.new(0, 0, 16, 16)
      add_control(rb, :btn_right)
      rb.add_handler(:click) do
        max = @total_size - @view_size
        if max >= 0
          @pos += @shift_qty
          @pos = max if @pos > max
          signal(:slide, @pos)
        end
      end
      
      layout(:hbox) do
        add lb
        layout
        add rb
      end
    end
    
    def resize(width, height)
      super
      @pos = @pos.clamp(0, (@total_size - @view_size < 0 ? 0 : @total_size - @view_size))
      signal(:slide, @pos)
    end
    
    # 描画時にスライダーのサイズを再計算する
    def render
      if self.visible # DXRubyのバグ回避
        self.slider.width = (@total_size > 0 ? @view_size.quo(@total_size) * (@width - 32) : 0).clamp(8, @width - 32)
        if @total_size > @view_size
          self.slider.x = (@width - 32 - slider.width) * (@pos.quo((@total_size - @view_size))) + 16
        else
          self.slider.x = 16
        end
      end
      super
    end
    
    def slide(dx)
      @pos += dx
      @pos = @pos.clamp(0, (@total_size - @view_size < 0 ? 0 : @total_size - @view_size))
      signal(:slide, @pos)
    end
    
    def on_click(tx, ty)
      if tx < self.slider.x
        @pos -= @view_size
        @pos = 0 if @pos < 0
        signal(:slide, @pos)
      elsif tx >= self.slider.x + self.slider.width
        max = @total_size - @view_size
        @pos += @view_size
        @pos = max if @pos > max
        signal(:slide, @pos)
      end
    end
  end
  
  # スクロールバー付きコンテナ
  class WSScrollableContainer < WSLightContainer
    attr_accessor :client, :h_header_size, :v_header_size, :vsb, :hsb
    
    # 生成時にクライアント領域にするコントロールが必須
    def initialize(x=nil, y=nil, width=nil, height=nil, client)
      super(x, y, width, height)
      @client = client
      @h_header_size = @v_header_size = 0
      add_control(client, :client)
      
      # スクロールバー生成
      vsb = WSVScrollBar.new
      add_control(vsb, :vsb)
      hsb = WSHScrollBar.new
      add_control(hsb, :hsb)
      
      # 縦横スクロールバー表示用レイアウト
      @layout_vsb_hsb = WSLayout.new(:vbox, self, self) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        
        layout(:hbox) do
          add client, true, true
          add vsb, false, true
        end
        layout(:hbox) do
          self.resizable_height = false
          self.height = 16
          add hsb, true, false
          layout do
            self.width = self.height = 16
            self.resizable_width = self.resizable_height = false
          end
        end
      end
      
      # 縦スクロールバーのみ表示用レイアウト
      @layout_vsb = WSLayout.new(:vbox, self, self) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        
        layout(:hbox) do
          add client, true, true
          add vsb, false, true
        end
      end
      
      # 横スクロールバーのみ表示用レイアウト
      @layout_hsb = WSLayout.new(:vbox, self, self) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        
        layout(:vbox) do
          add client, true, true
          add hsb, true, false
        end
      end
      
      # スクロールバーなし
      @layout_none = WSLayout.new(:vbox, self, self) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        add client, true, true
      end
    end
    
    def resize(width, height)
      size_x = width - 4 - @h_header_size# とりあえずスクロールバー無しのクライアントサイズ
      size_y = height - 4 - @v_header_size
      bhsb = bvsb = false
      if size_x <= hsb.total_size # トータルサイズに満たない場合はスクロールバーが必要
        bhsb = true
        size_y -= 16 # スクロールバーのぶん縦が小さくなる
      end
      if size_y <= vsb.total_size
        bvsb = true
      end
      
      # 横が小さくなった場合の再判定
      if bvsb and !bhsb
        size_x -= 16
        if size_x <= hsb.total_size
          bhsb = true
        end
      end
      
      # オートレイアウトの選択
      if bhsb and bvsb
        @layout = @layout_vsb_hsb
        hsb.visible = vsb.visible = true
        hsb.collision_enable = vsb.collision_enable = true
      elsif bhsb
        @layout = @layout_hsb
        hsb.visible = true
        vsb.visible = false
        hsb.collision_enable = true
        vsb.collision_enable = false
        vsb.pos = 0
      elsif bvsb
        @layout = @layout_vsb
        hsb.visible = false
        vsb.visible = true
        hsb.collision_enable = false
        vsb.collision_enable = true
        hsb.pos = 0
      else
        @layout = @layout_none
        hsb.visible = vsb.visible = false
        hsb.collision_enable = vsb.collision_enable = false
        vsb.pos = 0
        hsb.pos = 0
      end
      
      super
      
      hsb.view_size = client.width
      vsb.view_size = client.height
    end
    
    def render
      resize(@width, @height) unless @layout
      super
    end
    
    def draw
      draw_border(false)
      super
    end
  end
end
