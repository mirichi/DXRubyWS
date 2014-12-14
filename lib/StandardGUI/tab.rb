# coding: utf-8

module WS
  
  class WSControl
    
    # 表示
    def show
      self.visible = true
      self.collision_enable = true
    end
    
    # 隠す
    def hide
      self.visible = false
      self.collision_enable = false
    end
    
  end
  
  
  
  
  class WSContainer
    
    # 衝突判定可能状態の設定
    def collision_enable=(value)
      super
      @childlen.each do |c| c.collision_enable = value end
    end
    
  end
  
  
  ### ■タブコンテナクラスの定義■ ###
  class WSTab < WSLightContainer
    
    # 初期化
    def initialize(sx, sy, width, height, tab_height = 24)
      super(sx, sy, width, height)
      @tab_height = tab_height
      @tabs   = {}
      @panels = {}
      create_controls
    end
    
    # コントロールの作成
    def create_controls
      panel_container = WSTabPanelContainer.new(0, tab_height - 1, width, panel_height + 1)
      add_control(panel_container, :panel_container)
    end
    
    # タブと標準パネルの作成
    def create_tab_set(name, caption = "", pw = nil, ph = nil)
      tw = pw || @width
      th = ph || panel_height
      # パネルの作成
      panel = WSTabPanel.new(0, panel_y, tw, th)
      create_tab(panel, name, caption)
    end
    
    # タブの作成
    def create_tab(panel, name, caption = "")
      # パネル位置とサイズの修正
      panel.y = 0#panel_y
      #panel.resize(@width, panel_height)
      # パネルの登録
      panel_container.add_panel(panel, name)
      @panels[name] = panel
      # タブの作成
      tab      = WSTabButton.new(0, 0, @width / 4, tab_height, caption)
      tab.font = @font
      tab.set_panel(panel)
      self.add_control(tab)
      @tabs[name] = tab
      # ハンドラの作成
      tab.add_handler(:click, method(:change_tab))
      # タブの再配置
      arrange_tabs
      panel
    end
    
    # パネルの参照
    def panel(name)
      @panels[name]
    end
    
    # タブの高さ
    def tab_height
      @tab_height
    end
    
    # パネルのY座標
    def panel_y
      tab_height - 1
    end
    
    # パネルの高さ
    def panel_height
      @height - panel_y + 1
    end
    
    ### タブの処理 ###
    # タブの選択
    def select_tab(name)
      change_tab(@tabs[name], 0, 0)
    end
    
    # 選択タブの変更
    def change_tab(obj, sx, sy)
      @tabs.each_value do |tab| tab.release_tab end
      obj.select_tab
      panel_container.activate_panel(obj.panel)
    end
    
    # タブの整理
    def arrange_tabs
      tx = 0
      @tabs.each_value do |tab|
        tab.x = tx
        tx += tab.width - 4
      end
    end
    
    ### ■タブボタンクラスの定義■ ###
    class WSTabButton < WSControl
      
      ### Mix-In ###
      include ButtonClickable
      include Focusable
      
      ### 公開インデックス ###
      attr_accessor :panel
      
      # 初期化
      def initialize(sx, sy, width, height, caption="")
        tw = [@@default_font.get_width(caption) + 16, width].min
        super(sx, sy, tw, height)
        @px = sx
        @py = sy
        @max_width = width
        @caption = caption
        @fore_color = COLOR[:font]
        @image = {}
        @selection = false
        release_tab
        set_image
      end
      
      ### 参照関連
      # タブを選択する
      def select_tab
        @selection = true
        @panel.show if @panel
        self.z = 1
      end
      
      # タブを選択解除する
      def release_tab
        @selection = false
        @panel.hide if @panel
        self.z = 0
      end
      
      # タブが選択されているか？
      def selected?
        @selection
      end
      
      # タブにパネルを関連付ける
      def set_panel(panel)
        @panel = panel
      end
      
      ### 描画
      # タブ画像の作成
      def set_image
        w = @width
        h = @height
        # 通常時の画像を作成
        @image[false] = Image.new(w, h)
        .box_fill( 3, 3, w-4, h-2, COLOR[:base])
        .line( 4, 2, w-5, 2, COLOR[:light])
        .line( 3, 3, 3, 3, COLOR[:light])
        .line( 2, 4, 2, h-2, COLOR[:light])
        .line( w-4, 3, w-4, 3, COLOR[:darkshadow])
        .line( w-3, 4, w-3, h-2, COLOR[:darkshadow])
        .line( w-4, 4, w-4, h-2, COLOR[:shadow])
        
        # 押下時の画像を作成
        @image[true]  = Image.new(w, h)
        .box_fill( 1, 1, w-1, h-1, COLOR[:base])
        .line( 2, 0, w-3, 0, COLOR[:light])
        .line( 1, 1, 1, 1, COLOR[:light])
        .line( 0, 2, 0, h-1, COLOR[:light])
        .line( w-2, 1, w-2, 1, COLOR[:darkshadow])
        .line( w-1, 2, w-1, h-1, COLOR[:darkshadow])
        .line( w-2, 2, w-2, h-1, COLOR[:shadow])
        # 見出しの描画
        if @caption.length > 0
          width = @font.get_width(@caption)
          @image[false].draw_font_ex(@width / 2 - width / 2,
                                     @height / 2 - @font.size / 2,
                                     @caption, @font, {:color=>@fore_color, :aa =>false})
          
          @image[true].draw_font_ex(@width / 2 - width / 2,
                                    @height / 2 - @font.size / 2 - 1,
                                    @caption, @font, {:color=>@fore_color, :aa =>false})
          
        end
      end
      
      # 画像の作成
      def render
        self.image = @image[self.selected?]
        super
      end
    end
    
    
    
    ### ■タブパネルコンテナの定義■ ###
    class WSTabPanelContainer < WSScrollableContainer
      
      ### ■クライアント■ ###
      class WSTabPanelClient < WSContainer
        
        ### 公開インスタンス ###
        attr_accessor :panel
        
        # 初期化
        def initialize(sx, sy, width, height)
          super
        end
        
        # 画像の作成
        def render
          
          if @panel
            @panel.x = -@parent.hsb.pos
            @panel.y = -@parent.vsb.pos
          end
          
          super
          
        end
        
      end
      
      # 初期化
      def initialize(sx, sy, width, height)
        client = WSTabPanelClient.new(sx, sy, width, height)
        super(sx, sy, width, height, client)
        
        # スクロールバーを使うための設定。
        hsb.total_size = 1440
        hsb.view_size = client.width
        hsb.shift_qty = 24
        vsb.total_size = 960
        vsb.view_size = client.height
        vsb.shift_qty = 24
        
      end
      
      # パネルの登録
      def add_panel(panel, name)
        client.add_control(panel, name)
      end
      
      # パネルの選択
      def activate_panel(panel)
        client.panel = panel
        hsb.pos = -panel.x
        vsb.pos = -panel.y
        resize(@width, @height)
      end
      
      # リサイズ
      def resize(width, height)
        hsb.total_size = client.panel.width  if client.panel
        vsb.total_size = client.panel.height if client.panel
        super(width, height)
        hsb.view_size = client.width
        vsb.view_size = client.height
      end
      
      ### 描画
      # 枠の描画
      def draw_border(f)
        sx = self.x
        sy = self.y
        ex = sx + @width - 1
        ey = sy + @height - 1
        self.target.draw_line( sx+1 , ey-1, ex-1, ey-1, COLOR[:shadow])
        .draw_line( ex-1, sy+1, ex-1, ey-1, COLOR[:shadow])
        .draw_line( sx, sy, ex, sy, COLOR[:light])
        .draw_line( sx, sy, sx, ey, COLOR[:light])
        .draw_line( sx, ey, ex, ey, COLOR[:darkshadow])
        .draw_line( ex, sy+1, ex, ey, COLOR[:darkshadow])
      end
      
    end
    
  end
  
  
  
  
  ### ■タブパネルクラスの定義■ ###
  class WSTabPanel < WSLightContainer
    
    # 初期化
    def initialize(sx, sy, width, height)
      super(sx, sy, width, height)
      self.visible = false
    end
    
    # 更新
    def update
      super if self.visible
    end
    
    
  end
  
end
