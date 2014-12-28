# coding: utf-8

module WS
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
