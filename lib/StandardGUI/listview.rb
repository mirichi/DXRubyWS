# coding: utf-8
require_relative './scrollbar'

module WS
  # リストビュークラス
  class WSListView < WSContainer
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
  
      def on_mouse_push(tx, ty)
        total = 0
        # セパレータの判定用Sprite生成
        @titles.size.times do |i|
          total += @titles[i][1]
          s = Sprite.new(total - 2, 0)
          s.collision = [0, 0, 3, 15]

          # 判定
          @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
          if @hit_cursor === s
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
#        WS.capture(nil)
        Input.set_cursor(IDC_ARROW)
        super
      end

      def on_mouse_move(tx, ty)
        @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
        total = 0
        flag = false
        @titles.size.times do |i|
          total += @titles[i][1]
          s = Sprite.new(total - 2, 0)
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

        if @dragging_number
          tmp = @titles[@dragging_number][1] + tx - @drag_old_x
          tmp = 0 if tmp < 0
          @titles[@dragging_number][1] = tmp
          @drag_old_x = tx if tmp > 0
        end
        super
      end
    end

    # リストビュー内のクライアント領域クラス
    # マウスボタンに反応する必要がある。
    class WSListViewClient < WSContainer
      include DoubleClickable
    end

    attr_reader :items, :cursor
    attr_accessor :vposition, :hposition

    def initialize(tx, ty, width, height, titles)
      super(tx, ty, width, height)
      self.image.bgcolor = C_WHITE
      @font = Font.new(12)
      @items = [] # リストの中身
      @vposition = @hposition = 0    # 描画の基点
      @cursor = 0 # カーソルの位置

      # タイトル作成
      title = WSListViewTitle.new(0, 0, width - 4 - 16, 16, titles)
      add_control(title, :title)

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

      # スクロールバー作成
      vsb = WSVScrollBar.new(0, 0, 16, height - 4)
      add_control(vsb, :vsb)
      vsb.add_handler(:slide) {|obj, pos| @vposition = pos}
      vsb.total = @items.length
      vsb.screen_length = client.height.quo(@font.size)
      vsb.unit_quantity = 1

      # スクロールバー作成
      hsb = WSHScrollBar.new(0, 0, width - 4, 16)
      add_control(hsb, :hsb)
      hsb.add_handler(:slide) {|obj, pos| @hposition = pos; title.position = pos}
      hsb.total = client.width
      hsb.screen_length = client.width # 暫定
      hsb.unit_quantity = 1

      # マウスホイール処理
      client.add_handler(:mouse_wheel_up){vsb.slide(-3)}
      client.add_handler(:mouse_wheel_down){vsb.slide(3)}

      # オートレイアウト
      layout(:vbox) do
        self.margin_left = self.margin_top = self.margin_right = self.margin_bottom = 2
        layout(:hbox) do
          layout(:vbox) do
            add title, true, false
            add client, true, true
          end
          add vsb, false, true
        end
        layout(:hbox) do
          self.resizable_height = false
          self.height = 16
          add hsb, true, false
          layout do
            self.width = self.height = 16
            self.resizable_width = self.resizable_height = false
          end
        end
      end
    end

    # resize時にカーソル位置の反転画像を再生成する
    def resize(width, height)
      vsb.total = @items.length
      hsb.total = title.titles.inject(0){|t, o| t += o[1]}
      super
      @cursor_image.dispose if @cursor_image
      @cursor_image = Image.new(hsb.total, @font.size, C_BLACK)
      vsb.screen_length = client.height.quo(@font.size)
      hsb.screen_length = client.width
    end

    def set_scrollbar
      vsb.total = @items.length
      hsb.total = title.titles.inject(0){|total, o| total += o[1]}

      # スクロールバーの描画が必要ない場合は描画しない
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
        tx = 0
        item.each_with_index do |s, x|
          client.image.draw_font(2 + tx - @hposition, (i - @vposition) * @font.size, s.to_s, @font, :color=>color)
          tx += title.titles[x][1]
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
      super
    end
  end
end
