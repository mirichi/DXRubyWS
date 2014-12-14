# coding: utf-8

module WS
  class WSLabel < WSControl
    
    # 公開インスタンス
    attr_reader :caption, :fore_color
    
    # 初期化
    def initialize(tx=nil, ty=nil, width=nil, height=nil, caption = "")
      super(tx, ty, width, height)
      self.image = Image.new(width, height) if width and height
      self.collision_enable = false
      self.caption = caption
      @fore_color = COLOR[:font]
    end
    
    # キャプションの設定
    def caption=(text)
      @caption = text
      refresh
    end
    
    # 文字色の設定
    def fore_color=(color)
      @fore_color = color
      refresh
    end
    
    # resize時の処理
    def resize(width, height)
      super
      self.image.dispose if self.image
      self.image = Image.new(width, height)
      refresh
    end
    
    # 画像の作成
    def render
      if refresh?
        width = @font.get_width(@caption)
        self.image.clear
        self.image.draw_font_ex(0, @height / 2 - @font.size / 2 - 1,
                                @caption, @font, {:color=>@fore_color, :aa=>false})
        refreshed
      end
    end
  end
end
