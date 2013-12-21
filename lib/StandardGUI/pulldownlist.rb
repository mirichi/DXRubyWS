# coding: utf-8

require_relative './common'

module WS
  class WSPullDownList < WSControl
    include Focusable
    attr_accessor :list
    
    class WSPullDownPopup <WSControl
      attr_accessor :content
      attr_reader :selected
      
      def initialize(tx, ty, width, content, form, default = 0)
        @content = content #表示するリスト
        @font = form.font
        super(tx, ty, width, content.size * @font.size + 4)
        @image = Image.new(@width, @height, C_WHITE).draw_border(true)
        @active_image = Image.new(@width - 6, @font.size, [200, 200, 255])
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
          @selected = 0 if @selected >= @content.size
          self.height = @content.size * @font.size + 4
          @image = Image.new(self.width, self.height, C_WHITE).draw_border(true)
          @active_image = Image.new(@width - 6, @font.size, [200, 200, 255])
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
          self.target.draw(self.x + 3, self.y + @font.size * i + 3, @active_image, self.z) if @selected == i
          self.target.drawFont(self.x + 2, self.y + @font.size * i + 2, str.to_s.within(@font, @width - 4), @font,{:color => C_BLACK,:z => self.z})
        end
      end
      
      #resize時に@image変更
      def resize
        super
        update_image(true)
      end
      
      def on_mouse_push(tx,ty)
        super
        old_select = @selected
        if tx >= 2 && tx <= @width - 2 && ty >= 2 && ty <= @height - 2
          @selected = (ty - 2).div(@font.size)
        end
        WS.capture(nil)
        WS.desktop.remove_control(self)
        @form.change if old_select != @selected
      end
      
      def on_mouse_r_push(tx, ty)
        super
        WS.capture(nil)
        WS.desktop.remove_control(self)
      end
    
      def selected=(v)
        old_select = @selected
        @selected = v.clamp(0, @content.size-1)
        @form.change if old_select != @selected
      end
    end
    

    def initialize(tx, ty, width, height, content = [])
      super(tx, ty, width, height)
      @image = Image.new(@width, @height, C_WHITE).draw_border(false)
      @btn_image =Image.new(@height - 4, @height - 4, C_GRAY).triangle_fill(7, 11, 3, 4, 11, 4, C_BLACK).draw_border(true) # 暫定
      @active_image = Image.new(@width - 6, @height - 6, [200, 200, 255])
      lx, ly = self.get_global_vertex
      @list = WSPullDownPopup.new(lx, ly + height, width, content, self)

      self.add_key_handler(K_UP) do
        @list.selected -= 1
        unless WS.captured?(@list)
          WS.desktop.add_control(@list)
          WS.capture(@list)
        end
      end
      self.add_key_handler(K_DOWN) do
        @list.selected += 1
        unless WS.captured?(@list)
          WS.desktop.add_control(@list)
          WS.capture(@list)
        end
      end
      self.add_key_handler(K_RETURN) do
        if WS.captured?(@list)
          WS.capture(nil)
          WS.desktop.remove_control(@list)
        end
      end
    end
    
    def resize(width, height)
      @image.dispose if @image
      @image = @image.new(@width, @height, C_WHITE).draw_border(true)
      @btn_image =Image.new(@height-4, @height-4, C_GRAY).triangle_fill(7, 11, 3, 4, 11, 4, C_BLACK).draw_border(true) # 暫定
      @active_image = Image.new(@width - 6, @height - 6, [200, 200, 255])
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

      if self.activated?
        self.target.draw(self.x + 3, self.y + 3, @active_image, self.z)
      end
      self.target.draw_font(self.x + 2, self.y + 2, value.to_s, @font, {:color => C_BLACK,:z => self.z}) if self.index
      self.target.draw(self.x + 2 + @width - @height, self.y + 2, @btn_image, self.z)
    end
    
    def value
      @list.content[@list.selected]
    end
    
    def index
      @list.selected
    end
    
    def change #新しく別のものが選択されたら呼ばれる。
      signal(:change, self.value, self.index)
    end

    def on_leave
      if WS.captured?(@list)
        WS.capture(nil)
        WS.desktop.remove_control(@list)
      end
      super
    end
  end
end
 
