# coding: utf-8
require_relative './button'
require_relative './label'
require_relative './common'

module WS
  # システムモーダルなメッセージボックス
  class WSMessageBox < WSContainer
    # ウィンドウのタイトルバー用クラス
    class WSMessageBoxTitle < WSContainer
      def initialize(title="")
        @font = @@default_font
        super(nil, nil, nil, @font.size)
        self.image.bgcolor = [0, 0, 160]
        
        # ウィンドウタイトル
        label = WSLabel.new(nil, nil, nil, nil, title)
        label.fore_color = C_WHITE
        label.font = Font.new(@font.size - 2, @font.fontname, :weight=>true)
        add_control(label)
        
        # オートレイアウト
        layout(:hbox) do
          self.margin_top = self.margin_right = 1
          self.margin_left = 2
          add label
        end
      end
    end
    
    attr_reader :border_width, :window_focus, :message # ウィンドウ上のフォーカスを持つコントロール
    include WindowFocus
    include Focusable
    
    def initialize(caption = "", message, cancelable: true)
      @font = @@default_font
      @border_width = 3
      
      message_width = @font.get_width(message) + @border_width * 2 + 20 #20はmessageの左右に開けるスペース
      message_height = @font.size
      ok_width = @font.get_width("OK") + @border_width * 2 + 124
      ok_height = @font.get_width("OK") + 24
      caption_width = @font.get_width(caption) + @border_width * 2 + 4
      caption_height = @font.size
      
      sx = [message_width, ok_width, caption_width].max
      sy = message_height + ok_height + caption_height + 30 + @border_width
      tx = (WS.desktop.width - sx) / 2
      ty = (WS.desktop.height - sy) / 2
      
      super(tx, ty, sx, sy)
      self.image.bgcolor = COLOR[:base]
      @message = message
      
      window_title = WSMessageBoxTitle.new(caption)
      add_control(window_title, :window_title)
      
      message_label = WSLabel.new(nil, nil, nil, nil, @message)
      add_control(message_label, :message_label)
      
      btn = WSButton.new(nil,nil,nil,nil,"OK")
      add_control(btn, :btn)
      btn.add_handler(:click){self.close}
      btn.add_handler(:click_cancel){WS.capture(self, true)} # キャプチャが外れるのでしなおし
      
      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add window_title
        layout(:vbox) do
          self.margin_top = self.margin_bottom = self.space = 10
          self.margin_left = self.margin_right = 10
          add message_label
          layout(:vbox) do
            self.margin_left = self.margin_right = 40
            add btn
          end
        end
      end
      
      # Escで閉じる
      add_key_handler(K_ESCAPE){self.close} if cancelable
      
      # マウスキャプチャする
      WS.capture(self, true)
    end
    
    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      WS.capture(nil)
      super
    end
  end
end
