# coding: utf-8
require_relative './module.rb'

module WS
  class WSListBox < WSContainer
    attr_reader :items, :pos, :cursor
    def initialize(tx, ty, width, height)
      super
      self.image.bgcolor = C_WHITE
      @items = []
      @item_image = {}
      @pos = 0
      @cursor = 0
      @cursor_image = Image.new(width - 4 - 16, @font.size, C_BLACK)

      client = WSContainer.new(2, 2, width - 4 - 16, height - 4)
      add_control(client, :client)
      client.extend Clickable
      client.add_handler(:click) do |obj, tx, ty|
        @cursor = ((@pos * @font.size + ty) / @font.size).to_i
        signal(:select, @cursor)
      end

      sb = WSScrollBar.new(width - 16 - 2, 2, 16, height - 4)
      add_control(sb, :scrollbar)
      sb.add_handler(:slide) do |obj, pos|
        @pos = pos * (@items.length - client.height.quo(@font.size))
      end
      sb.add_handler(:btn_up) do
        @pos -= 1
        @pos = 0 if @pos < 0
        sb.set_slider(@pos.quo(@items.length - client.height.quo(@font.size)) )
      end
      sb.add_handler(:btn_down) do
        max = @items.length - client.height.quo(@font.size)
        @pos += 1
        @pos = max if @pos > max
        sb.set_slider(@pos.quo(max) )
      end
    end

    def draw
      @items.each_with_index do |s, i|
        if @cursor != i
          self.client.image.draw_font(2, (i - @pos) * @font.size, s.to_s, @font, :color=>C_BLACK)
        else
          self.client.image.draw(0, (i - @pos) * @font.size, @cursor_image)
          self.client.image.draw_font(2, (i - @pos) * @font.size, s.to_s, @font, :color=>C_WHITE)
        end
      end
      self.image.draw_line(0,0,@width-1,0,[80,80,80])
      self.image.draw_line(0,0,0,@height-1,[80,80,80])
      self.image.draw_line(1,1,@width-1,1,[120,120,120])
      self.image.draw_line(1,1,1,@height-1,[120,120,120])
      self.image.draw_line(@width-1,0,@width-1,@height-1,[240,240,240])
      self.image.draw_line(0,@height-1,@width-1,@height-1,[240,240,240])
      self.image.draw_line(@width-2,1,@width-2,@height-2,[200,200,200])
      self.image.draw_line(1,@height-2,@width-2,@height-2,[200,200,200])

      self.scrollbar.item_length = @items.length
      self.scrollbar.screen_length = self.client.height.quo(@font.size)
      if self.client.height.quo(@font.size) > @items.length
        self.scrollbar.visible = false
      else
        self.scrollbar.visible = true
      end
      super
    end
  end
end

