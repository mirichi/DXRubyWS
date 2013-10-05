# coding: utf-8

require_relative './common'

module WS
  class WSPullDownMenu < WSControl
    class WSPullDownList <WSControl
      def initialize(tx, ty, width, content, form)
        @content = content #表示するリスト
        super(tx, ty, width, content.size * @parent.font.size + 4)
        @image = Image.new(@width, @height, C_WHITE).draw_border(true)
        @old_cont = @content #リストが変更されたかの確認用
        @form = form #データの出力先
        @selected = nil #選択されているもの(index)
      end
      
      #いつリストが変更されるか分からないので、
      #update,draw時に更新
      def update_image(changed = false)
        if @content != @old_cont || changed
          @image.dispose
          @old_cont = @content
          @image = Image.new(@width, @height, C_WHITE).draw_border(true)
        end
      end
      
      def update
        update_image
        super
      end
      
      def draw
        update_image
        super
        @content.each_with_index do |str,i|
          Window.drawFont(self.x + 2, self.y + @font.size * i, str, @font)
        end
      end
      
      #resize時に@image変更
      def resize
        super
        update_image(true)
      end
    end
    
    def initialize(tx, ty, width, height, content = [])
      super
      @image = Image.new(@width, @height, C_LIGHT_GRAY).draw_border(true)
      lx, ly = self.get_global_vertex
      @list = WSPullDownList.new(lx, ly + height, width, content, self)
    end
    
    def resize(width, height)
      @image.dispose if @image
      @image = @image.new(@width, @height, C_LIGHT_GRAY).draw_border(true)
      lx, ly = self.get_global_vertex
      @list.x, @list.y = lx, ly + @height
      @list.width = @width
      @list.resize(width, height)
      super
    end
    
    def move
      super
      lx, ly = self.get_global_vertex
      @list.x, @list.y = lx, ly + @height
    end
    
    def on_mouse_push(tx, ty)
      super
    end
    
    def draw
      super
      
    end
  end
end
