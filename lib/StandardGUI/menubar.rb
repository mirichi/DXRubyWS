# coding: utf-8
require_relative './popupmenu'
require_relative './common'
require_relative './image'

module WS
  # ウィンドウにくっつけるメニューバー
  class WSMenuBar < WSContainer
    
    class WSMenuBarItem < WSImage
      attr_reader :item
      attr_accessor :popup
      
      def initialize(str, item, font=nil)
        @str = str
        @item = item
        @font = font if font
        w = @font.getWidth(@str)
        
        super(nil,nil,w+10,@font.size+4)
        
        @image = {true  => Image.new(w + 10, @font.size + 4).draw(4, 0, Image.new(w + 2, @font.size + 4, [150,150,150])).draw_font_ex(5, 2, @str, @font, :color=>COLOR[:font],:aa=>false),
          false => Image.new(w + 10, @font.size + 4).draw_font_ex(5, 2, @str, @font, :color=>COLOR[:font],:aa=>false)}
        self.image = @image[false]
        
        @mouse_on = false
        @popup = false
      end
      
      def on_mouse_push(tx, ty)
        @mouse_on = false
        
        self.parent.popup(self)
        
        super
      end
      
      def on_mouse_move(tx, ty)
        @mouse_on = true
        
        self.parent.popup(self) if @popup && WS.captured?(@popup)
        
        super
      end
      
      def on_mouse_out
        @mouse_on = false
        
        super
      end
      
      def render
        self.image = @image[@mouse_on]
        
        super
      end
    end
    
    def initialize(menuitems)
      super(nil, nil, nil, 16) #オートレイアウトで設定する。
      @font = Font.new(12)
      @menuitems = ary = menuitems.map{|ary|
        mbi = WSMenuBarItem.new(ary[0], ary[1], @font)
        self.add_control(mbi)
        mbi
      }
      self.image.bgcolor = COLOR[:base]
      @popup = nil
      
      layout(:hbox) do
        ary.each do |item|
          add item
        end
        layout
      end
    end
    
    def popup(item)
      WS.desktop.remove_control(@popup) if @popup
      tmpx, tmpy = item.get_global_vertex
      @popup = WSPopupMenu.new(tmpx, @font.size + 4 + tmpy, item.item)
      WS.desktop.add_control(@popup)
      @popup.object = self
      WS.capture(@popup)
      
      @menuitems.each do |ctl|
        ctl.popup = @popup
      end
    end
    
    def resize(width, height)
      super
      self.height = @min_height
    end
  end
end
