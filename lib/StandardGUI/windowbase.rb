# coding: utf-8
require_relative './button'
require_relative './label'

module WS
  ### ■WSのウィンドウ用のスーパークラス■ ###
  class WSWindowBase < WSContainer
    ### ■ウィンドウのクローズボタン用クラス■ ###
    class WSWindowCloseButton < WSButton
      def initialize(*args)
        super
        @focusable = false
      end

      def set_image
        super
        @image[true].line(4, 4, @width-5, @height-5, C_BLACK)
                    .line(5, 4, @width-4, @height-5, C_BLACK)
                    .line(@width-5, 4, 4, @height-5, C_BLACK)
                    .line(@width-4, 4, 5, @height-5, C_BLACK)
        @image[false].line(4-1, 4-1, @width-5-1, @height-5-1, C_BLACK)
                    .line(5-1, 4-1, @width-4-1, @height-5-1, C_BLACK)
                    .line(@width-5-1, 4-1, 4-1, @height-5-1, C_BLACK)
                    .line(@width-4-1, 4-1, 5-1, @height-5-1, C_BLACK)
      end
    end
    
    ### ■ウィンドウのタイトルバー用クラス■ ###
    class WSWindowTitle < WSContainer
      include DoubleClickable # 最大化用
      include Draggable # ウィンドウのドラッグ用
  
      def initialize(tx, ty, width, height, title="")
        super(tx, ty, width, height)
        self.image.bgcolor = [0, 0, 160]
  
        # タイトルバーのクロースボタン
        close_button = WSWindowCloseButton.new(0, 0, height-2, height-2, "")
        close_button.fore_color = C_BLACK
        add_control(close_button)
        close_button.add_handler(:click) {signal(:close)}
  
        # ウィンドウタイトル
        label = WSLabel.new(0, 0, width, height, title)
        label.fore_color = C_WHITE
        label.font = Font.new(14, nil, :weight=>true)
        add_control(label)

        add_handler(:doubleclick) do
          @dragging_flag = false
        end

        # オートレイアウト
        layout(:hbox) do
          self.margin_top = self.margin_right = 1
          self.margin_left = 2
          add label, true
          add close_button
        end
      end
    end

    ### ■ウィンドウ内容を描画するクライアント領域の定義■ ###
    class WSWindowClient < WSContainer
      def add_control(obj, name=nil)
        super
        self.activate
      end
    end

    ### ■ウィンドウの定義■ ###
    
    # Mix-In
    include WindowFocus
    include Focusable

    # 公開インスタンス
    attr_accessor :border_width # ウィンドウボーダーの幅
    attr_reader   :window_focus # ウィンドウ上のフォーカスを持つコントロール

    # 初期化
    def initialize(tx, ty, sx, sy, caption = "WindowTitle")
      super(tx, ty, sx, sy)
      self.image.bgcolor = C_GRAY
      @caption      = caption
      @border_width = 3
      
      create_client
      
      # Tabでフォーカス移動(キーハンドラ)
      add_key_handler(K_TAB) do
        if @window_focus
          tmp = client.get_focusable_control_ary
          tmp.reverse! unless Input.shift?
          tmp[tmp.index(@window_focus) - 1].activate
        end
      end
    end
    
    # クライアント領域の作成
    def create_client
      # クライアント領域は単純なコンテナである
      client = WSWindowClient.new(@border_width, @border_height, @width - @border_width * 2, @height - @border_width * 2)
      add_control(client, :client)
    end
    
    # コントロール画像の描画
    def draw
      super
    end
        
  end
end