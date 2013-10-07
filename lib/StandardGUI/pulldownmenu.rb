# coding: utf-8

require_relative './common'

module WS
  class WSPullDownMenu < WSControl
    class WSPullDownList <WSControl
      attr_accessor :content
      attr_reader :selected
      
      def initialize(tx, ty, width, content, form, default = nil)
        @content = content #表示するリスト
        @font = form.font
        super(tx, ty, width, content.size * @font.size + 4)
        @image = Image.new(@width, @height, C_WHITE).draw_border(true)
        @old_cont = @content #リストが変更されたかの確認用
        @form = form #データの出力先
        @selected = default #選択されているもの(index)
      end
      
      #いつリストが変更されるか分からないので、
      #update,draw時に更新
      def update_image(changed = false)
        if @content != @old_cont || changed
          @image.dispose
          @old_cont = @content
          @selected = nil if @selected >= @content.size
          @image = Image.new(@width, @height, C_WHITE).draw_border(true)
        end
        self.image = @image
      end
      
      def update
        update_image
        lx,ly = @form.get_global_vertex
        self.x,self.y = lx,ly + @form.height
        super
      end
      
      def draw
        update_image
        lx,ly = @form.get_global_vertex
        self.x,self.y = lx,ly + @form.height
        super
        @content.each_with_index do |str,i|
          Window.drawFont(self.x + 2, self.y + @font.size * i, str.to_s.within(@font, @width - 4), @font,{:color => [0,0,0],:z => self.z})
        end
      end
      
      #resize時に@image変更
      def resize
        super
        update_image(true)
      end
      
      def on_mouse_push(tx,ty)
        old_select = @selected
        if tx >= 2 && tx <= @width - 2 && ty >= 2 && ty <= @height - 2
          @selected = (ty - 2).div(@font.size)
        end
        WS.capture(nil)
        WS.desktop.remove_control(self)
        @form.change
      end
    end
    
    def initialize(tx, ty, width, height, content = [])
      super(tx, ty, width, height)
      @image = Image.new(@width, @height, C_LIGHT_GRAY).draw_border(true)
      lx, ly = self.get_global_vertex
      @list = WSPullDownList.new(lx, ly + height, width, content, self)
    end
    
    def resize(width, height)
      @image.dispose if @image
      @image = @image.new(@width, @height, C_LIGHT_GRAY).draw_border(true)
      lx, ly = self.get_global_vertex
      @list.x, @list.y = lx, ly + @height
      @list.resize(width, height)
      super
    end
    
    def move(tx,ty)
      super
      lx, ly = self.get_global_vertex
      @list.x, @list.y = lx, ly + @height
    end
    
    def on_mouse_push(tx, ty)
      super
      WS.desktop.add_control(@list)
      WS.capture(@list)
    end
    
    def draw
      self.image = @image
      super
      self.target.draw_font(self.x + 2, self.y + 2, value, @font, {:color => [0,0,0],:z => self.z}) if index
    end
    
    def value
      return @list.content[@list.selected] if @list.selected
      return nil
    end
    
    def index
      @list.selected
    end
    
    def change #新しく別のものが選択されたら呼ばれる。
      signal(:change,value,index)
    end
  end
end
