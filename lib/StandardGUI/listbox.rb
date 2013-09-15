# coding: utf-8
require_relative './scrollbar'

module WS

  # リストボックスクラス
  class WSListBox < WSScrollableContainer
    # リストボックス内のクライアント領域クラス
    # マウスボタンに反応する必要がある。か？
    class WSListBoxClient < WSContainer
      include DoubleClickable
    end

    include Focusable
    attr_reader :items, :cursor

    def initialize(tx, ty, width, height)
      # クライアント領域作成。WSScrollableContainerではsuperにクライアント領域コントロールを渡す必要があるので
      # superより先にこれだけ作る。
      client = WSListBoxClient.new(0, 0, width - 4 - 16, height - 4)
      super(tx, ty, width, height, client)

      self.image.bgcolor = C_WHITE
      @font = Font.new(12)
      @items = [] # リストの中身
      @cursor = 0 # カーソルの位置

      add_control(client, :client)
      client.add_handler(:mouse_push) do |obj, tx, ty|
        tmp = ((vsb.pos + ty) / @font.size).to_i
        if tmp < @items.size
          @cursor = tmp
          signal(:select, @cursor) # 項目がクリックされたら:selectシグナル発行
        end
      end

      # 縦スクロールバーを使うための設定。横スクロールバーは使わないので設定しない。
      vsb.total_size = @items.length * @font.size # リストボックス内データのサイズ(ピクセル単位)
      vsb.view_size = client.height               # 画面に見えているデータのサイズ(ピクセル単位)
      vsb.shift_qty = @font.size                  # 上下ボタンで動く量(ピクセル単位)

      # マウスホイール処理
      client.add_handler(:mouse_wheel_up){vsb.slide(-vsb.shift_qty * 3)}
      client.add_handler(:mouse_wheel_down){vsb.slide(vsb.shift_qty * 3)}

      # キーボードイベント
      add_key_handler(K_UP) do
        old_cursor = @cursor
        @cursor -= 1
        @cursor = @cursor.clamp(0, @items.length - 1)
        if @cursor * @font.size < vsb.pos
          vsb.pos = @cursor * @font.size
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_PGUP) do
        old_cursor = @cursor
        @cursor -= client.height / @font.size
        @cursor = @cursor.clamp(0, @items.length - 1)
        if @cursor * @font.size < vsb.pos
          vsb.pos = @cursor * @font.size
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_HOME) do
        old_cursor = @cursor
        @cursor = 0
        if @cursor * @font.size < vsb.pos
          vsb.pos = @cursor * @font.size
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_DOWN) do
        old_cursor = @cursor
        @cursor += 1
        @cursor = @cursor.clamp(0, @items.length - 1)
        if @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.height
          vsb.pos = @cursor * @font.size + @font.size - client.height
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_PGDN) do
        old_cursor = @cursor
        @cursor += client.height / @font.size
        @cursor = @cursor.clamp(0, @items.length - 1)
        if @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.height
          vsb.pos = @cursor * @font.size + @font.size - client.height
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_END) do
        old_cursor = @cursor
        @cursor = @items.length - 1
        if @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.height
          vsb.pos = @cursor * @font.size + @font.size - client.height
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
    end

    # resize時にカーソル位置の反転画像を再生成する
    def resize(width, height)
      vsb.total_size = @items.length * @font.size # itemsの配列はいつ書き換えられるかわからないからとりあえず再計算
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(width, @font.size, C_BLACK)
      vsb.view_size = client.height
    end

    def draw
      vsb.total_size = @items.length * @font.size # itemsの配列はいつ書き換えられるかわからないからとりあえず再計算

      # リスト描画
      @items.each_with_index do |s, i|
        if (i+1) * @font.size - vsb.pos >= 0 and i * @font.size - vsb.pos < client.height
          if @cursor != i
            client.image.draw_font(2, i * @font.size - vsb.pos, s.to_s, @font, :color=>C_BLACK)
          else
            client.image.draw(0, i * @font.size - vsb.pos, @cursor_image)
            client.image.draw_font(2, i * @font.size - vsb.pos, s.to_s, @font, :color=>C_WHITE)
          end
        end
      end
      super
    end
  end
end
