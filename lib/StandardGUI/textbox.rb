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

    def clear
      @first = @last = 0
    end

    def empty?
      @first == @last
    end

    def min
      @first < @last ? @first : @last
    end

    def max
      @first > @last ? @first : @last
    end

    def to_range
      min...max
    end
  end

  # テキストボックス
  class WSTextBox < WSControl
    include Focusable
    attr_reader :text

    def initialize(tx, ty, sx, sy)
      super(tx, ty, sx, sy)
      self.image = Image.new(sx, sy, COLOR[:background]).draw_border(false)
      @text = ""
      @cursor_count = 0 # カーソル点滅用カウント
      @cursor_pos = 0   # カーソル位置
      @selected_range = TextRange.new # 選択範囲
      @draw_range = TextRange.new     # 描画範囲
      @font = Font.new(12)
      @dragging_flag = false
      @border_width = 2

      # 特殊キーのハンドラ
      add_key_handler(K_BACKSPACE) do
        before = @text.dup
        if @selected_range.empty?
          if @cursor_pos > 0
            @text[@cursor_pos - 1] = ""
            @cursor_pos -= 1
          end
        else
          @text[@selected_range.to_range] = ""
          @cursor_pos = @selected_range.min
          @selected_range.clear
        end

        adjust_left
        signal(:changed, @text) if before != @text
      end

      add_key_handler(K_DELETE) do
        before = @text.dup
        if @selected_range.empty?
          @text[@cursor_pos] = ""
        else
          @text[@selected_range.to_range] = ""
          @cursor_pos = @selected_range.min
          @selected_range.clear
        end

        adjust_left
        signal(:change, @text) if before != @text
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
          @selected_range.clear
        end
        @cursor_pos -= 1 if @cursor_pos > 0

        adjust_left
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
          @selected_range.clear
        end
        @cursor_pos += 1 if @cursor_pos < @text.length

        adjust_right
      end

      add_key_handler(K_HOME) do
        if Input.shift?
          if @selected_range.empty?
            @selected_range.set(@cursor_pos, 0)
          else
            @selected_range.last = 0
          end
        else
          @selected_range.clear
        end
        @cursor_pos = 0

        adjust_left
      end

      add_key_handler(K_END) do
        if Input.shift?
          if @selected_range.empty?
            @selected_range.set(@cursor_pos, @text.length)
          else
            @selected_range.last = @text.length
          end
        else
          @selected_range.clear
        end
        @cursor_pos = @text.length

        adjust_right
      end

      add_key_handler(K_CTRL + K_A) do
        self.all_select
        adjust_right
      end

      add_key_handler(K_CTRL + K_X) do
        before = @text.dup
        if !@selected_range.empty?
          Rclip.setData(@text[@selected_range.to_range].encode("SJIS"))
          @text[@selected_range.to_range] = ""
          @cursor_pos = @selected_range.min
          @selected_range.clear
          set_draw_range
        end
        signal(:change, @text) if before != @text
      end

      add_key_handler(K_CTRL + K_C) do
        if !@selected_range.empty?
          Rclip.setData(@text[@selected_range.to_range].encode("SJIS"))
        end
      end

      add_key_handler(K_CTRL + K_V) do
        before = @text.dup
        str = Rclip.getData.force_encoding("SJIS").encode("UTF-8").gsub(/\r\n/, "").gsub(/\r/, "").gsub(/\n/, "")
        @text = @text.dup
        if @selected_range.empty?
          @text[@cursor_pos, 0] = str
        else
          @text[@selected_range.to_range] = str
          @cursor_pos = @selected_range.min
          @selected_range.clear
        end
        @cursor_pos += str.length
        
        adjust_right
        signal(:change, @text) if before != @text
      end
    end

    # コントロールの値を参照
    def value
      @text
    end
    
    # コントロールに値を設定
    def value=(v)
      self.text = v
    end
    
    def all_select
      @selected_range.set(0, @text.length)
      @cursor_pos = @text.length
    end

    def size_limit
      @width - @border_width - 2 - 2
    end

    # キーが押されたらカーソル点滅カウントを初期化
    def on_key_push(key)
      @cursor_count = 0
      super
    end

    # 文字が入力されたらカーソル位置に挿入
    def on_string(str)
      before = @text.dup
      @text = @text.dup
      if @selected_range.empty?
        @text[@cursor_pos, 0] = str
      else
        @text[@selected_range.to_range] = str
        @cursor_pos = @selected_range.min
        @selected_range.clear
      end
      @cursor_pos += str.length

      adjust_right
      if before != @text
        signal(:change, @text)
      end
    end

    def adjust_left
      if @cursor_pos < @draw_range.first
        # テキストボックスの左端にカーソルがはみ出した
        @draw_range.first = @cursor_pos
      end
      set_draw_range
    end

    def adjust_right
      tmp = @font.get_width(@text[@draw_range.first...@cursor_pos])
      # テキストボックスの右端にカーソルがはみ出した
      if tmp > size_limit
        pos = @draw_range.first
        while @font.get_width(@text[pos...@cursor_pos]) >= size_limit do
          pos += 1
        end
        @draw_range.first = pos
        @draw_range.last = @cursor_pos
      else
        @draw_range.last = @text.length
        set_draw_range
      end
    end

    def set_draw_range
      if @text.length == 0
        @cursor_pos = 0
        @selected_range.set(0, 0)
        @draw_range.set(0, 0)
      else
        tmp = @font.get_width(@text[@draw_range.to_range])
        if tmp > size_limit
          @draw_range.last = @draw_range.first
          tmp = @font.get_width(@text[@draw_range.to_range])
          while tmp <= size_limit do
            @draw_range.last += 1
            tmp = @font.get_width(@text[@draw_range.to_range])
          end
          @draw_range.last -= 1
        else
          begin
            @draw_range.first -= 1
            tmp = @font.get_width(@text[@draw_range.to_range])
          end while tmp < size_limit and @draw_range.first >= 0
          @draw_range.first += 1
        end
      end
    end

    # カーソル点滅と位置設定処理
    def update
      if self.activated?
        @cursor_count += 1
        tx, ty = self.get_global_vertex
      end
    end

    # フォーカス取得
    def on_enter
      Input::IME.enable = true
      @cursor_pos = @text.length
      @cursor_count = 0
      @selected_range.set(0, @text.length)
      @on_enter = true
      super
    end

    # フォーカス喪失
    def on_leave
      Input::IME.enable = false
      @selected_range.clear
      super
    end

    # マウス押したらカーソル移動
    def on_mouse_push(tx, ty)
      unless @on_enter
      cx = 0
      tx += @font.get_width(@text[0...@draw_range.first])
      @cursor_pos = @text.length
      @text.each_char.with_index do |c, i|
        cx += @font.get_width(c)
        if tx < cx + @border_width + 2
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
      else
        @on_enter = false
      end
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
        tx += @font.get_width(@text[0...@draw_range.first])
        @text.each_char.with_index do |c, i|
          cx += @font.get_width(c)
          if tx < cx + @border_width + 2
            @cursor_pos = i
            break
          end
        end
        @cursor_count = 0
  
        @selected_range.last = @cursor_pos
      end
      adjust_right
      adjust_left
      super
    end

    def draw
      super

      if Input::IME.compositing? and self.activated?
        info = Input::IME.get_comp_info
        if info.comp_str.size > 0
          # 変換入力中
          str1 = @text[@draw_range.first...@cursor_pos]
          str2 = info.comp_str
          str3 = @text[@cursor_pos...@draw_range.last]
          size1 = @font.get_width(str1)
          size2 = @font.get_width(str2)
          size3 = @font.get_width(str3)
          limit = size_limit
          str = ""

          if size2 > limit
            # 入力中文字列だけで範囲を超える
            begin
              str2 = str2[1..-1]
            end while @font.get_width(str2) > limit
            str = str2
          elsif size1 + size2 > limit
            # 前部分と入力中文字列だけで範囲を超える
            begin
              str1 = str1[1..-1]
            end while @font.get_width(str1) + size2 > limit
            str = str1 + str2
          elsif size1 + size2 + size3 > limit
            # 全体で範囲を超える
            begin
              str3 = str3[0..-2]
            end while size1 + size2 + @font.get_width(str3) > limit
            str = str1 + str2 + str3
          else
            str = str1 + str2 + str3
          end

