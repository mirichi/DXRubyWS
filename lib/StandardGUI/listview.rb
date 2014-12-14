# coding: utf-8
require_relative './scrollbar'
require_relative './common'

module WS
  # リストビュークラス
  class WSListView < WSScrollableContainer
    # リストビューのタイトル部分のクラス
    class WSListViewTitle < WSContainer
      attr_accessor :titles
      
      def initialize(tx, ty, width, height, titles)
        super(tx, ty, width, height)
        self.image.bgcolor = COLOR[:base]
        @font = Font.new(12)
        @titles = titles
        @titles_bak = nil
        @dragging_number = nil
      end
      
      def update
        pos = self.parent.parent.hsb.pos
        
        unless @titles == @titles_bak
          @titles_bak = @titles.map {|title| title.dup}
          @titles_image = []
          @titles.each do |title|
            img = Image.new(title[1], @height, COLOR[:base])
            img.draw_font_ex(3, 2, title[0].to_s, @font, color:COLOR[:font], aa:false)
            @titles_image << img
          end
          signal(:title_resize)
        end
      end
      
      def draw
        pos = self.parent.parent.hsb.pos
        
        # タイトル
        tx = 0
        @titles.each_with_index do |title, i|
          self.image.draw(tx - pos, 0, @titles_image[i])
          tx += title[1]
        end
        
        # ボーダー
        self.render_border(true)
        
        # セパレータ
        sx = @width
        sy = @height
        tx = 0
        ([["",0]]+@titles).each do |title|
          tx += title[1]
          self.image.draw_line(tx-2-pos,1,tx-2-pos,sy-3,COLOR[:darkshadow])
          self.image.draw_line(tx-1-pos,0,tx-1-pos,sy-2,COLOR[:shadow])
          self.image.draw_line(tx-pos  ,0,tx-pos  ,sy-2,COLOR[:highlight])
          self.image.draw_line(tx+1-pos,1,tx+1-pos,sy-3,COLOR[:light])
        end
        
        super
      end
      
      # 以下、セパレータドラッグ処理
      def on_mouse_push(tx, ty)
        total = 0
        @titles.size.times do |i|
          total += @titles[i][1]
          
          # セパレータの判定用Sprite生成
          s = Sprite.new(total - 2 - self.parent.parent.hsb.pos, 0)
          s.collision = [0, 0, 4, 15]
          
          # 判定
          @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
          if @hit_cursor === s
            # ドラッグ開始
            @dragging_number = i
            @drag_old_x = tx
            WS.capture(self)
          end
        end
        super
      end
      
      def on_mouse_release(tx, ty)
        @dragging_number = nil
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        WS.capture(nil)
        Input.set_cursor(IDC_ARROW) unless self === @hit_cursor
        super
      end
      
      def on_mouse_out
        Input.set_cursor(IDC_ARROW)
        super
      end
      
      def on_mouse_move(tx, ty)
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        total = 0
        flag = false
        @titles.size.times do |i|
          total += @titles[i][1]
          
          # セパレータの判定用Sprite生成
          s = Sprite.new(total - 2 - self.parent.parent.hsb.pos, 0)
          s.collision = [0, 0, 4, 15]
          
          # 判定
          if @hit_cursor === s
            Input.set_cursor(IDC_SIZEWE)
            flag = true
            break
          end
        end
        if !flag and @dragging_number == nil
          Input.set_cursor(IDC_ARROW)
        end
        
        # ドラッグ中処理
        if @dragging_number
          tmp = @titles[@dragging_number][1] + tx - @drag_old_x
          tmp = 1 if tmp < 1
          @titles[@dragging_number][1] = tmp
          @drag_old_x = tx if tmp > 1
          #          signal(:title_resize)
        end
        super
      end
    end
    
    class WSListViewMain < WSContainer
      def draw
        @parent.parent.vsb.total_size = @parent.parent.items.length * @parent.parent.font.size
        @parent.parent.hsb.total_size = @parent.title.titles.inject(0){|total, o| total += o[1]}
        
        # リスト描画
        total = @parent.title.titles.inject(0){|t, o| t += o[1]}
        @parent.parent.items.each_with_index do |item, i|
          if @parent.parent.cursor != i
            color = COLOR[:font]
          else
            self.image.draw(0 - @parent.parent.hsb.pos, i * @parent.parent.font.size - @parent.parent.vsb.pos, @parent.parent.cursor_image)
            color = COLOR[:font_reverse]
          end
          tmp = Encoding.default_external # コケる現象回避
          Encoding.default_external = Encoding::ASCII_8BIT
          item.each_with_index do |s, x|
            @parent.parent.client_tmp_rt[x].draw_font(2, i * @parent.parent.font.size - @parent.parent.vsb.pos, s.inspect, @parent.parent.font, :color=>color)
          end
          Encoding.default_external = tmp
        end
        tx = 0
        @parent.title.titles.size.times do |x|
          self.image.draw(tx - @parent.parent.hsb.pos, 0, @parent.parent.client_tmp_rt[x])
          tx += @parent.title.titles[x][1]
        end
        super
      end
    end
    
    # リストビュー内のクライアント領域クラス
    class WSListViewClient < WSContainer
      include DoubleClickable
      def initialize(x, y, width, height, titles)
        super(x, y, width, height)
        
        # タイトル作成
        title = WSListViewTitle.new(0, 0, width - 4 - 16, 16, titles)
        add_control(title, :title)
        
        # リストビュー本体
        listview = WSListViewMain.new(0, 0, width - 4 - 16, 16)
        add_control(listview, :listview)
        
        self.image.bgcolor = COLOR[:background]
        layout(:vbox) do
          add title, true, false
          add listview, true, true
        end
      end
    end
    
    attr_reader :items, :cursor, :client_tmp_rt
    attr_accessor :cursor_image
    include Focusable
    
    def initialize(tx, ty, width, height, titles)
      # クライアント領域作成。WSScrollableContainerではsuperにクライアント領域コントロールを渡す必要があるので
      # superより先にこれだけ作る。
      client = WSListViewClient.new(0, 16, width - 4 - 16, height - 4 - 16, titles)
      super(tx, ty, width, height, client)
      @font = Font.new(12)
      @items = [] # リストの中身
      @cursor = 0 # カーソルの位置
      @v_header_size = 16
      
      client.listview.add_handler(:mouse_push) do |obj, tx, ty|
        tmp = ((vsb.pos + ty) / @font.size).to_i
        if tmp < @items.size
          @cursor = tmp
          signal(:select, @cursor) # 項目がクリックされたら:selectシグナル発行
        end
      end
      
      client.title.add_handler(:title_resize) do
        @client_tmp_rt.each_with_index{|rt, i|rt.resize(client.title.titles[i][1], client.listview.height)}
        resize(@width, @height)
      end
      
      # 文字描画領域
      @client_tmp_rt = titles.map {|t|RenderTarget.new(t[1], client.listview.height)}
      
      # スクロールバーを使うための設定。
      vsb.view_size = client.listview.height       # 画面に見えているデータのサイズ(ピクセル単位)
      vsb.shift_qty = @font.size          # 上下ボタンで動く量(ピクセル単位)
      hsb.view_size = client.width        # 画面に見えているデータのサイズ(ピクセル単位)
      hsb.shift_qty = @font.size          # 上下ボタンで動く量(ピクセル単位)
      
      # マウスホイール処理
      client.listview.add_handler(:mouse_wheel_up){vsb.slide(-vsb.shift_qty * 3)}
      client.listview.add_handler(:mouse_wheel_down){vsb.slide(vsb.shift_qty * 3)}
      
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
        if @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.listview.height
          vsb.pos = @cursor * @font.size + @font.size - client.listview.height
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_PGDN) do
        old_cursor = @cursor
        @cursor += client.height / @font.size
        @cursor = @cursor.clamp(0, @items.length - 1)
        if @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.listview.height
          vsb.pos = @cursor * @font.size + @font.size - client.listview.height
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
      add_key_handler(K_END) do
        old_cursor = @cursor
        @cursor = @items.length - 1
        if @cursor * @font.size + (@font.size - 1) >= vsb.pos + client.listview.height
          vsb.pos = @cursor * @font.size + @font.size - client.listview.height
        end
        signal(:select, @cursor) if old_cursor != @cursor
      end
    end
    
    def resize(width, height)
      vsb.total_size = @items.length * @font.size
      hsb.total_size = client.title.titles.inject(0){|t, o| t += o[1]}
      super
      vsb.view_size = client.listview.height
      hsb.view_size = client.width
      @client_tmp_rt.each_with_index{|rt, i|rt.resize(client.title.titles[i][1], client.listview.height)}
      
      # カーソル位置の画像を生成する
      if !@cursor_image or @cursor_image.width != hsb.total_size
        @cursor_image.dispose if @cursor_image
        @cursor_image = Image.new(hsb.total_size, @font.size, COLOR[:select])
      end
    end
  end
end
