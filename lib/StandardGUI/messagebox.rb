# coding: utf-8
require_relative './button'
require_relative './dialogbase'
require_relative './label'
require_relative './common'

module WS
  # システムモーダルなメッセージボックス
  class WSMessageBox < WSDialogBase
    
    attr_reader :message # ウィンドウ上のフォーカスを持つコントロール
    
    def initialize(caption = "", message, **style)
      @font = @@default_font
      
      message_width = @font.get_width(message) + default_border_width * 2 + 20 #20はmessageの左右に開けるスペース
      message_height = @font.size
      ok_width = @font.get_width("OK") + default_border_width * 2 + 124
      ok_height = @font.size + 24
      caption_width = WSWindow::WSWindowTitle.title_font.get_width(caption) + default_border_width * 2 + window_title_height + 1
      caption_height = window_title_height
      
      sx = [message_width, ok_width, caption_width].max
      sy = message_height + ok_height + caption_height + 30 + default_border_width
      tx = (WS.desktop.width - sx) / 2
      ty = (WS.desktop.height - sy) / 2
      
      super(tx,ty,sx,sy,caption,style)
      @message = message
      
      message_label = WSLabel.new(nil, nil, @font.get_width(@message), nil, @message)
      add_control(message_label, :message_label)
      
      btn = WSButton.new(nil,nil,nil,nil,"OK")
      add_control(btn, :btn)
      btn.add_handler(:click){self.close}
      
      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      client.layout(:vbox) do
        self.margin_top = self.margin_bottom = self.space = 10
        self.margin_left = self.margin_right = 10
        add message_label
        layout(:hbox) do
          self.margin_left = self.margin_right = 40
          add btn
        end
      end
      
      # マウスキャプチャする
      WS.capture(self, true, true)
      
      # ボタンにフォーカスを当てる
      btn.activate
    end
    
    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      WS.release_capture
      super
    end
  end
end
