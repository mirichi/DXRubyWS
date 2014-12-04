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
        @image = Image.new(@width, @height, COLOR[:background]).draw_border(true)
        @active_image = Image.new(@width - 6, @font.size, COLOR[:select])
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
          @image = Image.new(self.width, self.height, COLOR[:background]).draw_border(true)
          @active_image = Image.new(@width - 6, @font.size, COLOR[:select])
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
          self.target.drawFont(self.x + 2, self.y + @font.size * i + 2, str.to_s.within(@font, @width - 4), @font,{:color => COLOR[:font],:z => self.z})
        end
      end
      
      #resize時に@image変更
      def resize(width, height)
        super(width, height)
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
    
    ### ■プルダウンリストの設定■ ###
    def initialize(tx, ty, width, height, content = [])
      super(tx, ty, width, height)
      lx, ly = self.get_global_vertex
      @list = WSPullDownPopup.new(lx, ly + height, width, content, self)
      @image = {}
      refresh
      
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
    
    def set_image
      @image.each{|image| image.dispose if image.disposed?}
      
      @btn_image =Image.new(@height - 4, @height - 4, COLOR[:base]).triangle_fill(7, 11, 3, 4, 11, 4, COLOR[:font]).draw_border(true) # 暫定
      @active_image = Image.new(@width - @height - 2, @height - 6, COLOR[:select])
      
      @image[:usual] = Image.new(@width, @height, COLOR[:background]).draw_border(false)
      @image[:usual].draw(2 + @width - @height, 2, @btn_image)
      @image[:active] = @image[:usual].dup
      @image[:active].draw(3, 3, @active_image)
      refreshed
    end
    
    def resize(width, height)
      refresh
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

    def on_key_push(k)
      if k == K_ESCAPE
        if WS.captured?(@list)
          WS.capture(nil)
          WS.desktop.remove_control(@list)
        else
          super
        end
      else
        super
      end
    end
    
    def render
      set_image if refresh?
      self.image = @image[state] || @image[:usual]
      super
    end
    
    def draw
      super
      draw_caption
    end
    
    def draw_caption
      if self.item
        self.target.draw_font(self.x + 3, self.y + 3, item.to_s, @font, {:color => activated? ? COLOR[:font_reverse] : COLOR[:font],:z => self.z})
      end 
    end
    
    def item
      @list.content[@list.selected]
    end
    
    def index
      @list.selected
    end
    
    def index=(v)
      @list.selected = v
    end
    
    def change #新しく別のものが選択されたら呼ばれる。
      signal(:change, self.item, self.index)
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
 
