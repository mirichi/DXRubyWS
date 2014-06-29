module WS
    
  COLOR[:base] = [190, 190, 190]         # ウィンドウやボタン等の基本色
  COLOR[:border] = [80,80,80]            # 境界線
  COLOR[:shadow] = [120,120,120]         # 影
  COLOR[:darkshadow] = [80,80,80]        # 濃い影
  COLOR[:light] = [220,220,220]          # 明るい
  COLOR[:highlight] = [240,240,240]      # ハイライト
  COLOR[:background] = [255,255,255]     # テキストボックス、リストボックスなどの背景色
  COLOR[:marker] = [0,0,0]               # チェックボックス、ラジオボタン等のマークの色
  COLOR[:select] = [0,30,153]            # リストボックスなどの選択色
  COLOR[:font] = [0,0,0]                 # デフォルトの文字色
  COLOR[:font_reverse] = [255, 255, 255] # 反転文字色
  COLOR[:mouse_over] = [0, 64, 128]
  #ボタン
  COLOR[:button_high] = [240, 240, 240]
  COLOR[:button_low]  = [160, 160, 160]
  
    
    
  
  ### ■マウスオーバー■ ###
  class Shader_MouseOver < Shader
    # シェーダコアのHLSL記述
    hlsl = <<EOS
    // (1) グローバル変数
        float4  tone;
        texture tex0;

    // (2) サンプラ
        sampler Samp0 = sampler_state
        {
            AddressU  = Border;
            AddressV  = Border;
            Texture =<tex0>;
        };

    // (3) 入出力の構造体
        struct PixelIn
        {
            float2 UV : TEXCOORD0;
        };
        struct PixelOut
        {
            float4 Color : COLOR0;
        };

    // (4) ピクセルシェーダのプログラム
        PixelOut PS_P0_Main(PixelIn input)
        {
            PixelOut output;
            output.Color =  tex2D(Samp0, input.UV);
            output.Color += tone;
            
            return output;
        }

    // (5) technique定義
        technique Glow
        {
            pass P0
            {
                PixelShader = compile ps_2_0 PS_P0_Main();
            }
        }
EOS

    # シェーダコアの作成
    @@core = DXRuby::Shader::Core.new(hlsl,{:tone => :float})

    # 初期化
    def initialize(tone)
      super(@@core, "Shader_MouseOver")
      set_parameter(tone)
    end

    # パラメータの設定
    def set_parameter(tone)
      self.tone = tone.collect{|v| v / 255.0}
    end
    
    # 更新
    def update
    end
    
  end  
  
### ■アクティブシェーダー■ ###
class Shader_Active < Shader
  # シェーダコアのHLSL記述
  hlsl = <<EOS
  // (1) グローバル変数
      float   level;  
      float4  tone;
      texture tex0;

  // (2) サンプラ
      sampler Samp0 = sampler_state
      {
          AddressU  = Border;
          AddressV  = Border;
          Texture =<tex0>;
      };

  // (3) 入出力の構造体
      struct PixelIn
      {
          float2 UV : TEXCOORD0;
      };
      struct PixelOut
      {
          float4 Color : COLOR0;
      };

  // (4) ピクセルシェーダのプログラム
      PixelOut PS_P0_Main(PixelIn input)
      {
          PixelOut output;
          output.Color =  tex2D(Samp0, input.UV);
          output.Color += (tone * level) ;
          
          return output;
      }

  // (5) technique定義
      technique Glow
      {
          pass P0
          {
              PixelShader = compile ps_2_0 PS_P0_Main();
          }
      }
EOS

  # シェーダコアの作成
  @@core = DXRuby::Shader::Core.new(hlsl,{:tone  => :float,
                                          :level => :float})

  # 初期化
  def initialize(tone)
    super(@@core, "Shader_Active")
    @count = 0
    set_parameter(tone)
  end

  # パラメータの設定
  def set_parameter(tone)
    self.tone = tone.collect{|v| v / 255.0}
  end
  
  # 更新
  def update
    @count = (@count + 2) % 360
    self.level = 0.5 + Math::sin((@count / 180.0) * Math::PI) / 2
  end
  
end  

    
  ### ■グラデーション用シェーダー■ ###
  class Shader_Button < Shader
    # シェーダコアのHLSL記述
    hlsl = <<EOS
    // (1) グローバル変数
        float3  gColorHigh;
        float3  gColorLow;
        texture tex0;
  
    // (2) サンプラ
        sampler Samp0 = sampler_state
        {
            AddressU  = Border;
            AddressV  = Border;
            Texture =<tex0>;
        };
  
    // (3) 入出力の構造体
        struct PixelIn
        {
            float2 UV : TEXCOORD0;
        };
        struct PixelOut
        {
            float4 Color : COLOR0;
        };
  
    // (4) ピクセルシェーダのプログラム
        PixelOut PS_P0_Main(PixelIn input)
        {
            PixelOut output;
            
            output.Color = tex2D(Samp0, input.UV);
            output.Color.rgb = gColorHigh - (gColorHigh - gColorLow) * input.UV[1];
            output.Color.rgb -= 0.1 * floor(input.UV[1] / 0.5);
            output.Color.a = 1.0;
      
            return output;
        }
  
    // (5) technique定義
        technique Glow
        {
            pass P0
            {
                PixelShader = compile ps_2_0 PS_P0_Main();
            }
        }
