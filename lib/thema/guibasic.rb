# coding: utf-8
module WS
    
  ### 色定数 ###
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
  
  

  
  ### ■コントロール■ ###
  class WSControl
    @@shader_mouse_over = Shader_MouseOver.new(COLOR[:mouse_over])
    @@shader_active     = Shader_Active.new(COLOR[:mouse_over])
  end
  
  
    
  
  ### ■ボタン■ ###
  class WSButtonBase < WSControl
    
    ### クラス変数 ###
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
      if @image.has_key?(:usual)
        @image[:usual].dispose  unless @image[:usual].disposed? 
        @image[:active].dispose unless @image[:active].disposed?
        @image[:pushed].dispose unless @image[:pushed].disposed?
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
      @image[:active]  = @image[:usual].dup
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


  

  ### ■チェックボックス■ ###
  class WSCheckBox
    
    BIN_TRUE = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOBAMAAADtZjDiAAAAMFBMVEUAAABH
                OjpZYnV8dX6ssrfO0djW3eHe6Or6/PgAAAAAAAAAAAAAAAAAAAAAAAAAAABK
                +yyIAAAASUlEQVR4nGNQggAGjQ4QaGLQcAEBIO0aGhpqAqGDRSG0oRmYDhZM
                A9GmhsJgWlhQvAxEGwqal4LoQOHyVJA5rmmpoU1wc6H2AAApZhx9AHeA0gAA
                AABJRU5ErkJggg=="

    
    BIN_FALSE = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOBAMAAADtZjDiAAAAMFBMVEXV78pZ
                YnWssrfO0djW3eHe6Orn9PT6/PgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6
                pDB0AAAAAXRSTlMAQObYZgAAAEFJREFUeJxjEIQABvFyEChkEFcCASCtbGxs
                bAShXZzBtIuLC4g2gdGuoWDaJSwtBEoHQ8VB6pWUXZyNC+HmQu0BAOTcFzey
                vHAbAAAAAElFTkSuQmCC"


    
    ### チェックボックス画像(true) ###
    def image_checkbox_true
      unless IMG_CACHE[:checkbox_true]
        IMG_CACHE[:checkbox_true] = Image.load_from_file_in_memory(BIN_TRUE.unpack('m')[0])
      end
      IMG_CACHE[:checkbox_true]
    end
        
    ### チェックボックス画像(false) ###
    def image_checkbox_false
      unless IMG_CACHE[:checkbox_false]
      IMG_CACHE[:checkbox_false] = Image.load_from_file_in_memory(BIN_FALSE.unpack('m')[0])
      end
      IMG_CACHE[:checkbox_false]
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
      refresh if refresh?
      self.shader = set_shader
    end
    
    # 描画
    def draw
      super
      if self.activated?
        tmp = @font.get_width(@caption)
        self.target.draw_line(self.x + 18, self.y - 2, self.x + tmp + 20, self.y - 2, C_BLACK)
        self.target.draw_line(self.x + 18, self.y - 2, self.x + 18, self.y + @font.size + 2, C_BLACK)
        self.target.draw_line(self.x + tmp + 20, self.y - 2, self.x + tmp + 20, self.y + @font.size + 2, C_BLACK)
        self.target.draw_line(self.x + 18, self.y + @font.size + 2, self.x + tmp + 20, self.y + @font.size + 2, C_BLACK)
      end
    end
  end  
  
  
end