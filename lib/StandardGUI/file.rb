# coding: utf-8

require_relative './dialogbase'
require_relative './scrollbar'

module WS
  module WSFile
    @@current_directory = File.dirname($0)
    
    def self.current_directory
      @@current_directory
    end
    
    def self.current_directory=(v)
      @@current_directory = File.expand_path(v) if Dir.exist?(v)
    end
    
    def self.open(tx=nil, ty=nil, sx=nil, sy=nil, filter, title, directory: nil)
      WSOpenFilename.new(tx, ty, sx, sy, filter, title, directory: directory)
    end
    
    def self.save(tx=nil, ty=nil, sx=nil, sy=nil, filter, title, directory: nil)
      WSSaveFilename.new(tx, ty, sx, sy, filter, title, directory: directory)
    end
    
    class WSFileFilter
      include Enumerable
      
      def initialize(filter)
        @data = filter
        
        return @pattern = [/.*/] if filter.empty?
        return @pattern = filter.flat_map{|ary| ary[1..-1]}.uniq if filter.any?{|ary| ary[0] == ''}
        
        @index = 0
      end
      
      def each
        if @pattern
          @pattern.each{|rx| yield rx}
        else
          @data[@index][1..-1].each{|rx| yield rx}
        end
      end
      
      def list
        return nil if @pattern
        @data.map{|ary| ary[0]}
      end
      
      def set_index(i)
        return nil if @pattern
        @index = i % @data.size
      end
    end
    
    class WSFileItem < WSLabel
      include Focusable
      
      attr_reader :absolute_path, :basename
      
      include ButtonClickable
      include DoubleClickable
      
      def initialize(absolute_path, dialog)
        @absolute_path = absolute_path
        @basename = File.basename(absolute_path)
        @directory = File.directory?(absolute_path)
        @dialog = dialog
        
        @font = @@default_font
        
        super(nil,nil,nil,@font.size,@basename)
        
        self.collision_enable = true
        
        add_key_handler(K_RETURN){on_doubleclick(0,0)}
      end
      
      def directory?
        @directory
      end
      
      def on_doubleclick(tx, ty)
        if @directory
          @dialog.set_directory(@absolute_path)
        else
          @dialog.select(self)
          @dialog.exit_dialog
        end
        
        super
      end
      
      def on_enter
        @dialog.select(self)
        refresh
        super
      end
      
      def on_leave
        refresh
        super
      end
      
      # 画像の作成
      def render
        if refresh?
          width = @font.get_width(@caption)
          case state
          when :active
            self.image.fill(COLOR[:select])
            self.image.draw_font_ex(0, @height / 2 - @font.size / 2,
                                    @caption, @font, {:color=>COLOR[:font_reverse], :aa=>false})
          else
            self.image.clear
            self.image.draw_font_ex(0, @height / 2 - @font.size / 2,
                                    @caption, @font, {:color=>@fore_color, :aa=>false})
          end
          
          refreshed
        end
      end
    end
    
    class WSFileItemArea < WSContainer
      def initialize
        super
        
        self.image.bgcolor = COLOR[:background]
        
        @v_pos = 0
        @h_pos = 0
      end
      
      def set_list(list)
        @children.each(&:vanish)
        @children.clear
        
        list.each.with_index do |item, index|
          add_control(item)
          item.activate if index == 0
          item.x = 1
          item.y = (@font.size + 1) * index + 1
        end
        
        @parent.vsb.total_size = (1 + @font.size) * @children.size + 1
        @parent.hsb.total_size = @children.empty? ? 2 : @children.map{|ctl| @font.get_width(ctl.basename)}.max + 2
        
        list.each do |item|
          item.resize([@parent.hsb.total_size, self.width].max - 2, @font.size)
        end
        
        @parent.resize(@parent.width, @parent.height)
        @parent.vsb.pos = @v_pos = 0
        @parent.hsb.pos = @h_pos = 0
        @parent.hsb.shift_qty = 5
        @parent.vsb.shift_qty = @font.size + 1
        
        self
      end
      
      def update
        if @v_pos != @parent.vsb.pos
          @children.each do |item|
            item.y += @v_pos
            item.y -= @parent.vsb.pos
          end
          
          @v_pos = @parent.vsb.pos
        end
        
        if @h_pos != @parent.hsb.pos
          @children.each do |item|
            item.x += @h_pos
            item.x -= @parent.hsb.pos
          end
          
          @h_pos = @parent.hsb.pos
        end
        
        super
      end
      
      def next_of(item)
        return item unless i = @children.index(item)
        @children[(i + 1).clamp(0, @children.size - 1)]
      end
      
      def previous_of(item)
        return item unless i = @children.index(item)
        @children[(i - 1).clamp(0, @children.size - 1)]
      end
      
      def search_basename(path)
        @children.find{|item| item.basename == path}
      end
    end
    
    class WSMainScrollableContainer < WSScrollableContainer
      def initialize(client)
        super(nil,nil,nil,nil,client)
      end
    end
    
    class WSFileDialogBase < WSDialogBase
      def initialize(tx=nil, ty=nil, sx=nil, sy=nil, filter, title, directory: nil)
        super(tx, ty, sx, sy, title, close_button: true)
        
        set_directory(directory)
        @filter = WSFileFilter.new(filter)
        @result = nil
        
        @fileItemArea = WSFileItemArea.new
        add_control(WSMainScrollableContainer.new(@fileItemArea), :main_area)
        
        add_control(WSLightContainer.new(nil,nil,nil,@font.size + 2), :directory_label_container)
        directory_label_container.add_control(WSLabel.new(nil,nil,nil,@font.size), :directory_label)
        directory_label_container.layout(:hbox) do
          self.margin_left = 5
          add obj.directory_label
        end
        
        
        add_key_handler(K_BACKSPACE) do
          Dir.chdir(@directory) do
            set_directory(File.expand_path('..'))
          end
        end
        
        add_key_handler(K_ESCAPE) do
          close
        end
        
        add_key_handler(K_UP) do
          main_area.client.previous_of(@result).activate
        end
        
        add_key_handler(K_DOWN) do
          main_area.client.next_of(@result).activate
        end
        
        WS.capture(self, true)
      end
      
      def update
        self.activate
        @fileItemArea.set_list(@file_list.map{|path| WSFileItem.new(path, self)}) unless @file_list == (@file_list = get_list)
        directory_label_container.directory_label.caption = 'viewing: ' + @directory
        super
      end
      
      def select(item)
        @result = item
        under_container.textbox_container.textbox.text = item.basename.dup
      end
      
      def exit_dialog
        @result = @result.absolute_path
        signal(:submit, @result)
        close
      end
      
      def close
        WS.capture(nil)
        super
      end
      
      def set_directory(path)
        return @directory = @directory || WS::WSFile.current_directory unless path
        return @directory = path if Dir.exist?(path)
        @directory = @directory || WS::WSFile.current_directory
      end
      
      def get_list
        Dir.chdir(@directory) do
          return Dir.glob('*').select{|path| File.directory?(path) || @filter.any?{|rx| path =~ rx}}.map{|path| File.expand_path(path)}.sort_by{|path| File.directory?(path) ? 0 : 1}
        end
      end
    end
    
    class WSOpenFilename < WSFileDialogBase
      def initialize(tx=nil, ty=nil, sx=nil, sy=nil, filter, title, directory: nil)
        super(tx, ty, sx, sy, filter, title, directory: directory)
        
        if list = @filter.list
          add_control(WSLightContainer.new(nil,nil,nil,@font.size * 2 + 16), :under_container)
          
          under_container.add_control(WSLightContainer.new, :textbox_container)
          under_container.textbox_container.add_control(WSTextBox.new(nil,nil,nil,font.size + 6), :textbox)
          under_container.textbox_container.layout(:hbox) do
            add obj.textbox
          end
          
          under_container.add_control(WSLightContainer.new, :button_container)
          under_container.button_container.add_control(WSPullDownList.new(nil,nil,nil,@font.size + 6, list), :filter_list).add_handler(:change){|list| @filter.set_index(list.index)}
          under_container.button_container.add_control(WSButton.new(nil,nil,nil,@font.size + 6,'開く'), :submit).add_handler(:click){
            item = main_area.client.search_basename(under_container.textbox_container.textbox.text)
            item.on_doubleclick(0,0) if item
          }
          under_container.button_container.layout(:vbox) do
            self.space = 2
            add obj.filter_list
            add obj.submit
          end
          
          under_container.layout(:hbox) do
            self.margin_left = self.margin_right = self.margin_top = self.margin_bottom = 1
            self.space = 2
            add obj.textbox_container
            add obj.button_container
          end
        else
          add_control(WSLightContainer.new(nil,nil,nil,@font.size + 8), :under_container)
          
          under_container.add_control(WSLightContainer.new, :textbox_container)
          under_container.textbox_container.add_control(WSTextBox.new(nil,nil,nil,font.size + 6), :textbox)
          under_container.textbox_container.layout(:hbox) do
            add obj.textbox
          end
          
          under_container.add_control(WSLightContainer.new, :button_container)
          under_container.button_container.add_control(WSButton.new(nil,nil,nil,@font.size + 6,'開く'), :submit).add_handler(:click){
            item = main_area.client.search_basename(under_container.textbox_container.textbox.text)
            item.on_doubleclick(0,0) if item
          }
          under_container.button_container.layout(:vbox) do
            add obj.submit
          end
          
          under_container.layout(:hbox) do
            self.margin_left = self.margin_right = self.margin_top = self.margin_bottom = 1
            self.space = 2
            add obj.textbox_container
            add obj.button_container
          end
        end
        
        
        client.layout(:vbox) do
          add obj.directory_label_container
          add obj.main_area
          add obj.under_container
        end
      end
    end
    
    class WSSaveFilename < WSFileDialogBase
      def initialize(tx=nil, ty=nil, sx=nil, sy=nil, filter, title, directory: nil)
        super(tx, ty, sx, sy, filter, title, directory: directory)
        
        if list = @filter.list
          add_control(WSLightContainer.new(nil,nil,nil,@font.size * 2 + 16), :under_container)
          
          under_container.add_control(WSLightContainer.new, :textbox_container)
          under_container.textbox_container.add_control(WSTextBox.new(nil,nil,nil,font.size + 6), :textbox)
          under_container.textbox_container.layout(:hbox) do
            add obj.textbox
          end
          
          under_container.add_control(WSLightContainer.new, :button_container)
          under_container.button_container.add_control(WSPullDownList.new(nil,nil,nil,@font.size + 6, list), :filter_list).add_handler(:change){|list| @filter.set_index(list.index)}
          under_container.button_container.add_control(WSButton.new(nil,nil,nil,@font.size + 6,'保存'), :submit).add_handler(:click){
            item = main_area.client.search_basename(str = under_container.textbox_container.textbox.text)
            if item
              item.on_doubleclick(0,0)
            else
              Dir.chdir(@directory) do
                str = File.expand_path(str)
              end
              signal(:submit, str)
              close
            end
          }
          under_container.button_container.layout(:vbox) do
            self.space = 2
            add obj.filter_list
            add obj.submit
          end
          
          under_container.layout(:hbox) do
            self.margin_left = self.margin_right = self.margin_top = self.margin_bottom = 1
            self.space = 2
            add obj.textbox_container
            add obj.button_container
          end
        else
          add_control(WSLightContainer.new(nil,nil,nil,@font.size + 8), :under_container)
          
          under_container.add_control(WSLightContainer.new, :textbox_container)
          under_container.textbox_container.add_control(WSTextBox.new(nil,nil,nil,font.size + 6), :textbox)
          under_container.textbox_container.layout(:hbox) do
            add obj.textbox
          end
          
          under_container.add_control(WSLightContainer.new, :button_container)
          under_container.button_container.add_control(WSButton.new(nil,nil,nil,@font.size + 6,'開く'), :submit).add_handler(:click){
            item = main_area.client.search_basename(str = under_container.textbox_container.textbox.text)
            if item
              item.on_doubleclick(0,0)
            else
              Dir.chdir(@directory) do
                str = File.expand_path(str)
              end
              signal(:submit, str)
              close
            end
          }
          under_container.button_container.layout(:vbox) do
            add obj.submit
          end
          
          under_container.layout(:hbox) do
            self.margin_left = self.margin_right = self.margin_top = self.margin_bottom = 1
            self.space = 2
            add obj.textbox_container
            add obj.button_container
          end
        end
        
        
        client.layout(:vbox) do
          add obj.directory_label_container
          add obj.main_area
          add obj.under_container
        end
      end
      
      def exit_dialog
        close
        cfm = WS.desktop.add_control(WSConfirmBox.new('Sure to overwrite?', @result.basename + 'は既に存在します。上書きしますか？'))
        cfm.add_handler(:yes){signal(:submit, @result = @result.absolute_path)}
        cfm.add_handler(:no){WS.capture(self,true);@parent.add_control(self)}
      end
    end
  end
end

#sample
#WS.desktop.add_control(tmp = WS::WSFile.save([['Ruby File', /\.rb$/], ['PNG image', /\.png$/]], "Title")).add_handler(:submit){|ctl, path| p path}
#WS.desktop.instance_eval do
#  layout(:hbox) do
#    add tmp
#  end
#  @layout.auto_layout
#end
