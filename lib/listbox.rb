# coding: utf-8
require_relative './module.rb'

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

      client = WSListBoxClient.new(0, 0, width - 4 - 16, height - 4)
      add_control(client, :client)
      client.add_handler(:click) do |obj, tx, ty|
        @cursor = ((@pos * @font.size + ty) / @font.size).to_i
        signal(:select, @cursor)
      end

      sb = WSScrollBar.new(0, 0, 16, height - 4)
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

      layout(:hbox) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        add client, true, true
        add sb, false, true
      end
    end

    def resize(width, height)
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(self.client.width, @font.size, C_BLACK)
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
