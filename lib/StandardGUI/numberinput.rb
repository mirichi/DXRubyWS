# coding: utf-8
require_relative 'button'
require_relative 'textbox'

module WS
  
  ### スピンボタンの定義 ###
  class WSSpinButton
    
    ### 定数 ###
    RATE = 30
    
    ### 公開インスタンス ###
    attr_reader :repeat_count
    
    def initialize(x, y, width, height, caption="")
      super
      @repeat_count = 0
    end
    
    # マウスを押した時の処理
    def on_mouse_push(tx, ty)
      @repeat_count = RATE
      super
    end
    
    # マウスを離した時の処理
    def on_mouse_release(tx, ty)
      @repeat_count = 0
      super
    end
    
    # 更新
    def update
      @repeat_count += 1 if @downcount > 0
      super
    end
    
  end
  
  
  
  
  ### ■NumberInput ■ ###
  class WSNumberInput < WSContainer
    
    ### 公開インスタンス ###
    attr_accessor :min, :max, :small, :big
    attr_reader :value
    
    ### 定数 ###
    RATE = 30
    
    # 初期化
    def initialize(tx, ty, width, height)
      super(tx, ty, [width, 48].max, [height, 20].max)
      @render_target = self.image
      @refresh = true
      @value  = 0
      @min   = 0
      @max   = 99999
      @small = 1
      create_controls
      set_text
    end
    
    # コントロールの作成
    def create_controls
      # テキストボックスの作成
      c_numtext = WSTextBox.new(0, 0, width - 18, height)
      c_numtext.add_handler(:changed, method(:text_changed))
      c_numtext.add_handler(:leave){ check_text; signal(:change, @value) }
      c_numtext.add_key_handler(K_RETURN){ check_text; signal(:change, @value) }
      # スピンボタン変動小の作成
      font_s = Font.new(8)
      c_b_add_s = WSSpinButton.new(width - 18,          0, 16, height / 2 - 1)
      c_b_add_s.font = font_s
      c_b_add_s.caption = "▲"
      c_b_add_s.add_handler(:click, self.method(:click_add_button_s))
      c_b_sub_s = WSSpinButton.new(width - 18, height / 2, 16, height / 2 - 1)
      c_b_sub_s.font = font_s
      c_b_sub_s.caption = "▼"
      c_b_sub_s.add_handler(:click, self.method(:click_sub_button_s))
      # コントロールの登録
      add_control(c_numtext, :c_numtext)
      add_control(c_b_add_s, :c_add_s)
      add_control(c_b_sub_s, :c_sub_s)
      
      # オートレイアウト
      layout(:hbox) do
        self.set_margin(0,0,0,0)
        add obj.c_numtext, true, false
        layout(:vbox) do
          self.set_margin(0,0,0,0)
          add obj.c_add_s, false, false
          add obj.c_sub_s, false, false
          self.resizable_width = false
          self.width = 16
        end
      end
      
      resize(width, height)
      
    end
    
    # 加算ボタン小の押下処理
    def click_add_button_s(obj, tx, ty)
      @value = [@value + @small * (self.c_add_s.repeat_count / RATE), @max].min
      set_text
      signal(:change, @value)
    end
    
    # 減算ボタン小の押下処理
    def click_sub_button_s(obj, tx, ty)
      @value = [@value - @small * (self.c_sub_s.repeat_count / RATE), @min].max
      set_text
      signal(:change, @value)
    end
    
    # テキスト変更
    def text_changed(obj, text)
      refresh
      signal(:change, @value)
    end
    
    def value=(v)
      @value = v.clamp(@min, @max)
      set_text
      check_text
    end
    
    ### スタイル ###
    # 限界値の設定
    def limit(min , max)
      @min = min
      @max = max
      self.value = @value
    end
    
    # ステップ値の設定
    def step(small)
      @small = small
    end
    
    # 更新
    def update
      super
    end
    
    # テキストに数字以外のものが入っていないかをチェックし、データに反映する
    def check_text
      num_text = self.c_numtext.text
      num = self.c_numtext.text.to_i
      if num_text != "0" && num == 0 || num_text !=  num.to_s
        self.c_numtext.text = @value.to_s
      else
        @value = num.clamp(@min, @max)
        set_text unless num >= @min && num <= @max
      end
    end
    
    # テキストボックスにテキストを設定
    def set_text
      self.c_numtext.text = @value.to_s
      refresh
    end
    
    ### 描画 ###
    # リフレッシュするか？
    def refresh?
      @refresh || c_numtext.activated?
    end
    
    # 描画継続中か？
    def rendering?
      c_numtext.activated? || c_add_s.activated? || c_sub_s.activated?
    end
    
    # 画像の作成
    def render
      
      if refresh?
        self.image = @render_target
        super
        # 描画を継続しない場合イメージ化して終了
        if !rendering?
          @image.dispose if @image
          @image = @render_target.to_image
          refreshed
        end
      else
        self.image = @image
      end
      
    end
    
  end
  
  
  
  
  ### ■NumberInputExt■ ###
  class WSNumberInputExt < WSNumberInput
    
    # 初期化
    def initialize(tx, ty, width, height)
      @big   = 10
      super
    end
    
    # コントロールの作成
    def create_controls
      # テキストボックスの作成
      c_numtext = WSTextBox.new(0, 0, width, height)
      c_numtext.add_handler(:change, method(:text_changed))
      c_numtext.add_handler(:leave){ check_text; signal(:change, @value) }
      c_numtext.add_key_handler(K_RETURN){ check_text; signal(:change, @value) }
      # スピンボタン変動小の作成
      font_s = Font.new(6)
      c_b_add_s = WSSpinButton.new(0, 0, 16, height / 2 - 1)
      c_b_add_s.font = font_s
      c_b_add_s.caption = "▲"
      c_b_add_s.add_handler(:click, self.method(:click_add_button_s))
      c_b_sub_s = WSSpinButton.new(0, 0, 16, height / 2 - 1)
      c_b_sub_s.font = font_s
      c_b_sub_s.caption = "▼"
      c_b_sub_s.add_handler(:click, self.method(:click_sub_button_s))
      # スピンボタン変動大の作成
      font_b = Font.new(8)
      c_b_add_b = WSSpinButton.new(0, 0, 16, height / 2 - 1)
      c_b_add_b.font = font_b
      c_b_add_b.caption = "▲"
      c_b_add_b.add_handler(:click, self.method(:click_add_button_b))
      c_b_sub_b = WSSpinButton.new(0, 0, 16, height / 2 - 1)
      c_b_sub_b.font = font_b
      c_b_sub_b.caption = "▼"
      c_b_sub_b.add_handler(:click, self.method(:click_sub_button_b))
      # コントロールの登録
      add_control(c_numtext, :c_numtext)
      add_control(c_b_add_s, :c_add_s)
      add_control(c_b_sub_s, :c_sub_s)
      add_control(c_b_add_b, :c_add_l)
      add_control(c_b_sub_b, :c_sub_l)
      
      # オートレイアウト
      layout(:hbox) do
        self.set_margin(0, 0, 0, 0)
        add obj.c_numtext, true, true
        layout(:vbox) do
          self.set_margin(1, 1, 0, 0)
          add obj.c_add_s, false, false
          add obj.c_sub_s, false, false
          self.resizable_width = false
          self.width = 16
        end
        layout(:vbox) do
          self.set_margin(1, 1, 0, 0)
          add obj.c_add_l, false, false
          add obj.c_sub_l, false, false
          self.resizable_width = false
          self.width = 16
        end
      end
      
    end
    
    # 加算ボタン大の押下処理
    def click_add_button_b(obj, tx, ty)
      @value = [@value + @big * (self.c_add_l.repeat_count / RATE), @max].min
      set_text
      signal(:change, @value)
    end
    
    # 減算ボタン大の押下処理
    def click_sub_button_b(obj, tx, ty)
      @value = [@value - @big * (self.c_sub_l.repeat_count / RATE), @min].max
      set_text
      signal(:change, @value)
    end
    
    # ステップ値の設定
    def step(small , big)
      @small = small
      @big   = big
    end
    
    # 描画継続中か？
    def rendering?
      c_numtext.activated? || c_add_s.activated? || c_sub_s.activated? || c_add_l.activated? || c_sub_l.activated?
    end
    
  end
  
end
