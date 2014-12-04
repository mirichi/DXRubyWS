# coding: utf-8
module WS
 
  require_relative 'guibasic_color'
  require_relative 'guibasic_shader'
 
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
   
    
    
  # 画像ボタン
  class WSImageButton

    def set_image
      # 画像を再作成する前にdisposeする
      if @image.has_key?(:usual)
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
       
      @image[:active] = @image[:usual].dup
      
      # 押下時の画像を作成
      @image[:pushed] = Image.new(@width, @height).draw((@width - @origin.width) / 2, (@height - @origin.height) / 2, @origin)
      set_border(@image[:pushed], :pushed)
     
      refreshed
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
    
    def set_image
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
