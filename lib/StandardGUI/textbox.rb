# coding: utf-8

module WS
  # テキストボックス
  class WSTextBox < WSControl
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
      @cursor_count = 0
      @cursor_pos = 0
      @active = false
      @font = Font.new(12)

      # 特殊キーのハンドラ
      add_key_handler(K_BACKSPACE) do
        if @cursor_pos > 0
          @text[@cursor_pos-1] = ""
          @cursor_pos -= 1
        end
      end

      add_key_handler(K_DELETE) do
        if @cursor_pos <= @text.length
          @text[@cursor_pos] = ""
        end
      end

      add_key_handler(K_LEFT) do
        if @cursor_pos > 0
          @cursor_pos -= 1
        end
      end

      add_key_handler(K_RIGHT) do
        if @cursor_pos < @text.length
          @cursor_pos += 1
        end
      end

      add_key_handler(K_HOME) do
        @cursor_pos = 0
      end

      add_key_handler(K_END) do
        @cursor_pos = @text.length
      end
    end

    def on_key_push(key)
      @cursor_count = 0
      super
    end

    def on_string(str)
      @text[@cursor_pos, 0] = str
      @cursor_pos += str.length
    end

    def update
      if @active
        @cursor_count += 1
        tx, ty = self.get_global_vertex
        Input::IME.set_cursor(tx + @font.get_width(@text[0, @cursor_pos]) + 4, ty + 4)
      end
    end

    def on_enter
      @active = true
      Input::IME.enable = true
      [K_BACKSPACE, K_DELETE, K_LEFT, K_RIGHT].each do |k|
        Input.set_key_repeat(k, 30, 2)
      end
      Input::IME.set_font(@font)
    end

    def on_leave
      @active = false
      [K_BACKSPACE, K_DELETE, K_LEFT, K_RIGHT].each do |k|
        Input.set_key_repeat(k, 0, 0)
      end
      Input::IME.enable = false
    end

    def draw
      super

      # 文字列表示
      self.target.draw_font(self.x + 4, self.y + 4, @text, @font, :color=>C_BLACK)

      # カーソル表示
      if @active and (@cursor_count / 30) % 2 == 0
        tx = self.x + @font.get_width(@text[0, @cursor_pos]) + 4
        self.target.draw_line(tx, self.y + 3, tx, self.y + 2 + @font.size, C_BLACK)
      end
    end
  end
end
