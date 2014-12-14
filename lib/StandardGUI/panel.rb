# coding: utf-8

module WS
  class WSPanel < WSLightContainer
    
    class WSPanelClient < WSLightContainer
    end
    
    def initialize(sx, sy, width, height, caption="", border = true)
      super(sx, sy, width, height)
      @caption = caption
      @border  = border
      create_client
    end
    
    def create_client
      _add_control(WSPanelClient.new(0, 0, 32, 32), :client)
      layout(:hbox) do
        set_margin(32, 8, 8, 8)
        add obj.client, true, true
      end
    end
    
    # コントロールの追加(クライアントに直接追加します)
    def add_control(obj, name=nil)
      client.add_control(obj , name)
      if name
        tmp = class << self;self;end
        tmp.class_eval do
          define_method(name) do obj end
        end
      end
      obj
    end
    
    # 描画
    def draw
      super
      # キャプションの描画
      if @caption.length > 0
        cw = @font.get_width(@caption) + 2
        cs = 4
        self.target.draw_font( self.x + 8, self.y, @caption, @font, :color=>COLOR[:font])
      else
        cw = 0
        cs = 0
      end
      # ボーダーの描画
      if @border
        sx = self.x
        sy = self.y + 8
        ex = self.x + @width
        ey = self.y + @height
        self.target.draw_line( sx, sy, sx + 8 - cs, sy, COLOR[:darkshadow])
        self.target.draw_line( sx, sy + 1, sx + 8 - cs, sy + 1, COLOR[:highlight])
        self.target.draw_line( sx + 8 + cw, sy, ex, sy, COLOR[:darkshadow])
        self.target.draw_line( sx + 8 + cw, sy + 1, ex, sy + 1, COLOR[:highlight])
        self.target.draw_line( sx, sy, sx, ey, COLOR[:darkshadow])
        self.target.draw_line( sx + 1, sy + 1, sx + 1, ey, COLOR[:highlight])
        self.target.draw_line( sx, ey - 1, ex, ey - 1, COLOR[:darkshadow])
        self.target.draw_line( sx, ey, ex, ey, COLOR[:highlight])
        self.target.draw_line( ex - 1, sy, ex - 1, ey, COLOR[:darkshadow])
        self.target.draw_line( ex, sy, ex, ey, COLOR[:highlight])
      end
    end
    
  end
end