# とりあえず適当に表示してみたテスト
          if info.can_list.size > 0
            gx, gy = get_global_vertex
            wx = gx + @border_width + 2 + @font.get_width(str1)
            wy = gy + @border_width + 2 + @font.size
            sx = @font.get_width(info.comp_str)
            
            info.can_list.each do |s|
              tlen = @font.get_width(s)
              if sx < tlen
                sx = tlen
              end
            end

            sx += 8
            sy = @font.size * info.page_size + 8

            Window.draw_line(wx, wy, wx+sx-1, wy, COLOR[:highlight], WS::default_z + 1)
            Window.draw_line(wx, wy, wx, wy+sy-1, COLOR[:highlight], WS::default_z + 1)
            Window.draw_line(wx+1, wy+1, wx+sx-1, wy+1, COLOR[:light], WS::default_z + 1)
            Window.draw_line(wx+1, wy+1, wx+1, wy+sy-1, COLOR[:light], WS::default_z + 1)
            Window.draw_line(wx+sx-1, wy, wx+sx-1, wy+sy-1, COLOR[:darkshadow], WS::default_z + 1)
            Window.draw_line(wx,wy+sy-1,  wx+sx-1, wy+sy-1, COLOR[:darkshadow], WS::default_z + 1)
            Window.draw_line(wx+sx-2, wy+1, wx+sx-2, wy+sy-2, COLOR[:shadow], WS::default_z + 1)
            Window.draw_line(wx+1, wy+sy-2, wx+sx-2, wy+sy-2, COLOR[:shadow], WS::default_z + 1)
            Window.draw_box_fill(wx+2, wy+2, wx + sx - 2, wy + sy - 2, COLOR[:base], WS::default_z + 1)

            info.can_list.each_with_index do |c, i|
              if info.selection == i
                Window.draw_box_fill(wx + 3, wy + @font.size * i + 3, wx + sx - 3, wy + @font.size * (i+1) + 3, C_BLUE, WS::default_z + 1)
                Window.draw_font(wx + 4, wy + @font.size * i + 4, c, @font, :color=>COLOR[:font_reverse], :z=>WS::default_z + 1)
              else
                Window.draw_font(wx + 4, wy + @font.size * i + 4, c, @font, :color=>COLOR[:font], :z=>WS::default_z + 1)
              end
            end
          end
        else
          str = @text[@draw_range.to_range]
        end

        # 文字列表示
        self.target.draw_font(self.x + @border_width + 2, self.y + @border_width + 2, str, @font, :color=>COLOR[:font], :z=>self.z)

      else
        # 選択範囲表示
        if !@selected_range.empty? and self.activated?
          tx1 = self.x + @border_width + 2 + @font.get_width(@text[@draw_range.first...@selected_range.min])
          tx2 = self.x + @border_width + 2 + @font.get_width(@text[0, [@selected_range.max, @draw_range.last].min]) - @font.get_width(@text[0, @draw_range.first])
          (0..(@font.size+1)).each do |ty|
            self.target.draw_line(tx1, self.y + ty + @border_width + 1, tx2, self.y + ty + @border_width + 1, [200, 200, 255], self.z)
          end
        end
  
        # 文字列表示
        self.target.draw_font(self.x + @border_width + 2, self.y + @border_width + 2, @text[@draw_range.to_range], @font, :color=>COLOR[:font], :z=>self.z)
  
        # カーソル表示
        if self.activated? and (@cursor_count / 30) % 2 == 0
          tx = self.x + @font.get_width(@text[@draw_range.first, @cursor_pos - @draw_range.first]) + @border_width + 2
          self.target.draw_line(tx, self.y + @border_width + 1, tx, self.y + @border_width + @font.size, COLOR[:font], self.z)
        end
      end
    end

    def text=(t)
      @text = t
      @selected_range.clear
      @draw_range.set(0, @text.length)
      @cursor_pos = 0
      set_draw_range
    end

    def resize(w, h)
      self.image.dispose if self.image
      self.image = Image.new(w, h, COLOR[:background]).draw_border(false)
      super
    end
  end
end
