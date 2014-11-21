# coding: utf-8
require_relative './button'
require_relative './label'

module WS
  ### ■WSのウィンドウ用のスーパークラス■ ###
  class WSWindowBase < WSLightContainer

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
      @border_width = default_border_width
      
#      # オートレイアウトでコントロールの位置を決める
#      # Layout#objで元のコンテナを参照できる
#      layout(:vbox) do
#        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
#        add client, true, true
#      end

      # Tabでフォーカス移動(キーハンドラ)
      add_key_handler(K_TAB) do
        if @window_focus
          tmp = self.get_focusable_control_ary
          tmp.reverse! unless Input.shift?
          tmp[tmp.index(@window_focus) - 1].activate
        end
      end
    end
    
    # ボーダー幅のデフォルト値
    def default_border_width
      return 3	
    end
    
  end
end
