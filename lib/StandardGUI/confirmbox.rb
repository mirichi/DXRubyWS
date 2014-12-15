# coding: utf-8
require_relative './button'
require_relative './dialogbase'
require_relative './label'
require_relative './common'

module WS
  # システムモーダルな確認ボックス
  class WSConfirmBox < WSDialogBase
    
    attr_reader :border_width, :window_focus, :message, :result # ウィンドウ上のフォーカスを持つコントロール
    
    def initialize(caption = "", message, **style)
      @font = @@default_font
      
      message_width = @font.get_width(message) + default_border_width * 2 + 20 #20はmessageの左右に開けるスペース
      message_height = @font.size
      btn_width = @font.get_width("YES") + @font.get_width("NO") + default_border_width * 2 + 50
      btn_height = @font.size + 24
      caption_width = WSWindow::WSWindowTitle.title_font.get_width(caption) + default_border_width * 2 + window_title_height + 1
      caption_height = window_title_height
      
      sx = [message_width, btn_width, caption_width].max
      sy = message_height + btn_height + caption_height + 30 + default_border_width
      tx = (WS.desktop.width - sx) / 2
      ty = (WS.desktop.height - sy) / 2
      
      super(tx, ty, sx, sy, caption, style)
      @message = message
      @result = nil
      
      message_label = WSLabel.new(nil, nil, @font.get_width(@message), nil, @message)
      add_control(message_label, :message_label)
      
      btn_yes = WSButton.new(nil,nil,nil,nil,"YES")
      add_control(btn_yes, :btn_yes)
      btn_yes.add_handler(:click){@result = true;self.signal(:yes);self.close}
      btn_yes.add_handler(:click_cancel){WS.capture(self, true)} # キャプチャが外れるのでしなおし
      
      btn_no = WSButton.new(nil,nil,nil,nil,"NO")
      add_control(btn_no, :btn_no)
      btn_no.add_handler(:click){@result = false;self.signal(:no);self.close}
      btn_no.add_handler(:click_cancel){WS.capture(self, true)} # キャプチャが外れるのでしなおし
      
      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      client.layout(:vbox) do
        self.margin_top = self.margin_bottom = self.space = 10
        self.margin_left = self.margin_right = 10
        add message_label
        layout(:hbox) do
          self.margin_left = self.margin_right = 5
          self.space = 20
          add btn_yes
          add btn_no
        end
      end
      
      # マウスキャプチャする
      WS.capture(self, true)
      
      # yesにフォーカスをあてる
      btn_yes.activate
    end
    
    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      WS.capture(nil)
      super
    end
  end
end
