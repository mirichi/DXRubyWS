# coding: utf-8
require_relative './scrollbar'

module WS
  # リストビュークラス
  class WSListView < WSContainer
    # リストビューのタイトル部分のクラス
    class WSListViewTitle < WSContainer
      attr_reader :titles
      attr_accessor :position

      def initialize(tx, ty, width, height, titles)
        super(tx, ty, width, height)
        self.image.bgcolor = [190,190,190]
        @font = Font.new(12)
        @titles = titles
        @position = 0
        @dragging_number = nil
      end

      def draw
        # ボーダー
        sx = @width
        sy = @height
        self.image.draw_line(0,0,sx-1,0,[240,240,240])
        self.image.draw_line(1,1,sx-1,1,[200,200,200])
        self.image.draw_line(0,sy-1,sx-1,sy-1,[80,80,80])
        self.image.draw_line(1,sy-2,sx-2,sy-2,[120,120,120])

        # セパレータ
        tx = 0
        ([["",0]]+@titles).each do |title|
          tx += title[1]
          self.image.draw_line(tx-2-@position,1,tx-2-@position,sy-3,[80,80,80])
          self.image.draw_line(tx-1-@position,0,tx-1-@position,sy-2,[120,120,120])
          self.image.draw_line(tx-@position  ,0,tx-@position  ,sy-2,[240,240,240])
          self.image.draw_line(tx+1-@position,1,tx+1-@position,sy-3,[200,200,200])
        end

        # タイトル
        tx = 0
        @titles.each do |title|
          self.image.draw_font(tx + 3-@position, 2, title[0].to_s, @font, :color=>C_BLACK)
          tx += title[1]
        end

        super
      end

      # 以下、セパレータドラッグ処理
      def on_mouse_push(tx, ty)
        total = 0
        @titles.size.times do |i|
          total += @titles[i][1]

          # セパレータの判定用Sprite生成
          s = Sprite.new(total - 2 - @position, 0)
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
          s = Sprite.new(total - 2 - @position, 0)
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
          signal(:title_resize)
        end
        super
      end
    end

    # リストビュー内のクライアント領域クラス
    class WSListViewClient < WSContainer
      include DoubleClickable
      def initialize(*args)
        super
        self.image.bgcolor = C_WHITE
      end
    end

    attr_reader :items, :cursor
    attr_accessor :vposition, :hposition

    def initialize(tx, ty, width, height, titles)
      super(tx, ty, width, height)
      self.image.bgcolor = [190,190,190]
      @font = Font.new(12)
      @items = [] # リストの中身
      @vposition = @hposition = 0    # 描画の基点
      @cursor = 0 # カーソルの位置

      # タイトル作成
      title = WSListViewTitle.new(0, 0, width - 4 - 16, 16, titles)
      add_control(title, :title)
      title.add_handler(:title_resize) do
        @client_tmp_rt.each_with_index{|rt, i|rt.resize(title.titles[i][1], client.height)}
      end

      # クライアント領域作成
      client = WSListViewClient.new(0, 16, width - 4 - 16, height - 4 - 16)
      add_control(client, :client)
      client.add_handler(:mouse_push) do |obj, tx, ty|
        tmp = ((@vposition * @font.size + ty) / @font.size).to_i
        if tmp < @items.size
          @cursor = tmp
          signal(:select, @cursor) # 項目がクリックされたら:selectシグナル発行
        end
      end

      # 文字描画領域
      @client_tmp_rt = titles.map {|t|RenderTarget.new(t[1], client.height)}

      # 縦スクロールバー作成
      vsb = WSVScrollBar.new(0, 0, 16, height - 4)
      add_control(vsb, :vsb)
      vsb.add_handler(:slide) {|obj, pos| @vposition = pos}
      vsb.total_size = @items.length
      vsb.view_size = client.height.quo(@font.size)
      vsb.shift_qty = 1

      # 横スクロールバー作成
      hsb = WSHScrollBar.new(0, 0, width - 4, 16)
      add_control(hsb, :hsb)
      hsb.add_handler(:slide) {|obj, pos| @hposition = title.position = pos}
      hsb.total_size = client.width
      hsb.view_size = client.width # 暫定
      hsb.shift_qty = 10

      # マウスホイール処理
      client.add_handler(:mouse_wheel_up){vsb.slide(-3)}
      client.add_handler(:mouse_wheel_down){vsb.slide(3)}

      set_scrollbar
    end

    # resize時にカーソル位置の反転画像を再生成する
    def resize(width, height)
      vsb.total_size = @items.length
      hsb.total_size = title.titles.inject(0){|t, o| t += o[1]}
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(hsb.total_size, @font.size, C_BLACK)
      vsb.view_size = client.height.quo(@font.size)
      hsb.view_size = client.width
      @client_tmp_rt.each_with_index{|rt, i|rt.resize(title.titles[i][1], client.height)}
    end

    def set_scrollbar
      vsb.total_size = @items.length
      hsb.total_size = title.titles.inject(0){|total, o| total += o[1]}

      # スクロールバーの描画が必要ない場合は描画しない(つくりかけ)
     if client.height.quo(@font.size) >= @items.length
        if vsb.visible
          vsb.visible = false
          vsb.collision_enable = false
          layout(:vbox) do
            self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
            layout(:hbox) do
              layout(:vbox) do
                add obj.title, true, false
                add obj.client, true, true
              end
            end
            layout(:hbox) do
              self.resizable_height = false
              self.height = 16
              add obj.hsb, true, false
            end
          end
        end
      else
        unless vsb.visible
          vsb.visible = true
          vsb.collision_enable = true
          layout(:vbox) do
            self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
            layout(:hbox) do
              layout(:vbox) do
                add obj.title, true, false
                add obj.client, true, true
              end
              add obj.vsb, false, true
            end
            layout(:hbox) do
              self.resizable_height = false
              self.height = 16
              add obj.hsb, true, false
              layout do
                self.width = self.height = 16
                self.resizable_width = self.resizable_height = false
              end
            end
          end
        end
      end
    end

    def draw
      set_scrollbar

      # リスト描画
      total = title.titles.inject(0){|t, o| t += o[1]}
      @items.each_with_index do |item, i|
        if @cursor != i
          color = C_BLACK
        else
          client.image.draw(0 - @hposition, (i - @vposition) * @font.size, @cursor_image)
          color = C_WHITE
        end
        item.each_with_index do |s, x|
          @client_tmp_rt[x].draw_font(2, (i - @vposition) * @font.size, s.to_s, @font, :color=>color)
        end
      end
      tx = 0
      title.titles.size.times do |x|
        client.image.draw(tx - @hposition, 0, @client_tmp_rt[x])
        tx += title.titles[x][1]
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
      super
    end
  end
end
