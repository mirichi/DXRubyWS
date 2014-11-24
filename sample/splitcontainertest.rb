# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
require_relative '../lib/fontcache'

module WS
  class SeparatorTest < WSWindow
    def initialize
      super(100,100,400,300)
      sch = WSSplitContainerH.new(4,8,384, 260)
      scv = WSSplitContainerV.new(4,8,384, 260)
      
      client.add_control(sch)
      sch.client_b.add_control(scv)
      
      sch.client_a.add_control(b1 = WSButton.new(50,50,100,20))
      scv.client_b.add_control(b2 = WSButton.new(100,100,100,20))
      b1.add_handler(:click) {|obj, tx, ty|self.button1_click(tx, ty)}
      b2.add_handler(:click) {|obj, tx, ty|self.button2_click(tx, ty)}

      sch.client_a.add_control(t1 = WSTextBox.new(50,130,100,20))

      sch.client_a.layout(:vbox) do
      	self.set_margin(16,16,16,16)
        add b1, true, false
        add t1, true, false
      end
      sch.client_b.layout(:hbox) do
      	self.set_margin(0,0,0,0)
      	add scv, true, true
      end
      scv.client_b.layout(:hbox) do
      	self.set_margin(16,16,16,16)
      	add b2, false, false
      	layout
      end
      
      
    end

    def button1_click(tx, ty)
      WS.desktop.add_control(WS::WSMessageBox.new("MessageBoxTest", "メッセージボックステスト1"))
    end
    def button2_click(tx, ty)
      WS.desktop.add_control(WS::WSMessageBox.new("MessageBoxTest", "メッセージボックステスト2"))
    end
  end
  
  
  ### セパレーター付きコンテナの定義 ###
  class WSSplitContainerH < WSContainer
  	class WSClient < WSContainer
  	  def initialize(x, y, width, height)
  	  	super
  	  	self.image.bgcolor = COLOR[:highlight]
  	  end
    end
  	
  	class WSSeparator < WSControl
  		include Draggable 
  		attr_accessor :client
  	  def initialize(x, y, width, height)
  	  	super
  	  	self.image = Image.new(width, height, COLOR[:shadow])
  	  end
    end
    
  	def initialize(x, y, width, height)
  		super
  		create_controls
  	end
  	
  	def create_controls
      add_control(WSClient.new(0, 0, width / 2, height), :client_a)
      add_control(WSClient.new(0, 0, width / 2, height), :client_b)
      add_control(WSSeparator.new(0, 0, 8, height), :c_separator)
    	c_separator.add_handler(:drag_move) do |obj, x|
  	    obj.x = (obj.x + x).clamp(64, width - 64)
  	    client_a.resize(obj.x - client_a.x, client_a.height)
  	    obj.signal(:slide)
  	  end
      c_separator.add_handler(:slide){  @layout.auto_layout }
      # オートレイアウト
      layout(:hbox) do
      	add obj.client_a, false, true 
      	add obj.c_separator, false, true
      	add obj.client_b, true, true
      end
  	end
  end
  
  ### セパレーター付きコンテナの定義 ###
  class WSSplitContainerV < WSContainer
  	class WSClient < WSContainer
  	  def initialize(x, y, width, height)
  	  	super
  	  	self.image.bgcolor = COLOR[:highlight]
  	  end
    end
  	
  	class WSSeparator < WSControl
  		include Draggable 
  		attr_accessor :client
  	  def initialize(x, y, width, height)
  	  	super
  	  	self.image = Image.new(width, height, COLOR[:shadow])
  	  end
    end
    
  	def initialize(x, y, width, height)
  		super
  		create_controls
  	end
  	
  	def create_controls
      add_control(WSClient.new(0, 0, width, height / 2), :client_a)
      add_control(WSClient.new(0, 0, width, height / 2), :client_b)
      add_control(WSSeparator.new(0, 0, width, 8), :c_separator)
    	c_separator.add_handler(:drag_move) do |obj, x, y|
  	    obj.y = (obj.y + y).clamp(64, height - 64)
  	    client_a.resize(client_a.height ,obj.y - client_a.y)
  	    obj.signal(:slide)
  	  end
      c_separator.add_handler(:slide){  @layout.auto_layout }
      # オートレイアウト
      layout(:vbox) do
      	add obj.client_a, true, false 
      	add obj.c_separator, true, false
      	add obj.client_b, true, true
      end
  	end
  end
  
end

w = WS::SeparatorTest.new
WS.desktop.add_control w

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
  Window.caption = Window.get_load.to_s
end






