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
  
  

  module ButtonGradation
    @@shader_image      = RenderTarget.new(32, 32)
    @@shader_button     = Shader_Button.new(COLOR[:button_high], COLOR[:button_low])
    
    def set_border(image, state=:usual, round=false)
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
    end
      
  end
  
  # フォーカスを受け取れるようにするモジュール
  module Focusable
    ### クラス変数 ###
    @@shader_mouse_over = Shader_MouseOver.new(COLOR[:mouse_over])
    @@shader_active     = Shader_Active.new(COLOR[:mouse_over])
    
    # シェーダーをセットする
    def set_shader
      if activated?
        @@shader_active
      elsif @mouse_over
        @@shader_mouse_over
      elsif
        nil
      end
    end
      
    def update
      super
      @@shader_active.update if activated?
    end
    
    # 画像の作成
    def render
      self.shader = set_shader
      super
    end
    
  end
    
  
  ### ■ボタン■ ###
  class WSButtonBase < WSControl
 
    include ButtonGradation   
    
    # set_imageで@image[true](押された絵)と@image[false](通常の絵)を設定する。
    # オーバーライドしてこのメソッドを再定義することでボタンの絵を変更することができる。
    def set_image
      # 画像を再作成する前にdisposeする
      @image.each_value{|image| image.dispose if image.disposed?}
 
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

    # 画像の描画
    def draw
      super
    end
    
  end
  
  # 普通のボタン
  class WSButton
    # 境界線を丸める
    def set_border(image, state=:usual)
      w = self.width-1
      h = self.height-1
      super(image, state)
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
  
  module HoverTextDisplayable
    
    #表示するテキストのクラス
    class HoverText < WSControl
      def initialize(text, font = nil, max_width = nil)
        super(0,0,0,0) #取り敢えず生成
        
        @old_text = text
        txt = text.gsub($/, "") #改行は不可能
        @font = font if font
        @max_width = max_width
        
        @text = []
        width = 0
        sum = 0
        length = txt.length
        
        until sum == length
          new_added = (max_width ? txt.within(@font, max_width) : txt)
          new_added = txt[0] if new_added.empty?
          @text << new_added
          txt = txt[(new_length = new_added.length)..-1]
          sum += new_length
          width = [width, @font.get_width(new_added)].max
        end
        
        self.width = width + 4
        self.height = @text.size * @font.size + 4
        
        self.image = Image.new(self.width, self.height, COLOR[:background])
                  .box(0,0,self.width-1,self.height-1,COLOR[:border])
        @text.each_with_index do |v, i|
          self.image.draw_font(2, i * @font.size + 2, v, @font, COLOR[:font])
        end
        
        @show = false
      end
      
      def text
        @text.join($/)
      end
      def text=(v)
        self.__send__(:initialize, v, @font, @max_width)
        v
      end
      
      def font
        @font
      end
      def font=(v)
        self.__send__(:initialize, @old_text, v, @max_width)
        v
      end
      
      def max_width
        @max_width
      end
      def max_width=(v)
        self.__send__(:initialize, @old_text, @font, v)
        v
      end
      
      def show(x, y)
        return if @show
        self.x = x
        self.y = y
        WS.desktop.add_control(self)
        @show = true
      end
      
      def hide
        return unless @show
        WS.desktop.remove_control(self)
        self.vanish
        @show = false
      end
    end
    
    def initialize(*args)
      super
      @hovertext_wait = 30
      @hovertext_frame = 120
      @hovertext = "default hovertext"
      @hovertext_frame_count = 0
      @hovertext_max_width = nil
    end
    
    def update
      super
      if @mouse_over
        if @hovertext_frame_count >= @hovertext_wait
          unless @hovertext_frame
            @hovertext_control ||= HoverText.new(@hovertext, @font, @hovertext_max_width)
            @hovertext_control.show(Input.mousePosX + 1, Input.mousePosY + 1)
          else
            if @hovertext_frame_count < @hovertext_wait + @hovertext_frame
              @hovertext_control ||= HoverText.new(@hovertext, @font, @hovertext_max_width)
              @hovertext_control.show(Input.mousePosX + 1, Input.mousePosY + 1)
            else
              @hovertext_control.hide
            end
          end
        end
        
        @hovertext_frame_count += 1
        
      else
        if @hovertext_control
          @hovertext_control.hide
          @hovertext_control = nil
        end
        @hovertext_frame_count = 0
      end
    end
    
    def hover_text
      @hovertext_control ? @hovertext_control.text : @hovertext
    end
    def hover_text=(v)
      @hovertext = v
      if @hovertext_control
        @hovertext_control.text = v
      end
    end
    
    def font=(v)
      super
      if @hovertext_control
        @hovertext_control.font = v
      end
    end
    
    def hover_text_max_width
      @hovertext_max_width
    end
    def hover_text_max_width=(v)
      @hovertext_max_width = v
      if @hovertext_control
        @hovertext_control.max_width = v
      end
    end
  end
  
  # 画像ボタン
  class WSImageButton < WSButtonBase
    include Focusable
    include ButtonClickable
    include HoverTextDisplayable

    def initialize(tx, ty, image, width = image.width, height = image.height, caption = "")
      @origin = image
      super(tx, ty, width, height, caption)
      self.hover_text = caption
    end

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
      @image[:usual] = Image.new(@width, @height).draw((@width - @origin.width) / 2, (@height - @origin.height) / 2, @origin)
      set_border(@image[:usual])
      # 押下時の画像を作成
      @image[:pushed] = Image.new(@width, @height).draw((@width - @origin.width) / 2, (@height - @origin.height) / 2, @origin)
      set_border(@image[:pushed], :pushed)
      
      refreshed
    end

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
  

  ### ■チェックボックス■ ###
  class WSCheckBox
    
    ### 画像キャッシュの作成
    IMG_CACHE[:checkbox_true] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOBAMAAADtZjDiAAAAMFBMVEUAAABHOjpZYnV8dX6ssrfO0djW3eHe6Or6/PgAAAAAAAAAAAAAAAAAAAAAAAAAAABK+yyIAAAASUlEQVR4nGNQggAGjQ4QaGLQcAEBIO0aGhpqAqGDRSG0oRmYDhZMA9GmhsJgWlhQvAxEGwqal4LoQOHyVJA5rmmpoU1wc6H2AAApZhx9AHeA0gAAAABJRU5ErkJggg==".unpack('m')[0])
    IMG_CACHE[:checkbox_false] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOBAMAAADtZjDiAAAAMFBMVEXV78pZYnWssrfO0djW3eHe6Orn9PT6/PgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6pDB0AAAAAXRSTlMAQObYZgAAAEFJREFUeJxjEIQABvFyEChkEFcCASCtbGxsbAShXZzBtIuLC4g2gdGuoWDaJSwtBEoHQ8VB6pWUXZyNC+HmQu0BAOTcFzeyvHAbAAAAAElFTkSuQmCC".unpack('m')[0])
    
    # チェックボックス画像(true)
    def image_checkbox_true
      IMG_CACHE[:checkbox_true]
    end
        
    # チェックボックス画像(false)
    def image_checkbox_false
      IMG_CACHE[:checkbox_false]
    end
  
    # 描画
    def draw
      super
    end
  end  
  
 

  ### ■プルダウンリスト■ ###
  class WSPullDownList  

    include ButtonGradation
    
    def refresh
      @image.each_value{|image| image.dispose if image.disposed?}
       
      @@shader_image.resize(width, height)
      
      # 通常時の画像を作成
      tx = self.width - 8
      ty = self.height / 2 + 3
      @image[:usual] = @@shader_image.draw_shader(0,0,@@shader_image, @@shader_button)
                                     .to_image
                                     .triangle_fill(tx, ty, tx-3, ty-6, tx+3, ty-6, COLOR[:font])
      set_border(@image[:usual])
 
      refreshed            
    end

    def draw_caption
      self.target.draw_font(self.x + 3, self.y + 3, item.to_s, @font, {:color => COLOR[:font],:z => self.z}) if self.item
    end
    
  end
  
  
  
  
end
