# coding: utf-8
require_relative 'button'
require_relative 'textbox'

module WS
  class WSNumberInput < WSContainer
		
    ### 公開インスタンス###
    attr_accessor :min, :max, :small, :big
    attr_reader :value
	  	  
    # 初期化
    def initialize(tx, ty, width, height)
      super(tx, ty, [width, 72].max, [height, 20].max)
      @value  = 0
      @min   = 0
      @max   = 99999
      @small = 1
      @big   = 10
      create_controls
      set_text
    end
		
    # コントロールの作成
    def create_controls
      # テキストボックスの作成
      c_numtext = WSTextBox.new(0, 0, width - 48, height)
      c_numtext.add_handler(:changed, self.method(:text_changed))
      # スピンボタン変動小の作成
      font_s = Font.new(8)
      c_b_add_s = WSSpinButton.new(width - 48,          0, 24, height / 2, "▲")
      c_b_add_s.font = font_s
      c_b_add_s.add_handler(:click, self.method(:click_add_button_s))
      c_b_sub_s = WSSpinButton.new(width - 48, height / 2, 24, height / 2, "▼")
      c_b_sub_s.font = font_s  
      c_b_sub_s.add_handler(:click, self.method(:click_sub_button_s))
      # スピンボタン変動大の作成
      font_b = Font.new(10)
      c_b_add_b = WSSpinButton.new(width - 24,          0, 24, height / 2, "▲")
      c_b_add_b.font = font_b
      c_b_add_b.add_handler(:click, self.method(:click_add_button_b))
      c_b_sub_b = WSSpinButton.new(width - 24, height / 2, 24, height / 2, "▼")
      c_b_sub_b.font = font_b  
      c_b_sub_b.add_handler(:click, self.method(:click_sub_button_b))

      # コントロールの登録
      add_control(c_numtext, :c_numtext)
      add_control(c_b_add_s)
      add_control(c_b_sub_s)
      add_control(c_b_add_b)
      add_control(c_b_sub_b)		  
    end
		
    # 加算ボタン小の押下処理
    def click_add_button_s(obj, tx, ty)
      @value = [@value + @small, @max].min
      set_text
      signal(:changed, @value)
    end

    # 減算ボタン小の押下処理
    def click_sub_button_s(obj, tx, ty)
      @value = [@value - @small, @min].max
      set_text
      signal(:changed, @value)
    end
		
    # 加算ボタン大の押下処理
    def click_add_button_b(obj, tx, ty)
      @value = [@value + @big, @max].min
      set_text
      signal(:changed, @value)
    end
    
    # 減算ボタン大の押下処理
    def click_sub_button_b(obj, tx, ty)
      @value = [@value - @big, @min].max
      set_text
      signal(:changed, @value)
    end

    # テキスト変更
    def text_changed(obj, text)
      before = @value
      self.c_numtext.text = text
      check_text
      signal(:changed, @value) if before != @value
    end

    def value=(v)
      before = @value
      @value = v.clamp(@min, @max)
      check_text
      signal(:changed, @value) if before != @value
    end
    
    ### スタイル ###
    # 限界値の設定
    def limit(min , max)
      @min = min
      @max = max
    end
    
    # ステップ値の設定
    def step(small , big)
      @small = small
      @big   = big
    end
    
    # テキストに数字以外のものが入っていないかをチェックし、データに反映する
    def check_text
      num_text = self.c_numtext.text
      num = self.c_numtext.text.to_i
      if num_text != "0" && num == 0 || num_text !=  num.to_s
        self.c_numtext.text = @value.to_s
      else
        @value = [[num, @min].max, @max].min
        set_text unless num >= @min && num <= @max
      end 
    end
    
    # テキストボックスにテキストを設定
    def set_text
      self.c_numtext.text = @value.to_s
    end
				
  end
end