module WS
  class WSScrollBar < WSContainer
    class WSScrollBarSlider < WSControl
      include Draggable
      def initialize(tx, ty, width, height)
        super
        add_handler(:drag_move) do |obj, dx, dy|
          self.y += dy
          signal(:slide, self.y)
        end
      end

      def draw
        if @old_height != @height
          self.image = Image.new(@width, @height, [160,160,160])
                      .line(0,0,@width-1,0,[240,240,240])
                      .line(0,0,0,@height-1,[240,240,240])
                      .line(1,1,@width-1,1,[200,200,200])
                      .line(1,1,1,@height-1,[200,200,200])
                      .line(@width-1,0,@width-1,@height-1,[80,80,80])
                      .line(0,@height-1,@width-1,@height-1,[80,80,80])
                      .line(@width-2,1,@width-2,@height-2,[120,120,120])
                      .line(1,@height-2,@width-2,@height-2,[120,120,120])
          self.collision = [0, 0, @width, @height]
        end
        @old_height = @height
        super
      end

      def slide
        signal(:slide, self.y)
      end
    end

    class WSRepeatButton < WSControl
      attr_accessor :caption, :fore_color
      include RepeatClickable
  
      def initialize(tx, ty, sx, sy, caption = "Button")
        super(tx, ty, sx, sy)
        @image = {}
        @image[false] = Image.new(sx, sy, [160,160,160])
                       .line(0,0,sx-1,0,[240,240,240])
                       .line(0,0,0,sy-1,[240,240,240])
                       .line(1,1,sx-1,1,[200,200,200])
                       .line(1,1,1,sy-1,[200,200,200])
                       .line(sx-1,0,sx-1,sy-1,[80,80,80])
                       .line(0,sy-1,sx-1,sy-1,[80,80,80])
                       .line(sx-2,1,sx-2,sy-2,[120,120,120])
                       .line(1,sy-2,sx-2,sy-2,[120,120,120])
        @image[true] = Image.new(sx, sy, [160,160,160])
                       .line(0,0,sx-1,0,[80,80,80])
                       .line(0,0,0,sy-1,[80,80,80])
                       .line(1,1,sx-1,1,[120,120,120])
                       .line(1,1,1,sy-1,[120,120,120])
                       .line(sx-1,0,sx-1,sy-1,[200,200,200])
                       .line(0,sy-1,sx-1,sy-1,[200,200,200])
                       .line(sx-2,1,sx-2,sy-2,[240,240,240])
                       .line(1,sy-2,sx-2,sy-2,[240,240,240])
        @image_flag = false
        @caption = caption
      end
  
      def on_mouse_down(tx, ty, button)
        @image_flag = true
        super
      end
  
      def on_mouse_up(tx, ty, button)
        @image_flag = false
        super
      end
  
      def on_mouse_move(tx, ty)
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        @image_flag = (WS.captured?(self) and @hit_cursor === self)
        super
      end
  
      def draw
        self.image = @image[@image_flag]
        super
        width = @font.get_width(@caption)
        self.target.draw_font(self.image.width / 2 - width / 2 + self.x + (@image_flag ? 1 : 0),
                              self.image.height / 2 - @font.size / 2 + self.y + (@image_flag ? 1 : 0),
                              @caption, @font, :color=>@fore_color)
      end
    end
  
    attr_accessor :screen_length, :item_length
    include RepeatClickable

    def initialize(tx, ty, width, height)
      super
      self.image.bgcolor = [200, 200, 200]
      font = Font.new(12)

      slider = WSScrollBarSlider.new(0, 16, width, 16)
      slider.add_handler(:slide, self, :on_slide)
      add_control(slider, :slider)

      ub = WSRepeatButton.new(0, 0, width, 16, "▲")
      ub.fore_color = C_BLACK
      ub.font = font
      add_control(ub, :btn_up)
      ub.add_handler(:click){signal(:btn_up)}

      db = WSRepeatButton.new(0, height - 16, width, 16, "▼")
      db.fore_color = C_BLACK
      db.font = font
      add_control(db, :btn_down)
      db.add_handler(:click){signal(:btn_down)}
      
      add_handler(:click, self, :on_click)
    end
    
    def draw
      self.slider.height = @screen_length / @item_length * (@height - 32)
      self.slider.height = 16 if self.slider.height < 16
      self.slider.height = (@height - 32) if self.slider.height > (@height - 32)
      super
    end

    def on_slide(obj, pos)
      pos = 16 if pos < 16
      if pos > height - 16 - slider.height
        pos = height - 16 - slider.height
      end
      slider.y = pos
      signal(:slide, (pos - 16).quo(height - 32 - slider.height))
    end

    def set_slider(p) # %
      slider.y = (height - 32 - slider.height) * p + 16
    end

    def on_click(obj, tx, ty)
      if ty < self.slider.y
        self.slider.y -= self.slider.height
        self.slider.slide
      elsif ty >= self.slider.y + self.slider.height
        self.slider.y += self.slider.height
        self.slider.slide
      end
    end
  end
end

