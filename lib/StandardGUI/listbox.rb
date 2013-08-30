# coding: utf-8
require_relative './scrollbar'

module WS

  # リストボックスクラス
  class WSListBox < WSContainer
    # リストボックス内のクライアント領域クラス
    # マウスボタンに反応する必要がある。
    class WSListBoxClient < WSContainer
      include DoubleClickable
    end

    attr_reader :items, :cursor
    attr_accessor :position

    def initialize(tx, ty, width, height)
      super
      self.image.bgcolor = C_WHITE
      @font = Font.new(12)
      @items = [] # リストの中身
      @position = 0    # 描画の基点
      @cursor = 0 # カーソルの位置

      # クライアント領域作成
      client = WSListBoxClient.new(0, 0, width - 4 - 16, height - 4)
      add_control(client, :client)
      client.add_handler(:mouse_push) do |obj, tx, ty|
        tmp = ((@position * @font.size + ty) / @font.size).to_i
        if tmp < @items.size
          @cursor = tmp
          signal(:select, @cursor) # 項目がクリックされたら:selectシグナル発行
        end
      end

      # スクロールバー作成
      sb = WSVScrollBar.new(0, 0, 16, height - 4)
      add_control(sb, :sb)
      sb.add_handler(:slide) {|obj, pos| @position = pos}
      sb.total = @items.length
      sb.screen_length = client.height.quo(@font.size)
      sb.unit_quantity = 1

      # マウスホイール処理
      client.add_handler(:mouse_wheel_up){sb.slide(-3)}
      client.add_handler(:mouse_wheel_down){sb.slide(3)}

      # オートレイアウト
      layout(:hbox) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        add client, true, true
        add sb, false, true
      end
    end

    # resize時にカーソル位置の反転画像を再生成する
    def resize(width, height)
      sb.total = @items.length
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(client.width, @font.size, C_BLACK)
      sb.screen_length = client.height.quo(@font.size)
    end

    def draw
      # リスト描画
      @items.each_with_index do |s, i|
        if @cursor != i
          client.image.draw_font(2, (i - @position) * @font.size, s.to_s, @font, :color=>C_BLACK)
        else
          client.image.draw(0, (i - @position) * @font.size, @cursor_image)
          client.image.draw_font(2, (i - @position) * @font.size, s.to_s, @font, :color=>C_WHITE)
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

      sb.total = @items.length

      # スクロールバーの描画が必要ない場合は描画しない
      if client.height.quo(@font.size) >= @items.length
        sb.visible = false
        sb.collision_enable = false
      else
        sb.visible = true
        sb.collision_enable = true
      end
      super
    end
  end
end
