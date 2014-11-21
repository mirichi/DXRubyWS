# coding: utf-8
module WS
	
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
      if @running_time != Window.running_time
        @running_time = Window.running_time
        @count = (@count + 2) % 360
        self.level = 0.5 + Math::sin((@count / 180.0) * Math::PI) / 2
      end
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
  
  ### ■ウィンドウフレーム用シェーダー■ ###
  class Shader_WindowFrame < Shader
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
            output.Color.rgb = gColorHigh - (gColorHigh - gColorLow) * input.UV[1] + (output.Color.rgb - 0.5);
            output.Color.rgb -= (0.8 - input.UV[1]) * floor(input.UV[1] / 0.5);
            
      
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
      super(@@core, "Shader_WindowFrame")
      set_parameter(high, low)
    end
  
    # パラメータの設定
    def set_parameter(high, low)
      self.gColorHigh = high.collect{|v| v / 255.0}
      self.gColorLow  = low.collect{ |v| v / 255.0}
    end
  end  
  
end