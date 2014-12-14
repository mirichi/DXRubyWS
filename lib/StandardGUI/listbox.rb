# coding: utf-8
require_relative './scrollbar'

module WS
  
  # リストボックスクラス
  class WSListBox < WSScrollableContainer
    # リストボックス内のクライアント領域クラス
    # マウスボタンに反応する必要がある。か？
    class WSListBoxClient < WSContainer
      include DoubleClickable
      
      def initialize(*)
        super
        self.image.bgcolor = COLOR[:background]
      end
      
      # 描画
      def render
        @parent.vsb.total_size = @parent.items.length * @parent.font.size # itemsの配列はいつ書き換えられるかわからないからとりあえず再計算
        
        # リスト描画
        @parent.items.each_with_index do |s, i|
          if (i+1) * @parent.font.size - @parent.vsb.pos >= 0 and i * @parent.font.size - @parent.vsb.pos < @height
            if @parent.cursor != i
              self.image.draw_font(2, i * @parent.font.size - @parent.vsb.pos, s.to_s, @parent.font, :color=>COLOR[:font])
            else
              self.image.draw(0, i * @parent.font.size - @parent.vsb.pos, @parent.cursor_image)
              self.image.draw_font(2, i * @parent.font.size - @parent.vsb.pos, s.to_s, @parent.font, :color=>COLOR[:font_reverse])
            end
          end
        end
        super
      end
    end
    
    # Mix-In
    include Focusable
    
    # 公開インスタンス
    attr_reader :items, :cursor, :cursor_image
    
    
    # 初期化
    def initialize(tx=nil, ty=nil, width=nil, height=nil)
      # クライアント領域作成。WSScrollableContainerではsuperにクライアント領域コントロールを渡す必要があるので
      # superより先にこれだけ作る。
      client = WSListBoxClient.new
      super(tx, ty, width, height, client)
      
      @font = Font.new(12)
      @items = [] # リストの中身
      @cursor = 0 # カーソルの位置
      
      client.add_handler(:mouse_push) do |obj, tx, ty|
        tmp = ((vsb.pos + ty) / @font.size).to_i
        if tmp < @items.size
          @cursor = tmp
          signal(:select, @cursor) # 項目がクリックされたら:selectシグナル発行
        end
      end
      
      # 縦スクロールバーを使うための設定。横スクロールバーは使わないので設定しない。
      vsb.total_size = @items.length * @font.size # リストボックス内データのサイズ(ピクセル単位)
      vsb.view_size = client.height if client.height # 画面に見えているデータのサイズ(ピクセル単位)
      vsb.shift_qty = @font.size                  # 上下ボタンで動く量(ピクセル単位)
      
      # マウスホイール処理
      client.add_handler(:mouse_wheel_up){vsb.slide(-vsb.shift_qty * 3)}
      client.add_handler(:mouse_wheel_down){vsb.slide(vsb.shift_qty * 3)}
      
      # キーボードイベント
      add_key_handler(K_UP) do
        set_cursor(@cursor - 1)
      end
      
      add_key_handler(K_PGUP) do
        set_cursor(@cursor - client.height / @font.size)
      end
      
      add_key_handler(K_HOME) do
        set_cursor(0)
      end
      
      add_key_handler(K_DOWN) do
        set_cursor(@cursor + 1)
      end
      
      add_key_handler(K_PGDN) do
        set_cursor(@cursor + client.height / @font.size)
      end
      
      add_key_handler(K_END)  do
        set_cursor(@cursor = @items.length - 1)
      end
    end
    
    # カーソル位置設定
    def set_cursor(index, event = true)
      old_cursor = @cursor
      @cursor = index
      @cursor = @cursor.clamp(0, @items.length - 1)
      if @cursor * @font.size < vsb.pos
        vsb.pos = @cursor * @font.size
      elsif @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.height
        vsb.pos = @cursor * @font.size + @font.size - client.height
      end
      signal(:select, @cursor) if old_cursor != @cursor && event
    end
    
    # 項目の設定
    def set_items(value)
      @items = value
      resize(@width, @height)
    end
    
    # カーソル位置の項目を取得
    def item
      @items[@cursor]
    end
    
    # resize時にカーソル位置の反転画像を再生成する
    def resize(width, height)
      vsb.total_size = @items.length * @font.size # itemsの配列はいつ書き換えられるかわからないからとりあえず再計算
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(width, @font.size, COLOR[:select])
    end
  end
end
