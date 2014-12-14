# coding: utf-8

module WS
  module WindowFrameBasic
    ### フレーム画像の作成 ###
    @@frameimg = {:activated => {}, :deactivated => {}}
    
    # 画像の読み込み
    frame_shader = Shader_WindowFrame.new(COLOR[:windowframe_high], COLOR[:windowframe_low])
    frame_render = RenderTarget.new(40, 80)
    frame_tmpimg = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAACAAAABQBAMAAACKdmoGAAAAG1BMVEXV78oAAAAZGRkyMjJQUFCAgICkpKTIyMj////szmG6AAAAAXRSTlMAQObYZgAAAFpJREFUeJxjYGAQRAIMQCCY3gEHZUARxvRQJJAiwMBYiiwQJsAgFooCHBnE0QUkUAUMRwUwBYKMocAVKhDMAAWtowKjAqMChARCYKVWKc2yqbAxCjBEKTxBAADWqQvgFYNF4QAAAABJRU5ErkJggg==".unpack('m')[0])
    
    # カラーの焼き込み
    frame_img = frame_render.draw_shader(0, 0, frame_tmpimg, frame_shader).to_image
    
    # 画像の分割
    # アクティブ時
    @@frameimg[:activated][:windowframe_up]          = Image.new(1,24).draw(0, 0, frame_img, 16, 0, 1, 24)
    @@frameimg[:activated][:windowframe_low]         = Image.new(1,8).draw(0, 0, frame_img, 16, 72, 1, 8)
    @@frameimg[:activated][:windowframe_left]        = Image.new(8,48).draw(0, 0, frame_img, 0, 24, 8, 48)
    @@frameimg[:activated][:windowframe_right]       = Image.new(8,48).draw(0, 0, frame_img, 24, 24, 8, 48)
    @@frameimg[:activated][:windowframe_upper_left]  = Image.new(16,24).draw(0, 0, frame_img, 0, 0, 16, 24)
    @@frameimg[:activated][:windowframe_upper_right] = Image.new(16,24).draw(0, 0, frame_img, 16, 0, 16, 24)
    @@frameimg[:activated][:windowframe_lower_left]  = Image.new(8,8).draw(0, 0, frame_img, 0, 72, 8, 8)
    @@frameimg[:activated][:windowframe_lower_right] = Image.new(8,8).draw(0, 0, frame_img, 24, 72, 8, 8)
    # 非アクティブ時
    @@frameimg[:activated].each{|key, value| @@frameimg[:deactivated][key] = value.change_hls(0, 6, -10)}
    
    # 作業オブジェクトの開放
    frame_tmpimg.dispose
    frame_render.dispose
    frame_img.dispose
  end
	
  class WSWindow
  	
    # MixIn
    include WindowFrameBasic
  	
    ### ■ウィンドウ内容を描画するクライアント領域の定義■ ###
    class WSWindowClient < WSContainer
    end
    
    ### ■ウィンドウのクローズボタン用クラス■ ###
    class WSWindowCloseButton < WSButton
      # ボタン画像をキャッシュ
      IMG_CACHE[:windowbutton_close_usual]      = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABgAAAAQCAMAAAA7+k+nAAADAFBMVEXV78oAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlJTZZYnVtip2CssbB19kAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADG3uIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABibItqh5yWsMaeuM2mwNSuyNu20OK/2ekAAAC91+DK3+bX5+zk7/Lx9/iq0+AAAAAlMpk2VaAuPu4pUO0jZu0eeuwYkOwUouoAAABTtPF0w/KW1PS45fbZ9vkUzeoAAACYQibPa3C/IhHGMSTPQTXbUUXmYFTyb2QAAADxU3XydJH0lq/2uMz52en4qrMAAAASFCoeJDYbI38aK3oZNnUiPZQaXZ8gfLsAAAAibaAqgro3m9FYsN55zekiv+AAAAAqFxJ5P0FAEg5OHRpcKSZ1LimOMCqvLiUAAACgIju6KknRN13UWH/XeajaRlQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADN9NwbAAAAAXRSTlMAQObYZgAAAHdJREFUeJxtkFsOgCAQAzecqKBiROX+x5J28ZUwHzTdSSCsGYaYIdYBEYZ6DqgUh8AvJHaCgE/sEqWBEAKeKEViIxrpUHWRCIecq7hI6TXoRWJyXPQiMYv7Km8SC3kfV5XIDY2eyFliJe1nn1gp+hLxi8j1jtd+AfTSRqn4Ce2mAAAAAElFTkSuQmCC".unpack('m')[0])
      IMG_CACHE[:windowbutton_close_pushed]     = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABgAAAAQCAMAAAA7+k+nAAADAFBMVEXV78oAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlJTZZYnVtip2CssbB19kAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADG3uIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABibItqh5yWsMaeuM2mwNSuyNu20OK/2ekAAAC91+DK3+bX5+zk7/Lx9/iq0+AAAAAlMpk2VaAuPu4pUO0jZu0eeuwYkOwUouoAAABTtPF0w/KW1PS45fbZ9vkUzeoAAACYQibPa3C/IhHGMSTPQTXbUUXmYFTyb2QAAADxU3XydJH0lq/2uMz52en4qrMAAAASFCoeJDYbI38aK3oZNnUiPZQaXZ8gfLsAAAAibaAqgro3m9FYsN55zekiv+AAAAAqFxJ5P0FAEg5OHRpcKSZ1LimOMCqvLiUAAACgIju6KknRN13UWH/XeajaRlQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADN9NwbAAAAAXRSTlMAQObYZgAAAHlJREFUeJxtkFsOgCAMBBtOxNEKKkZQzi67xQcJ88FmOwmEivgpIj7UCcGLr9eECnESHYKiAHX6i0KRG+qc0zdypjgARzxYTUSAIeYsJmL8jPZCsRgmeqFYyXOVNYoNfI+zUqQGR2+kRLGD9rNf7BB9iTpEwHrna78B696HqfettZgAAAAASUVORK5CYII=".unpack('m')[0])
      IMG_CACHE[:windowbutton_close_mouse_over] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABgAAAAQCAMAAAA7+k+nAAADAFBMVEXV78oAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlJTZZYnVtip2CssbB19kAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADG3uIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABibItqh5yWsMaeuM2mwNSuyNu20OK/2ekAAAC91+DK3+bX5+zk7/Lx9/iq0+AAAAAlMpk2VaAuPu4pUO0jZu0eeuwYkOwUouoAAABTtPF0w/KW1PS45fbZ9vkUzeoAAACYQibPa3C/IhHGMSTPQTXbUUXmYFTyb2QAAADxU3XydJH0lq/2uMz52en4qrMAAAASFCoeJDYbI38aK3oZNnUiPZQaXZ8gfLsAAAAibaAqgro3m9FYsN55zekiv+AAAAAqFxJ5P0FAEg5OHRpcKSZ1LimOMCqvLiUAAACgIju6KknRN13UWH/XeajaRlQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADN9NwbAAAAAXRSTlMAQObYZgAAAHpJREFUeJxtkFsOgCAMBBtOxFEKKkZQ7n8M2S0+SJgPNttJIFTETxHxoU4IXny9JlSIk+gQFAWo018UitxQ55y+kTPFATjiwWoiAgwxZzER42e0F4rFMNELxUqeq6xRbOB7nJUiNTh6IyWKHbSf/WKH6EvUIQLWO1/7DfBYZylt9mJ5AAAAAElFTkSuQmCC".unpack('m')[0])
      
      def initialize(*args)
        super
        @focusable = false
        resize(24,16)
      end
      
      # イメージをセット
      def set_image
        # 通常時の画像を作成
        @image[:usual]  = IMG_CACHE[:windowbutton_close_usual]
        # 押下時の画像を作成
        @image[:pushed] = IMG_CACHE[:windowbutton_close_pushed]
        # マウスオーバー時の画像を作成
        @image[:mouse_over] = IMG_CACHE[:windowbutton_close_mouse_over]
        # アクティブ時の画像を作成
        @image[:active] = IMG_CACHE[:windowbutton_close_mouse_over]
        refreshed
      end
      
      # コントロールの状態を判定しシンボルを返す
      def state
        if !@enabled
          :disable
        elsif @pushed
          :pushed
        elsif @mouse_over
          :mouse_over
        elsif @active or parent.parent.activated?
          :active
        else
          :usual
        end
      end
      
      # シェーダーをセットする
      def set_shader
        nil
      end
    end
    
    ### ■ウィンドウのタイトルバー用クラス■ ###
    class WSWindowTitle < WSContainer
      def render
        super
      end
    end
    
    # オートレイアウト
    def init_layout
      layout(:vbox) do
        self.margin_top = 2
        self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add obj.window_title
        add obj.client
      end
    end
    
    # メニューバー付きレイアウト
    def add_menubar(menuitems)
      add_control(WSMenuBar.new(menuitems), :menubar)
      layout(:vbox) do
        self.margin_top = 2
        self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add obj.window_title, true
        add obj.menubar, true
        add obj.client, true, true
      end
    end
    
    # ボーダー幅のデフォルト値
    def default_border_width
      return 8
    end
    
    # ウィンドウタイトルの高さ
    def window_title_height
      return 22
    end
    
    # コントロール画像の描画
    def render
      super
    end
    
    def draw
      sx = self.x
      ex = self.x + self.width
      sy = self.y
      ey = self.y + self.height
      faw, fah, fbw, fbh, fcw, fch = 16, 24, 8, 48, 8, 8
      rate = (self.height - fah - fch) / 1.0 / fbh
      frameimg = activated? ? @@frameimg[:activated] : @@frameimg[:deactivated]
      self.target.draw(sx, sy, frameimg[:windowframe_upper_left])
      self.target.draw(ex-faw, sy, frameimg[:windowframe_upper_right])
      self.target.draw(sx, ey-fch, frameimg[:windowframe_lower_left])
      self.target.draw(ex-fcw, ey-fch, frameimg[:windowframe_lower_right])
      self.target.draw_scale(sx+faw, sy, frameimg[:windowframe_up],self.width - faw * 2,1,0,0)
      self.target.draw_scale(sx+fcw, ey-fch, frameimg[:windowframe_low],self.width - fcw * 2,1,0,0)
      self.target.draw_scale(sx, sy+fah, frameimg[:windowframe_left],1,rate,0,0)
      self.target.draw_scale(ex-fbw, sy+fah, frameimg[:windowframe_right],1,rate,0,0)
      super
    end
    
  end
  
  # ダイアログボックスのスーパークラス
  class WSDialogBase

    # MixIn
    include WindowFrameBasic
	  
    # オートレイアウト
    def init_layout
      layout(:vbox) do
        self.margin_top = 2
        self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add obj.window_title
        add obj.client
      end
    end
	  
    # ボーダー幅のデフォルト値
    def default_border_width
      return 8
    end
    
    # ウィンドウタイトルの高さ
    def window_title_height
      return 22
    end
	  
    def draw
      sx = self.x
      ex = self.x + self.width
      sy = self.y
      ey = self.y + self.height
      faw, fah, fbw, fbh, fcw, fch = 16, 24, 8, 48, 8, 8
      rate = (self.height - fah - fch) / 1.0 / fbh
      frameimg = activated? ? @@frameimg[:activated] : @@frameimg[:deactivated]
      self.target.draw(sx, sy, frameimg[:windowframe_upper_left])
      self.target.draw(ex-faw, sy, frameimg[:windowframe_upper_right])
      self.target.draw(sx, ey-fch, frameimg[:windowframe_lower_left])
      self.target.draw(ex-fcw, ey-fch, frameimg[:windowframe_lower_right])
      self.target.draw_scale(sx+faw, sy, frameimg[:windowframe_up],self.width - faw * 2,1,0,0)
      self.target.draw_scale(sx+fcw, ey-fch, frameimg[:windowframe_low],self.width - fcw * 2,1,0,0)
      self.target.draw_scale(sx, sy+fah, frameimg[:windowframe_left],1,rate,0,0)
      self.target.draw_scale(ex-fbw, sy+fah, frameimg[:windowframe_right],1,rate,0,0)
      super      
    end
  end
end
