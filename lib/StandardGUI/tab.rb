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
  class WSTab < WSContainer
          
    # 初期化
    def initialize(sx, sy, width, height, tab_height = 24)
      super(sx, sy, width, height)
      @tab_height = tab_height
      @tabs  = {}
      @panel = {}
    end
    
    # タブと標準パネルの作成
    def create_tab_set(name, caption = "")
      # パネルの作成
      panel = WSTabPanel.new(0, panel_y, @width, panel_height)
      create_tab(panel, name, caption)
    end
    
    # タブの作成
    def create_tab(panel, name, caption = "")
      # パネル位置とサイズの修正
      panel.y = panel_y
      panel.resize(@width, panel_height)
      # パネルの登録
      self.add_control(panel, name)
      @panel[name] = panel
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
      @panel[name]
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
    end 
    
    # タブの整理
    def arrange_tabs
      tx = 0
      @tabs.each_value do |tab|
        tab.x = tx
        tx += tab.width - 4
      end
    end
    
    ### ■タブクラスの定義■ ###
    class WSTabButton < WSControl
            
      ### Mix-In ###
      include ButtonClickable
      include Focusable
      
      ### 公開インデックス ###
      attr_accessor :index
      
      # 初期化
      def initialize(sx, sy, width, height, caption="")
        tw = [@@default_font.get_width(caption) + 16, width].min
        super(sx, sy, tw, height)
        @index = 0
        @px = sx
        @py = sy
        @max_width = width
        @caption = caption
        @fore_color = C_BLACK
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
        self.z = 0
      end
    
      # タブを選択解除する
      def release_tab
        @selection = false
        @panel.hide if @panel
        self.z = -1
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
        @image[false] = Image.new(w, h)
                             .box_fill( 3, 3, w-4, h-2, C_GRAY)
                             .line( 4, 2, w-5, 2, C_LIGHT_GRAY)
                             .line( 3, 3, 3, 3, C_LIGHT_GRAY)
                             .line( 2, 4, 2, h-2, C_LIGHT_GRAY)
                             .line( w-4, 3, w-4, 3, C_LIGHT_BLACK)
                             .line( w-3, 4, w-3, h-2, C_LIGHT_BLACK)
                             .line( w-4, 4, w-4, h-2, C_DARK_GRAY)                             
                 
        
        @image[true]  = Image.new(w, h)
                             .box_fill( 1, 1, w-1, h-1, C_GRAY)
                             .line( 2, 0, w-3, 0, C_LIGHT_GRAY)
                             .line( 1, 1, 1, 1, C_LIGHT_GRAY)
                             .line( 0, 2, 0, h-1, C_LIGHT_GRAY)
                             .line( w-2, 1, w-2, 1, C_LIGHT_BLACK)
                             .line( w-1, 2, w-1, h-1, C_LIGHT_BLACK)
                             .line( w-2, 2, w-2, h-1, C_DARK_GRAY) 
      end
      
      # 描画
      def draw
        self.image = @image[self.selected?]
        super
        # 見出しの描画
        if @caption.length > 0
          width = @font.get_width(@caption)
          self.target.draw_font(self.image.width / 2 - width / 2 + self.x,
                                self.image.height / 2 - @font.size / 2 + self.y,
                                @caption, @font, :color=>@fore_color)
        end
      end
    end
  end

  
  
  
  ### ■タブパネルクラスの定義■ ###
  class WSTabPanel < WSContainer
          
    # 初期化
    def initialize(sx, sy, width, height)
      super(sx, sy, width, height)
      self.visible = false
    end      
    
    # 更新
    def update
      super if self.visible
    end
    
    # 描画
    def draw
      if self.visible
        # ボーダーの描画
        self.image.draw_line( 1, @height-2, @width-2, @height-2, C_DARK_GRAY)
                  .draw_line( @width-2, 1, @width-2, @height-2, C_DARK_GRAY)
                  .draw_line( 0, 0, @width-1, 0, C_LIGHT_GRAY)
                  .draw_line( 0, 0, 0, @height-1, C_LIGHT_GRAY)
                  .draw_line( 0, @height-1, @width-1, @height-1, C_LIGHT_BLACK)
                  .draw_line( @width-1, 1, @width-1, @height-1, C_LIGHT_BLACK)
        super
      end
    end
    
  end

end
