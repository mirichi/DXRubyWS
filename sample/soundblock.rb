# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
require_relative '../lib/fontcache'

# スーパー簡易FM音源。モジュレータの出力でキャリアの波形が周波数変調されます。

Window.width, Window.height = 1000, 320

# スライダーコントロール
module WS
  class WSSliderH < WSContainer
    class WSSlider < WSControl
      include Draggable
      def initialize(x, y, width, height)
        super
        self.image = Image.new(width, height, COLOR[:base]).draw_border(true)
      end
    end
    
    def initialize(x, y, width, height, val)
      super(x, y, width, height)
      @val = val
      @slider = WSSlider.new((width - 10) * val, 0, 10, height)
      self.add_control(@slider)
      
      @slider.add_handler(:drag_move) do |obj, x|
        @slider.x = (@slider.x + x).clamp(0, width - 10)
        signal(:slide, @slider.x / (width - 10.0)) # 0.0～1.0でシグナルに値をのせる
      end
    end
    
    def draw
      self.image.draw_line(0, @height/2, @width-1, @height/2, C_BLACK)
      super
    end
    
    # 0.0～1.0で指定する
    def set_val(x)
      @slider.x = x * width
    end
  end
end


module WS
  # フォーム定義
  class SoundBlockWindow < WSWindow
    attr_accessor :btn_play, :wave_image, :volume_image
    
    def initialize(x, y, title)
      super(x, y, 226, 200, title)
      
      @btn_play = WSButton.new(160, 150, 50, 20, "Play")
      self.client.add_control(@btn_play, :btn_play)
      @btn_play.add_handler(:click) {|obj, tx, ty|self.btn_play_clicked(tx, ty)}
      
      @wave_image = WSImage.new(10, 10, 100, 60)
      @wave_image.image = Image.new(100, 60, C_BLACK)
      self.client.add_control(@wave_image, :wave_image)
      
      @volume_image = WSImage.new(10, 80, 100, 60)
      @volume_image.image = Image.new(100, 60, C_BLACK)
      self.client.add_control(@volume_image, :volume_image)
      
      @slider_a = WSSliderH.new(120, 60, 80, 16, 0)
      @slider_d = WSSliderH.new(120, 80, 80, 16, 0)
      @slider_s = WSSliderH.new(120, 100, 80, 16, 0)
      @slider_r = WSSliderH.new(120, 120, 80, 16, 0)
      self.client.add_control(@slider_a)
      self.client.add_control(@slider_d)
      self.client.add_control(@slider_s)
      self.client.add_control(@slider_r)
      @slider_a.add_handler(:slide) {|obj, x|self.a_slide(x)}
      @slider_d.add_handler(:slide) {|obj, x|self.d_slide(x)}
      @slider_s.add_handler(:slide) {|obj, x|self.s_slide(x)}
      @slider_r.add_handler(:slide) {|obj, x|self.r_slide(x)}
      
      @label_a = WSLabel.new(205, 60, 30, 16, "A")
      @label_d = WSLabel.new(205, 80, 30, 16, "D")
      @label_s = WSLabel.new(205, 100, 30, 16, "S")
      @label_r = WSLabel.new(205, 120, 30, 16, "R")
      self.client.add_control(@label_a)
      self.client.add_control(@label_s)
      self.client.add_control(@label_d)
      self.client.add_control(@label_r)
      
      @ni = WSNumberInputExt.new(120, 20, 80, 20)
      self.client.add_control(@ni)
      @ni.limit(1, 32)
      @ni.step(1, 8)
      @ni.add_handler(:change) {|obj, val| self.wx_changed(val)}
      
      init
    end
  end
  
  # アプリコード
  class SoundBlockWindow
    attr_accessor :modulator, :carrier
    T = 2 * Math::PI / 44100.0
    
    def self.connect(mod, car)
      mod.carrier = car
      car.modulator = mod
      car.draw_wave
    end
    
    def init
      @se = nil
      
      # デフォルト値
      @wave = WAVE_SIN
      @f = 440.0
      @v = 1.0
      @attack_time = 0.005
      @decay_time = 0.3
      @sustain_level = 0.4
      @release_time = 0.1
      @fbx = 0
      @wx = 1
      @ni.value = 1
      
      @slider_a.set_val(@attack_time)
      @slider_s.set_val(@decay_time)
      @slider_d.set_val(@sustain_level)
      @slider_r.set_val(@release_time)
      
      draw_wave
      draw_volume
    end
    
    def a_slide(val)
      @attack_time = val
      draw_volume
    end
    
    def d_slide(val)
      @decay_time = val
      draw_volume
    end
    
    def s_slide(val)
      @sustain_level = val
      draw_volume
    end
    
    def r_slide(val)
      @release_time = val
      draw_volume
    end
    
    def wx_changed(val)
      @wx = val
      draw_wave
    end
    
    def draw_wave
      @wave_image.image.fill(C_BLACK)
      x = 0
      y = 30
      f = 44100.0 / 100 / @f
      
      100.times do |i|
        tmp = w_calc_for_image(f*i) * 30 + 30
        @wave_image.image.line(x, y, i, tmp, C_WHITE)
        x = i
        y = tmp
      end
      @carrier.draw_wave if @carrier
    end
    
    def draw_volume
      @volume_image.image.fill(C_BLACK)
      x = 0
      y = 60
      100.times do |i|
        tmp = 60-v_calc(441.0 * i)*60.0
        @volume_image.image.line(x, y, i, tmp, C_WHITE)
        x = i
        y = tmp
      end
    end
    
    def w_calc_for_image(t) # 1/44100単位
      @fb = 0 if t == 0
      if @modulator
        @fb = Math.sin(T * @f * t * @wx + @modulator.w_calc_for_image(t) + @fb * @fbx)
      else
        @fb = Math.sin(T * @f * t * @wx + @fb * @fbx)
      end
    end
    
    def w_calc(t) # 1/44100単位
      @fb = 0 if t == 0
      if @modulator
        @fb = Math.sin(T * @f * t * @wx + @modulator.w_calc(t) * @modulator.v_calc(t) + @fb * @fbx)
      else
        @fb = Math.sin(T * @f * t * @wx + @fb * @fbx)
      end
    end
    
    def v_calc(t) # 1/44100単位
      t = t / 44100.0
      if t <= @attack_time
        # アタック中
        return 0.0 if @attack_time == 0.0
        (t / @attack_time) * @v
      elsif t >= 1.0 - @release_time
        # リリース中
        (1 - ((t - 1.0 + @release_time) / @release_time)) * @sustain_level
      else
        # 減衰 or 保持中
        if (t - @attack_time) > @decay_time
          @sustain_level
        else
          (1 - (t - @attack_time) / @decay_time) * (@v - @sustain_level) + @sustain_level
        end
      end
    end
    
    def btn_play_clicked(tx, ty)
      if @se
        @se.stop
        @se.dispose
      end
      @se = SoundEffect.new(Array.new(44100){|i|w_calc(i) * v_calc(i)})
      @se.play
    end
  end
end

w1 = WS::SoundBlockWindow.new(0, 0, "SoundBlock Modulator1")
WS.desktop.add_control(w1)
w2 = WS::SoundBlockWindow.new(226, 0, "SoundBlock Modulator2")
WS.desktop.add_control(w2)
w3 = WS::SoundBlockWindow.new(226*2, 0, "SoundBlock Modulator3")
WS.desktop.add_control(w3)
w4 = WS::SoundBlockWindow.new(226*3, 0, "SoundBlock Carrier")
WS.desktop.add_control(w4)
WS::SoundBlockWindow.connect(w1, w2)
WS::SoundBlockWindow.connect(w2, w3)
WS::SoundBlockWindow.connect(w3, w4)
w2.btn_play.activate

WS.desktop.add_key_handler(K_ESCAPE) do break end

Window.loop do
  WS.update
  Window.caption = Window.get_load.to_s
end
