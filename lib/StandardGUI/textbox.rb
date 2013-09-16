# coding: utf-8
require_relative '../rclip.rb'

module WS
  # テキストの選択範囲を表すクラス
  class TextRange
    attr_accessor :first, :last
    
    def initialize
      @first = @last = 0
    end

    def set(first, last)
      @first, @last = first, last
    end

    def empty
      @first = @last = 0
    end

    def empty?
      @first == @last
    end

    def min
      [@first, @last].min
    end

    def max
      [@first, @last].max
    end

    def to_range
      min...max
    end
  end

  # テキストボックス
  class WSTextBox < WSControl
    include Focusable
    attr_accessor :text

    def initialize(tx, ty, sx, sy)
      super(tx, ty, sx, sy)
      self.image = Image.new(sx, sy, C_WHITE)

      self.image.line(0,0,@width-1,0,[80,80,80])
                .line(0,0,0,@height-1,[80,80,80])
                .line(1,1,@width-1,1,[120,120,120])
                .line(1,1,1,@height-1,[120,120,120])
                .line(@width-2,1,@width-2,@height-2,[200,200,200])
                .line(1,@height-2,@width-2,@height-2,[200,200,200])
                .line(@width-1,0,@width-1,@height-1,[240,240,240])
                .line(0,@height-1,@width-1,@height-1,[240,240,240])
      @text = ""
      @cursor_count = 0 # カーソル点滅用カウント
      @cursor_pos = 0   # カーソル位置
      @selected_range = TextRange.new # 選択範囲
      @font = Font.new(12)
      @dragging_flag = false

      # 特殊キーのハンドラ
      add_key_handler(K_BACKSPACE) do
        if @selected_range.empty?
          if @cursor_pos > 0
            @text[@cursor_pos - 1] = ""
            @cursor_pos -= 1
          end
        else
          @text[@selected_range.to_range] = ""
          @cursor_pos = @selected_range.min
          @selected_range.empty
        end
      end

      add_key_handler(K_DELETE) do
        if @selected_range.empty?
          @text[@cursor_pos] = ""
        else
          @text[@selected_range.to_range] = ""
          @cursor_pos = @selected_range.min
          @selected_range.empty
        end
      end

      add_key_handler(K_LEFT) do
        if Input.shift?
          if @cursor_pos > 0
            if @selected_range.empty?
              @selected_range.set(@cursor_pos, @cursor_pos - 1)
            else
              @selected_range.last = @cursor_pos - 1
            end
          end
        else
          @selected_range.empty
        end
        @cursor_pos -= 1 if @cursor_pos > 0
      end

      add_key_handler(K_RIGHT) do
        if Input.shift?
          if @cursor_pos < @text.length
            if @selected_range.empty?
              @selected_range.set(@cursor_pos, @cursor_pos + 1)
            else
              @selected_range.last = @cursor_pos + 1
            end
          end
        else
          @selected_range.empty
        end
        @cursor_pos += 1 if @cursor_pos < @text.length
      end

      add_key_handler(K_HOME) do
        if Input.shift?
          if @selected_range.empty?
            @selected_range.set(@cursor_pos, 0)
          else
            @selected_range.last = 0
          end
        else
          @selected_range.empty
        end
        @cursor_pos = 0
      end

      add_key_handler(K_END) do
        if Input.shift?
          if @selected_range.empty?
            @selected_range.set(@cursor_pos, @text.length)
          else
            @selected_range.last = @text.length
          end
        else
          @selected_range.empty
        end
        @cursor_pos = @text.length
      end

      add_key_handler(K_CTRL + K_A) do
        @selected_range.set(0, @text.length)
      end

      add_key_handler(K_CTRL + K_X) do
        if !@selected_range.empty?
          Rclip.setData(@text[@selected_range.to_range])
          @text[@selected_range.to_range] = ""
          @selected_range.empty
        end
      end

      add_key_handler(K_CTRL + K_C) do
        if !@selected_range.empty?
          Rclip.setData(@text[@selected_range.to_range])
        end
      end

      add_key_handler(K_CTRL + K_V) do
        str = Rclip.getData.encode("UTF-8").gsub(/\r\n/, "").gsub(/\r/, "").gsub(/\n/, "")
        if @selected_range.empty?
          @text[@cursor_pos, 0] = str
        else
          @text[@selected_range.to_range] = str
          @cursor_pos = @selected_range.min
          @selected_range.empty
        end
        @cursor_pos += str.length
      end
    end

    # キーが押されたらカーソル点滅カウントを初期化
    def on_key_push(key)
      @cursor_count = 0
      super
    end

    # 文字が入力されたらカーソル位置に挿入
    def on_string(str)
      if @selected_range.empty?
        @text[@cursor_pos, 0] = str
      else
        @text[@selected_range.to_range] = str
        @cursor_pos = @selected_range.min
        @selected_range.empty
      end
      @cursor_pos += str.length
    end

    # カーソル点滅と位置設定処理
    def update
      if self.active?
        @cursor_count += 1
        tx, ty = self.get_global_vertex
        Input::IME.set_cursor(tx + @font.get_width(@text[0, @cursor_pos]) + 4, ty + 4)
      end
    end

    # フォーカス取得
    def on_enter
#      Input::IME.enable = true
      Input::IME.set_font(@font)
      @selected_range.set(0, @text.length)
      @cursor_pos = @text.length
      @cursor_count = 0
      super
    end

    # フォーカス喪失
    def on_leave
#      Input::IME.enable = false
      @selected_range.empty
      super
    end

    # マウス押したらカーソル移動
    def on_mouse_push(tx, ty)
      cx = 0
      @cursor_pos = @text.length
      @text.each_char.with_index do |c, i|
        cx += @font.get_width(c)
        if tx < cx + 4
          @cursor_pos = i
          break
        end
      end
      @cursor_count = 0

      # マウスでの範囲選択の準備
      @dragging_flag = true
      WS.capture(self)
      @drag_old_x = tx
      @drag_old_y = ty
      @selected_range.set(@cursor_pos, @cursor_pos)
      super
    end

    # 範囲選択終了
    def on_mouse_release(tx, ty)
      @dragging_flag = false
      WS.capture(nil)
      super
    end

    # ドラッグ操作で選択
    def on_mouse_move(tx, ty)
      if @dragging_flag
        cx = 0
        @cursor_pos = @text.length
        @text.each_char.with_index do |c, i|
          cx += @font.get_width(c)
          if tx < cx + 4
            @cursor_pos = i
            break
          end
        end
        @cursor_count = 0
  
        @selected_range.last = @cursor_pos
      end
      super
    end

    def draw
      super

      # 選択範囲表示
      if !@selected_range.empty? and self.active?
        tx1 = self.x + @font.get_width(@text[0, @selected_range.min]) + 4
        tx2 = self.x + @font.get_width(@text[0, @selected_range.max]) + 4
        (0..(@font.size+1)).each do |ty|
          self.target.draw_line(tx1, self.y + ty + 3, tx2, self.y + ty + 3, [200, 200, 255], self.z)
        end
      end

      # 文字列表示
      self.target.draw_font(self.x + 4, self.y + 4, @text, @font, :color=>C_BLACK, :z=>self.z)

      # カーソル表示
      if self.active? and (@cursor_count / 30) % 2 == 0
        tx = self.x + @font.get_width(@text[0, @cursor_pos]) + 4
        self.target.draw_line(tx, self.y + 3, tx, self.y + 2 + @font.size, C_BLACK, self.z)
      end
    end
  end
end