EOS
  
    # シェーダコアの作成
    @@core = DXRuby::Shader::Core.new(hlsl,{:gColorHigh => :float,
                                            :gColorLow  => :float})
  
    # 初期化
    def initialize(high, low)
      super(@@core, "Shader_Button")
      set_parameter(high, low)
    end
  
    # パラメータの設定
    def set_parameter(high, low)
      self.gColorHigh = high.collect{|v| v / 255.0}
      self.gColorLow  = low.collect{ |v| v / 255.0}
    end
  end  
  
  
  
    
  # すべての基本、コントロールのクラス
  class WSControl

    def initialize(tx, ty, width, height)
      super(tx, ty)
      @width, @height = width, height
      @min_width, @min_height = 16, 16
      self.collision = [0, 0, width - 1, height - 1]
      @signal_handler = {}   # シグナルハンドラ
      @key_handler = {}      # キーハンドラ
      @hit_cursor = Sprite.new # 衝突判定用スプライト
      @hit_cursor.collision = [0,0]
      @font ||= @@default_font
      @resizable_width = false  # オートレイアウト用設定
      @resizable_height = false # オートレイアウト用設定
      @focusable = false
      @active = false
      @mouse_over = false
      @enabled = true
    end

    # コントロールにマウスカーソルが乗ったときに呼ばれる
    def on_mouse_over
      signal(:mouse_over)
      @mouse_over = true
      self
    end
    
    # コントロールからマウスカーソルが離れたときに呼ばれる
    def on_mouse_out
      signal(:mouse_out)
      @mouse_over = false
      self
    end
            
    # フォーカスが当てられたときに呼ばれる
    def on_enter
      @active = true
    end
    
    # フォーカスを失ったときに呼ばれる
    def on_leave
      @active = false
    end
            
    # コントロールの状態を判定しシンボルを返す
    # 特殊な状態は継承先で個別に定義する
    # :usual            通常状態
    # :disable          使用不可状態
    # :active           フォーカスを得ている
    # :mouseover        マウスが乗っている
    # :mouseover_active フォーカスを得ていてマウスが乗っている
    def state
      :usual
    end
  
  end
  
  
  
  
  module ButtonClickable
    def initialize(*args)
      super
      @pushed = false
    end
  
    def on_mouse_push(tx, ty)
      WS.capture(self)
      @pushed = true
      super
    end
  
    def on_mouse_release(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      @pushed = false
      if @hit_cursor === self and WS.captured?(self)
        WS.capture(nil)
        on_click(tx, ty)
      else
        if WS.captured?(self)
          WS.capture(nil)
          on_click_cancel(tx, ty)
        else
          WS.capture(nil)
        end
      end
      super
    end
  
    def on_mouse_move(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      if WS.captured?(self)
        @pushed = @hit_cursor === self
      end
      super
    end
  
    def on_click(tx, ty)
      signal(:click, tx, ty)
    end
  
    def on_click_cancel(tx, ty)
      signal(:click_cancel, tx, ty)
    end
  end
  
  # スクロールバーのボタンのようにオートリピートで:clickシグナルを発行し続ける
  # このシグナルはupdate時に発生する
  module RepeatClickable
    def initialize(*args)
      super
      @downcount = 0
      @pushed = false
    end
    def on_mouse_push(tx, ty)
      @old_tx, @old_ty = tx, ty
      WS.capture(self)
      @downcount = 20
      @pushed = true
      super
      on_click(tx, ty)
    end
  
    def on_mouse_release(tx, ty)
      @pushed = false
      WS.capture(nil)
      @downcount = 0
      super
    end
  
    def on_mouse_move(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      if WS.captured?(self)
        @pushed = @hit_cursor === self
      end
      super
    end
  
    def update
      if @downcount > 0
        @downcount -= 1
        if @downcount == 0
          @downcount = 5
          on_click(@old_tx, @old_ty)
        end
      end
      super
    end
  
    def on_click(tx, ty)
      signal(:click, tx, ty)
    end
  end

  
  
  

  class WSButtonBase < WSControl
    
    ### クラス変数 ###
    @@shader_mouse_over = Shader_MouseOver.new(COLOR[:mouse_over])
    @@shader_active     = Shader_Active.new(COLOR[:mouse_over])
    @@shader_button     = Shader_Button.new(COLOR[:button_high], COLOR[:button_low])
    @@shader_image      = RenderTarget.new(32, 32)
      
    def state
      if @pushed
        :pushed
      elsif !@enabled
        :disable    
      elsif @active
        :active
      else
        :usual
      end
    end
    
    # set_imageで@image[true](押された絵)と@image[false](通常の絵)を設定する。
    # オーバーライドしてこのメソッドを再定義することでボタンの絵を変更することができる。
    def set_image
      # 画像を再作成する前にdisposeする
      if @image.has_key?(true)
        @image[:usual].dispose
        @image[:active].dispose
        @image[:pushed].dispose
      end
      
      w = width-1
      h = height-1
      
      @@shader_image.resize(width, height)
      
      # 通常時の画像を作成
      @image[:usual] = @@shader_image.draw_shader(0,0,@@shader_image, @@shader_button).to_image
      set_border(@image[:usual])
      if @caption.length > 0
        tw = @font.get_width(@caption)
        @image[:usual].draw_font_ex(@width / 2 - tw / 2 ,
                             @height / 2 - @font.size / 2 ,
                             @caption, @font, {:color => @fore_color, :aa => false})
      end
      # アクティブ時の画像を作成  
      @image[:active]  = @image[:usual]
      # 押下時の画像を作成
      @image[:pushed] = Image.new(width, height)
      @image[:pushed].draw(1, 1, @image[:usual])
      set_border(@image[:pushed], :pushed)


      refreshed
    end

    def set_border(image, state=:usual, round=true)
      w = self.width-1
      h = self.height-1
      image.line(0,0,w,0,COLOR[:border])
           .line(0,h,w,h,COLOR[:border])
           .line(0,0,0,h,COLOR[:border])
           .line(w,0,w,h,COLOR[:border])
      if state != :pushed
        image.line(1,1,w-1,1,COLOR[:button_high])
             .line(1,h-1,w-1,h-1,COLOR[:button_high])
             .line(1,1,1,h-1,COLOR[:button_high])
             .line(w-1,1,w-1,h-1,COLOR[:button_high])
      end
      if round
        image.line(0,2,2,0,COLOR[:border])
             .line(0,h-2,2,h,COLOR[:border])
             .line(w-2,0,w,2,COLOR[:border])
             .line(w-2,h,w,h-2,COLOR[:border])
        image[0,0] = [0,0,0,0]
        image[w,0] = [0,0,0,0]
        image[0,h] = [0,0,0,0]
        image[w,h] = [0,0,0,0]
      end
    end
    
    # コントロールの状態を判定しシンボルを返す
    def state
      if @pushed
        :pushed
      else  
        super
      end
    end
    
    # シェーダーをセットする
    def set_shader
      if activated?
        @@shader_active.update
        @@shader_active
      elsif @mouse_over
        @@shader_mouse_over
      elsif
        nil
      end
    end
    
    # 画像のレンダリング
    def render
      set_image if refresh?
      self.shader = set_shader
      self.image = @image[self.state]
    end

    # 画像の描画
    def draw
      super
    end
  end

  ### ■通常のボタン■ ###
  class WSButton < WSButtonBase
    include Focusable
    include ButtonClickable # 普通のクリック用モジュール

    def on_key_push(key)
      if key == K_SPACE
        @image_flag = true
      end
    end

    def on_key_release(key)
      if key == K_SPACE
        @image_flag = false
        on_click(0, 0)
      end
    end
  end

  
  # スピンボタン
  class WSSpinButton < WSButtonBase
    include Focusable
    include RepeatClickable # リピートクリック用モジュール
  end


  # 縦スクロールバークラス
  class WSVScrollBar < WSContainer
    class WSScrollBarUpButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(7, 3, 3, 10, 11, 10, COLOR[:font])
        @image[:pushed].triangle_fill(8, 4, 4, 11, 12, 11, COLOR[:font])
      end
    end

    class WSScrollBarDownButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(7, 11, 3, 4, 11, 4, COLOR[:font])
        @image[:pushed].triangle_fill(8, 12, 4, 5, 12, 5, COLOR[:font])
      end
    end
  end

  # 横スクロールバークラス
  class WSHScrollBar < WSContainer
    class WSScrollBarLeftButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(3, 8, 10, 4, 10, 11, COLOR[:font])
        @image[:pushed].triangle_fill(4, 9, 11, 5, 11, 12, COLOR[:font])
      end
    end

    class WSScrollBarRightButton < WSSpinButton
      def set_image
        super
        @image[:usual].triangle_fill(11, 8, 4, 4, 4, 11, COLOR[:font])
        @image[:pushed].triangle_fill(12, 9, 5, 5, 5, 12, COLOR[:font])
      end
    end
  end

  # ウィンドウぽい動きを実現してみる
  class WSWindow
    ### ■ウィンドウのクローズボタン用クラス■ ###
    class WSWindowCloseButton < WSButton
    
      def set_image
        super
        @image[:pushed].line(4, 4, @width-5, @height-5, C_BLACK)
        .line(5, 4, @width-4, @height-5, C_BLACK)
        .line(@width-5, 4, 4, @height-5, C_BLACK)
        .line(@width-4, 4, 5, @height-5, C_BLACK)
        @image[:usual].line(4-1, 4-1, @width-5-1, @height-5-1, C_BLACK)
        .line(5-1, 4-1, @width-4-1, @height-5-1, C_BLACK)
        .line(@width-5-1, 4-1, 4-1, @height-5-1, C_BLACK)
        .line(@width-4-1, 4-1, 5-1, @height-5-1, C_BLACK)
      end
    end
  end

end