# coding: utf-8
require_relative './module.rb'

module WS

  # リストボックスクラス
  class WSListBox < WSContainer
    # リストボックス内のクライアント領域クラス
    # マウスボタンに反応する必要がある。
    class WSListBoxClient < WSContainer
      include Clickable
      include DoubleClickable
    end

    attr_reader :items, :pos, :cursor

    def initialize(tx, ty, width, height)
      super
      self.image.bgcolor = C_WHITE
      @font = Font.new(12)
      @items = [] # リストの中身
      @pos = 0    # 描画の基点
      @cursor = 0 # カーソルの位置

      # クライアント領域作成
      client = WSListBoxClient.new(0, 0, width - 4 - 16, height - 4)
      add_control(client, :client)
      client.add_handler(:click) do |obj, tx, ty|
        tmp = ((@pos * @font.size + ty) / @font.size).to_i
        if tmp < @items.size
          @cursor = tmp
          signal(:select, @cursor) # 項目がクリックされたら:selectシグナル発行
        end
      end

      # スクロールバーオブジェクト作成
      sb = WSScrollBar.new(0, 0, 16, height - 4)
      add_control(sb, :scrollbar)
      sb.add_handler(:slide) {|obj, pos| @pos = pos * slide_range}
      sb.add_handler(:btn_up) do # ▲ボタン
        @pos -= 1
        @pos = 0 if @pos < 0
        sb.set_slider(@pos.quo(slide_range) )
      end
      sb.add_handler(:btn_down) do # ▼ボタン
        max = slide_range
        @pos += 1
        @pos = max if @pos > max
        sb.set_slider(@pos.quo(max) )
      end
      sb.add_handler(:page_up) do # スライダーの上の空き部分をクリック
        @pos -= client.height / @font.size
        @pos = 0 if @pos < 0
        sb.set_slider(@pos.quo(slide_range) )
      end
      sb.add_handler(:page_down) do # スライダーの下の空き部分をクリック
        max = slide_range
        @pos += client.height / @font.size
        @pos = max if @pos > max
        sb.set_slider(@pos.quo(max) )
      end

      # オートレイアウト
      layout(:hbox) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        add client, true, true
        add sb, false, true
      end
    end

    # resize時にカーソル位置の反転画像を再生成する
    def resize(width, height)
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(self.client.width, @font.size, C_BLACK)
    end

    def slide_range
      @items.length - client.height.quo(@font.size)
    end

    def draw
      # リスト描画
      @items.each_with_index do |s, i|
        if @cursor != i
          self.client.image.draw_font(2, (i - @pos) * @font.size, s.to_s, @font, :color=>C_BLACK)
        else
          self.client.image.draw(0, (i - @pos) * @font.size, @cursor_image)
          self.client.image.draw_font(2, (i - @pos) * @font.size, s.to_s, @font, :color=>C_WHITE)
        end
      end

      # ボーダーライン
      self.image.draw_line(0,0,@width-1,0,[80,80,80])
      self.image.draw_line(0,0,0,@height-1,[80,80,80])
      self.image.draw_line(1,1,@width-1,1,[120,120,120])
      self.image.draw_line(1,1,1,@height-1,[120,120,120])
      self.image.draw_line(@width-1,0,@width-1,@height-1,[240,240,240])
      self.image.draw_line(0,@height-1,@width-1,@height-1,[240,240,240])
      self.image.draw_line(@width-2,1,@width-2,@height-2,[200,200,200])
      self.image.draw_line(1,@height-2,@width-2,@height-2,[200,200,200])

      self.scrollbar.item_length = @items.length
      self.scrollbar.screen_length = self.client.height.quo(@font.size)
      # スクロールバーの描画が必要ない場合は描画しない
      if self.client.height.quo(@font.size) > @items.length
        self.scrollbar.visible = false
      else
        self.scrollbar.visible = true
      end
      super
    end
  end
end
