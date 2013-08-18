# coding: utf-8
require_relative './module.rb'

class Numeric
  def clamp(min, max)
    if self < min
      min
    elsif self > max
      max
    else
      self
    end
  end
end

module WS
  class WSListBox < WSContainer
    class WSListBoxClient < WSContainer
      include Clickable
      include DoubleClickable
    end

    attr_reader :items, :pos, :cursor
    def initialize(tx, ty, width, height)
      super
      self.image.bgcolor = C_WHITE
      @font = Font.new(12)
      @items = []
      @item_image = {}
      @pos = 0
      @cursor = 0

      client = WSListBoxClient.new(2, 2, width - 4 - 16, height - 4)
      add_control(client, :client)
      client.add_handler(:click) do |obj, tx, ty|
        @cursor = ((@pos * @font.size + ty) / @font.size).to_i
        signal(:select, @cursor)
      end

      sb = WSScrollBar.new(width - 16 - 2, 2, 16, height - 4)
      add_control(sb, :scrollbar)
      sb.add_handler(:slide) {|obj, pos| @pos = pos * slide_range}
      sb.add_handler(:btn_up) do
        @pos -= 1
        @pos = 0 if @pos < 0
        sb.set_slider(@pos.quo(slide_range) )
      end
      sb.add_handler(:btn_down) do
        max = slide_range
        @pos += 1
        @pos = max if @pos > max
        sb.set_slider(@pos.quo(max) )
      end
      sb.add_handler(:page_up) do
        @pos -= client.height / @font.size
        @pos = 0 if @pos < 0
        sb.set_slider(@pos.quo(slide_range) )
      end
      sb.add_handler(:page_down) do
        max = slide_range
        @pos += client.height / @font.size
        @pos = max if @pos > max
        sb.set_slider(@pos.quo(max) )
      end

      self.resize(width, height)
    end

    def resize(width, height)
      @cursor_image = Image.new(width - 4 - 16, @font.size, C_BLACK)
      self.client.resize(width - 4 - 16, height - 4)
      self.scrollbar.move(width - 16 - 2, 2)
      self.scrollbar.resize(16, height - 4)
      super
    end

    def slide_range
      @items.length - client.height.quo(@font.size)
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
        add_handler(:drag_move) {|obj, dx, dy| self.slide(dy)}
      end

      def draw
        if @old_height != @height
          self.image.dispose if self.image
          self.image = Image.new(@width, @height, [160,160,160])
                            .line(0,0,@width-1,0,[240,240,240])
                            .line(0,0,0,@height-1,[240,240,240])
                            .line(1,1,@width-1,1,[200,200,200])
                            .line(1,1,1,@height-1,[200,200,200])
                            .line(@width-1,0,@width-1,@height-1,[80,80,80])
                            .line(0,@height-1,@width-1,@height-1,[80,80,80])
                            .line(@width-2,1,@width-2,@height-2,[120,120,120])
                            .line(1,@height-2,@width-2,@height-2,[120,120,120])
          self.collision = [0, 0, @width-1, @height-1]
        end
        @old_height = @height
        super
      end

      def slide(dy)
        self.y = (self.y + dy).clamp(16, @parent.height - 16 - @height)
        signal(:slide, self.y)
      end
    end

    class WSRepeatButton < WSControl
      attr_accessor :caption, :fore_color
      include RepeatClickable
  
      def initialize(tx, ty, width, height, caption = "Button")
        super(tx, ty, width, height)
        @image = {}
        @image[false] = Image.new(width, height, [160,160,160])
                       .line(0,0,width-1,0,[240,240,240])
                       .line(0,0,0,height-1,[240,240,240])
                       .line(1,1,width-1,1,[200,200,200])
                       .line(1,1,1,height-1,[200,200,200])
                       .line(width-1,0,width-1,height-1,[80,80,80])
                       .line(0,height-1,width-1,height-1,[80,80,80])
                       .line(width-2,1,width-2,height-2,[120,120,120])
                       .line(1,height-2,width-2,height-2,[120,120,120])
        @image[true] = Image.new(width, height, [160,160,160])
                       .line(0,0,width-1,0,[80,80,80])
                       .line(0,0,0,height-1,[80,80,80])
                       .line(1,1,width-1,1,[120,120,120])
                       .line(1,1,1,height-1,[120,120,120])
                       .line(width-1,0,width-1,height-1,[200,200,200])
                       .line(0,height-1,width-1,height-1,[200,200,200])
                       .line(width-2,1,width-2,height-2,[240,240,240])
                       .line(1,height-2,width-2,height-2,[240,240,240])
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

      layout(:vbox) do
        add ub
        layout
        add db
      end
    end
    
    def draw
      self.slider.height = @screen_length / @item_length * (@height - 32)
      self.slider.height = self.slider.height.clamp(8, @height - 32)
      super
    end

    def on_slide(obj, pos)
      signal(:slide, (pos - 16).quo(height - 32 - slider.height))
    end

    def set_slider(p) # %
      slider.y = (height - 32 - slider.height) * p + 16
    end

    def on_click(obj, tx, ty)
      if ty < self.slider.y
        signal(:page_up)
      elsif ty >= self.slider.y + self.slider.height
        signal(:page_down)
      end
    end
  end
end

