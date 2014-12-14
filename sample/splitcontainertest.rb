# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
require_relative '../lib/fontcache'

WS.set_theme("guibasic")

module WS
  class SeparatorTest < WSWindow
    def initialize
      super(0,0,560,400)
      # 垂直配置コンテナ
      scv = WSSplitContainer.new(nil,nil,nil,nil, :v)
      scv.separator_size = 8
      scv.space = 4
      scv.add_client(WSButton.new(0,0,72,72, "ボタンA"), :c_panel_d)
      scv.add_client(WSPanel.new(0,0,72,72, "パネルE"), :c_panel_e)
      scv.c_panel_d.min_height = 72
      scv.c_panel_e.min_height = 72
      # 水平配置コンテナ
      sch = WSSplitContainer.new
      sch.separator_size = 8
      sch.space = 4
      sch.add_client(WSLightContainer.new, :c_panel_a)
      sch.add_client(WSListBox.new, :c_panel_b)
      sch.add_client(WSLightContainer.new(0,0,72,24), :c_panel_c)
      sch.add_client(scv)
      sch.c_panel_a.min_width = 72
      sch.c_panel_b.min_width = 72
      sch.c_panel_c.min_width = 72
      # コンテナ要素の追加
      scv.c_panel_e.add_control(WSLabel.new(0,0,32,22,"チェックボックス"), :label_a)
      scv.c_panel_e.add_control(WSCheckBox.new(0,0,32,"チェックボックスA"), :checkbox_a)
      scv.c_panel_e.add_control(WSCheckBox.new(0,0,32,"チェックボックスB"), :checkbox_b)
      scv.c_panel_e.add_control(WSCheckBox.new(0,0,32,"チェックボックスC"), :checkbox_c)
      scv.c_panel_e.client.layout(:vbox) do
        self.space = 4
        add obj.label_a, true, false
        add obj.checkbox_a, true, false
        add obj.checkbox_b, true, false
        add obj.checkbox_c, true, false
        layout
      end
      sch.c_panel_a.add_control(WSLabel.new(0,0,32,22,"ラベルa"), :label_b)
      sch.c_panel_a.add_control(WSLabel.new(0,0,32,22,"ラベルb"), :label_c)
      sch.c_panel_a.add_control(WSLabel.new(0,0,32,22,"ラベルc"), :label_d)
      sch.c_panel_a.layout(:vbox) do
        self.space = 32
        add obj.label_b, true, false
        add obj.label_c, true, false
        add obj.label_d, true, false
        layout
      end
      # クライアントのオートレイアウト
      client.add_control(sch)
      client.layout(:hbox) do
        set_margin(8,8,8,8)
        add sch, true, true
      end
      
      # SplitContainerのレイアウト初期化
      sch.init_layout
      scv.init_layout
      
    end
  end
  
### セパレーター付きコンテナの定義 ###
class WSSplitContainer < WSContainer

  ### セパレータの定義 ###
  class WSSeparator < WSControl
    include Draggable 
    attr_accessor :client
    def initialize(x, y, width, height, client, type=:h)
      super(x, y, width, height)
      @client = client
      @type = type
      self.min_width  = 2
      self.min_height = 2
      init_handler
      set_image
    end
  	  
    def adjust_move_x(v)
      self.parent.width - (self.width + self.x + v) < 0 ? 0 : v
    end
  	  
    def adjust_move_y(v)
      self.parent.height - (self.height + self.y + v) < 0 ? 0 : v
    end
  	  
    def init_handler
      case @type
      when :h # 水平セパレータ
        add_handler(:drag_move) do |obj, x, y|
          # クライアント幅をリサイズ
          x = self.adjust_move_x(x)
      	  new_width = [@client.width + x, @client.min_width].max
          obj.x += x
          @client.resize(new_width, @client.height)
          obj.signal(:slide)
        end
      when :v # 垂直セパレータ
        add_handler(:drag_move) do |obj, x, y|
          y = self.adjust_move_y(y)
  	  new_height = [@client.height + y, @client.min_height].max
  	  obj.y += y
          @client.resize(@client.width, new_height)
  	  obj.signal(:slide)
  	end
      end
    end
    
    def set_image
      self.image.dispose if self.image
      self.image = Image.new(width, height, COLOR[:shadow])
    end
  	  
    def resize(width, height)
      super(width, height)
      set_image
    end
  end
    
  attr_reader   :clients
  attr_reader   :separators
  attr_accessor :space
    
  def initialize(x=nil, y=nil, width=nil, height=nil, type=:h)
    super(x, y, width, height)
    @type = type
    @clients = []
    @separators = []
    @separator_size = 8
    @space = 0
  end
  	
  # セパレーターサイズ
  def separator_size=(v)
    @separator_size = v
    @separators.each do |separator|
      separator.resize(@separator_size, @separator_size)
    end
  end
  	
  # クライアント追加
  def add_client(obj, name=nil)
    # セパレータの追加
    if @clients.size > 0
      separator = WSSeparator.new(0, 0, @separator_size, @separator_size, @clients.last, @type)
      separator.add_handler(:slide){ @layout.auto_layout }
      add_control(separator)
      @separators << separator
    end
    # クライアントサイズがnilの場合サイズ矯正
    obj.resize(obj.width || 16, obj.height || 16) if obj.width.nil? || obj.height.nil?
    # クライアントの追加
    add_control(obj, name)
      @clients << obj
    end
    
    # オートレイアウト
    def init_layout
      case @type
      when :h # 水平レイアウト
        layout(:hbox) do
          s = obj.clients.size-1
          self.space = obj.space
          for i in 0..s
            add obj.clients[i], (i == s), true
            add obj.separators[i], false, true if s > 0 && i != s
          end
        end
      when :v # 垂直レイアウト
        layout(:vbox) do
          s = obj.clients.size-1
          self.space = obj.space
          for i in 0..s
            add obj.clients[i], true, (i == s)
            add obj.separators[i], true, false if s > 0 && i != s
          end
        end
      end
    end
  end
  
end

w  = WS::SeparatorTest.new
WS.desktop.add_control w

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
  Window.caption = Window.get_load.to_s
end
