# coding: utf-8
require_relative './module.rb'

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

      def on_mouse_down(tx, ty)
        @image_flag = true
        super
      end
  
      def on_mouse_up(tx, ty)
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

      db = WSRepeatButton.new(0, 0, width, 16, "▼")
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
      self.slider.height = (@item_length > 0 ? @screen_length / @item_length * (@height - 32) : 0)
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
