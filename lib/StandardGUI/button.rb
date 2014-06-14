# coding: utf-8
require_relative './common'

module WS
  class WSButtonBase < WSControl
    attr_accessor :caption, :fore_color

    def initialize(tx, ty, width, height, caption = "")
      super(tx, ty, width, height)
      @caption = caption
      @fore_color = COLOR[:font]

      # 画像を作成する
      set_image
      
      self.add_animation(:usual, 1, [0])
      self.add_animation(:active, 1, [1])
      self.add_animation(:mouseover, 1, [2])
      self.add_animation(:mouseover_active, 1, [3])
      self.add_animation(:pushed, 1, [4])
      
      @pushed = false
      @mouseover = false
      set_animation
    end
    
    # キャプションの設定
    def caption=(text)
      refresh if @caption != text
      @caption = text
    end
    
    # オートレイアウトなどでサイズが変更されたときに呼ばれる
    def resize(width, height)
      super
      # 画像を作成する
      set_image
    end
    
    def set_image
      Image.dispose(self.animation_image)
      
      self.animation_image = [img = Image.createFromArray(@width, @height, Array.new(@height){|y| Array.new(@width){|x|
                                if x == 0 || x == @width - 1 || y == 0 || y == @height - 1
                                  #画像の端なら
                                  COLOR[:border]
                                else
                                  COLOR[:button][(y - 1).to_f / (@height - 2)]
                                end
                              }}.flatten),
                              
                              img.dup.draw(2, 2, IMAGE[:dotted_box][@width-4,@height-4,COLOR[:mark]]),
                              
                              img = Image.new(@width, @height, COLOR[:mouseover]).box(0,0,@width-1,@height-1,COLOR[:mouseover_border]),
                              
                              img.dup.draw(2, 2, IMAGE[:dotted_box][@width-4,@height-4,COLOR[:mark]]),
                              
                              Image.new(@width, @height, COLOR[:pushed]).box(0,0,@width-1,@height-1,COLOR[:pushed_border])
                              ]
      
      # キャプションの描画
      if @caption.length > 0
        width = @font.get_width(@caption)
        self.animation_image[0..3].each{|img|
                               img.draw_font_ex(@width / 2 - width / 2 ,
                               @height / 2 - @font.size / 2 ,
                               @caption, @font, {:color => @fore_color, :aa => false})
        }
        
        self.animation_image[4].draw_font_ex(@width / 2 - width / 2 + 1,
                                @height / 2 - @font.size / 2 + 1,
                                @caption, @font, {:color => @fore_color, :aa => false})
      end
      
      refreshed
    end
    
    def set_animation
      if @pushed
        self.change_animation(:pushed)
      else
        if @active
          if @mouseover
            self.change_animation(:mouseover_active)
          else
            self.change_animation(:active)
          end
        else
          if @mouseover
            self.change_animation(:mouseover)
          else
            self.change_animation(:usual)
          end
        end
      end
      
      self
    end
    
    def on_mouse_over
      super
      @mouseover = true
      set_animation
    end
    
    def on_mouse_out
      super
      @mouseover = false
      set_animation
    end
    
    def on_enter
      super
      set_animation
    end
    
    def on_leave
      super
      set_animation
    end
    
    def render
      set_image if refresh?
      self.update_animation
    end
  end

  # 普通のボタン
  class WSButton < WSButtonBase
    include Focusable
    include ButtonClickable # 普通のクリック用モジュール

    def on_key_push(key)
      if key == K_SPACE
        @pushed = true
        set_animation
      end
    end

    def on_key_release(key)
      if key == K_SPACE
        @pushed = false
        set_animation
        on_click(0, 0)
      end
    end
  end

  # スピンボタン
  class WSSpinButton < WSButtonBase
      include Focusable
      include RepeatClickable # リピートクリック用モジュール
  end
end
