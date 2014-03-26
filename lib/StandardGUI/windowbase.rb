# coding: utf-8
require_relative './button'
require_relative './label'

module WS
  ### ■WSのウィンドウ用のスーパークラス■ ###
  class WSWindowBase < WSLightContainer

    ### ■ウィンドウ内容を描画するクライアント領域の定義■ ###
    class WSWindowClient < WSContainer
      def initialize(*)
        super
        self.image.bgcolor = C_GRAY
      end

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
      @caption      = caption
      @border_width = 3
      
      # クライアント領域は単純なコンテナである
      client = WSWindowClient.new(0, 0, sx - @border_width * 2, sy - @border_width * 2 - 16)
      add_control(client, :client)

      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add client, true, true
      end

      # Tabでフォーカス移動(キーハンドラ)
      add_key_handler(K_TAB) do
        if @window_focus
          tmp = self.get_focusable_control_ary
          tmp.reverse! unless Input.shift?
          tmp[tmp.index(@window_focus) - 1].activate
        end
      end
    end
  end
end
