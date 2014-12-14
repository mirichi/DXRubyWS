# coding: utf-8

# ウィンドウシステム
module WS
  K_CTRL = 256
  
  # すべての基本、コントロールのクラス
  class WSControl < Sprite
    
    attr_accessor :parent, :font, :width, :height, :resizable_width, :resizable_height
    attr_accessor :focusable, :active, :enabled
    attr_reader :min_width, :min_height
    # デフォルトフォントオブジェクト
    @@default_font = Font.new(16)
    
    def initialize(tx=nil, ty=nil, width=nil, height=nil)
      super(tx, ty)
      @width = width
      @height = height
      @min_width, @min_height = 16, 16
      self.collision = [0, 0, width - 1, height - 1] if width and height
      @signal_handler = {}   # シグナルハンドラ
      @key_handler = {}      # キーハンドラ
      @hit_cursor = Sprite.new # 衝突判定用スプライト
      @hit_cursor.collision = [0,0]
      @font ||= @@default_font
      @resizable_width = !width  # オートレイアウト用設定
      @resizable_height = !height # オートレイアウト用設定
      @focusable = false
      @active = false
      @mouse_over = false
      @enabled = true
    end
    
    # マウスイベント
    # ユーザはこれをオーバーライドして使う。
    # ありがちな処理なら自分で書かなくてもmodule.rbのモジュールをincludeすれば、
    # これらをオーバーライドして判定してシグナルを発行してくれるので、
    # シグナルを受けるだけでよくなる。
    
    # マウスの左ボタンを押したときに呼ばれる
    def on_mouse_push(tx, ty)
      signal(:mouse_push, tx, ty)
      self
    end
    
    # マウスの左ボタンを離したときに呼ばれる
    def on_mouse_release(tx, ty)
      signal(:mouse_release, tx, ty)
      self
    end
    
    # マウスの中ボタンを押したときに呼ばれる
    def on_mouse_m_push(tx, ty)
      signal(:mouse_m_push, tx, ty)
      self
    end
    
    # マウスの中ボタンを離したときに呼ばれる
    def on_mouse_m_release(tx, ty)
      signal(:mouse_m_release, tx, ty)
      self
    end
    
    # マウスの右ボタンを押したときに呼ばれる
    def on_mouse_r_push(tx, ty)
      signal(:mouse_r_push, tx, ty)
      self
    end
    
    # マウスの右ボタンを離したときに呼ばれる
    def on_mouse_r_release(tx, ty)
      signal(:mouse_r_release, tx, ty)
      self
    end
    
    # マウスカーソルを動かしたときに呼ばれる
    def on_mouse_move(tx, ty)
      signal(:mouse_move, tx, ty)
      self
    end
    
    # コントロールにマウスカーソルが乗ったときに呼ばれる
    def on_mouse_over
      signal(:mouse_over)
      @mouse_over = true
      self
    end
    
    # コントロールからマウスカーソルが離れたときに呼ばれる
    def on_mouse_out
      signal(:mouse_out)
      @mouse_over = false
      self
    end
    
    # マウスのホイールアップ
    def on_mouse_wheel_up(tx, ty)
      signal(:mouse_wheel_up)
      self
    end
    
    # マウスのホイールダウン
    def on_mouse_wheel_down(tx, ty)
      signal(:mouse_wheel_down)
      self
    end
    
    # マウスイベント用の内部処理
    # WSContainerとの協調に必要。特殊なパターンでない限り、ユーザが意識する必要はない。
    def mouse_event_dispatch(event, tx, ty)
      self.__send__(("on_" + event.to_s).to_sym, tx, ty)
    end
    
    # シグナル処理
    # add_handlerで登録しておいたMethodオブジェクトもしくはブロックを、signal実行時に呼び出す
    # 一応、1つのシグナルに複数のハンドラを設定することができるようになっている。はず。
    # callを呼ぶのでcallを持っていればそれが呼ばれる。
    
    # シグナルハンドラの登録
    def add_handler(signal, obj=nil, &block)
      if obj
        if @signal_handler.has_key?(signal)
          @signal_handler[signal] << obj
        else
          @signal_handler[signal] = [obj]
        end
      end
      if block
        if @signal_handler.has_key?(signal)
          @signal_handler[signal] << block
        else
          @signal_handler[signal] = [block]
        end
      end
      nil
    end
    
    # シグナルの発行(=ハンドラの呼び出し)
    # ハンドラを呼んだらtrue、何もなければfalseを返す。
    def signal(s, *args)
      if @signal_handler.has_key?(s)
        @signal_handler[s].each do |obj|
          obj.call(self, *args)
        end
        true
      else
        false
      end
    end
    
    # 絶対座標の算出
    def get_global_vertex
      return [self.x, self.y] unless self.parent
      tx, ty = self.parent.get_global_vertex
      [self.x + tx, self.y + ty]
    end
    
    # コントロールの移動/リサイズをするときはmove/resizeを呼ぶ。
    # 自分でコントロールのクラスを実装した場合、move/resize時になにか処理が必要なら実装すること。
    # :move/:resizeシグナルは外部の処理でこのコントロールのmove/resize後に何かをしたい場合に使う。
    # たとえばWSImageを派生クラスを作らず直接newした場合、画像データは外部から設定することになるが、
    # resize時に画像の再生成が必要になる。そういうときにこのイベントを捕まえて新しいサイズの画像を生成、設定する。
    # :moveシグナルは使い道ないかもしれん。
    
    # コントロールの移動
    def move(tx, ty)
      self.x, self.y = tx, ty
      signal(:move, tx, ty)
      nil
    end
    
    # コントロールのリサイズ
    def resize(width, height)
      @width = [width, @min_width].max
      @height = [height, @min_height].max
      self.collision = [0, 0, @width - 1, @height - 1]
      signal(:resize)
      nil
    end
    
    # コントロールの最小幅の設定
    def min_width=(v)
      @min_width = v
      @width = [@width, v].max if @width
    end
    
    # コントロールの最小高さの設定
    def min_height=(v)
      @min_height = v
      @height = [@height, v].max if @height
    end
    
    # キー押したイベント。引数はDXRubyのキー定数。
    # ハンドラを呼んだらtrue、何もなければfalseを返す。
    def on_key_push(key)
      return false unless self.enabled?
      result = false
      key += 256 if Input.key_down?(K_LCONTROL) or Input.key_down?(K_RCONTROL)
      if @key_handler.has_key?(key)
        @key_handler[key].each do |obj|
          obj.call(self)
        end
        result ||= true
      end
      
      result
    end
    
    # キー離したイベント。引数はDXRubyのキー定数。
    def on_key_release(key)
    end
    
    # キーハンドラ登録
    def add_key_handler(key, obj=nil, &block)
      if obj
        if @key_handler.has_key?(key)
          @key_handler[key] << obj
        else
          @key_handler[key] = [obj]
        end
      end
      if block
        if @key_handler.has_key?(key)
          @key_handler[key] << block
        else
          @key_handler[key] = [block]
        end
      end
      nil
    end
    
    # 文字列入力イベント
    def on_string(str)
    end
    
    # フォーカスが当てられたときに呼ばれる
    def on_enter
      @active = true
      signal(:enter)
    end
    
    # フォーカスを失ったときに呼ばれる
    def on_leave
      @active = false
      signal(:leave)
    end
    
    # コントロールをアクティブにする
    def activate
      self.parent.set_focus(self) if self.focusable
      self
    end
    
    # アクティブかどうかを返す
    def activated?
      @active
    end
    
    # 有効かどうかを返す
    def enabled?
      @enabled && self.visible && (self.parent ? self.parent.enabled? : true)
    end
    
    # 見えるかどうかを返す
    def visible?
      self.visible && (self.parent ? self.parent.visible? : true)
    end
    
    # コントロールの状態を判定しシンボルを返す
    # 特殊な状態は継承先で個別に定義する
    # :usual            通常状態
    # :disable          使用不可状態
    # :active           フォーカスを得ている
    def state
      if !@enabled
        :disable
      elsif @active
        :active
      else
        :usual
      end
    end
    
    # コントロールを読める文字にする
    def inspect
      "#<" + self.class.name + ">"
    end
    
    # フォーカスを受け取れるコントロールを配列にして返す
    def get_focusable_control_ary
      if @focusable and self.visible and self.enabled?
        [self]
      else
        []
      end
    end
    
    # フォーカスを受け取れるコントロールを返す
    def get_focusable_control(tx, ty)
      if @focusable and self.visible and self.enabled?
        self
      else
        nil
      end
    end
    
    # リフレッシュ
    def refresh
      @refresh = true
    end
    
    # リフレッシュするか？
    def refresh?
      @refresh
    end
    
    # リフレッシュの終了
    def refreshed
      @refresh = false
    end
    
    # drawで描画するためのself.imageを準備する
    def render
    end
    
  end
  
  
  
  
  # 配下にコントロールを保持する機能を追加したコントロール
  # ウィンドウやリストボックスなど、自身の内部にコントロールを配置するものはWSContainerを使う。
  # マウスイベントやdraw/updateの伝播をしてくれる。
  class WSContainerBase < WSControl
    attr_accessor :childlen
    
    def initialize(tx=nil, ty=nil, width=nil, height=nil)
      super
      @childlen = []
      @layout = nil
    end
    
    # 自身の配下にコントロールを追加する
    # nameでシンボルを渡されるとその名前でgetterメソッドを追加する
    # _add_controlは書き換えないようにする
    def _add_control(obj, name=nil)
      obj.parent = self
      
      @childlen << obj
      if name
        tmp = class << self;self;end
        tmp.class_eval do
          define_method(name) do
            obj
          end
        end
      end
      obj
    end
    
    # コントロール追加に変更を加えたい場合はこちらを書き換える
    def add_control(obj, name=nil)
      _add_control(obj, name)
    end
    
    # コントロールの削除
    # _remove_controlは書き換えないようにする
    def _remove_control(obj, name=nil)
      @childlen.delete(obj)
      if name
        tmp = class << self;self;end
        tmp.class_eval do
          remove_method(name)
        end
      end
      obj
    end
    
    # コントロールの削除に変更を加えたい場合はこちらを書き換える
    def remove_control(obj, name=nil)
      _remove_control(obj, name)
    end
    
    
    # Sprite#update時に配下のコントロールにもupdateを投げる
    def update
      Sprite.update(@childlen)
      super
    end
    
    # 引数の座標に存在する配下のコントロールを返す。無ければnil
    def find_hit_object(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx, ty
      @hit_cursor.check(@childlen.reverse)[0]
    end
    
    def mouse_event_dispatch(event, tx, ty)
      if !WS.captured?(self) or WS.capture_notify # キャプチャしたのが自コンテナだった場合は配下コントロールにイベントを渡さない
        ctl = find_hit_object(tx, ty)
        return ctl.mouse_event_dispatch(event, tx - ctl.x, ty - ctl.y) if ctl and ctl.enabled?
      end
      super
    end
    
    # オートレイアウト設定開始
    def layout(type=nil, &b)
      @layout = WSLayout.new(type, self, self, &b)
      @layout.auto_layout if self.width and self.height
    end
    
    # サイズの変更でRenderTargetをresizeし、オートレイアウトを起動する
    def resize(width, height)
      super
      if @layout
        @layout.width, @layout.height = width, height
        @layout.auto_layout
      end
    end
    
    # フォーカスを受け取れるコントロールを配列にして返す
    def get_focusable_control_ary
      ary = []
      @childlen.each do |o|
        if o.focusable and o.visible and o.enabled?
          ary.push(o)
        else
          ary.concat(o.get_focusable_control_ary)
        end
      end
      ary
    end
    
    # 座標の位置にあってフォーカスを受け取れるコントロールを返す
    def get_focusable_control(tx, ty)
      ctl = find_hit_object(tx, ty)
      return nil unless ctl
      return ctl if ctl.focusable and ctl.visible and ctl.enabled?
      return ctl.get_focusable_control(tx - ctl.x, ty - ctl.y)
    end
    
    # コントロールにフォーカスを設定する
    def set_focus(obj)
      self.parent.set_focus(obj) if self.parent
      obj
    end
  end
  
  class WSLightContainer < WSContainerBase
    def target=(v)
      @childlen.each do |s|
        s.target = v
      end
      super
    end
    
    # 自身の配下にコントロールを追加する
    # nameでシンボルを渡されるとその名前でgetterメソッドを追加する
    def add_control(obj, name=nil)
      obj.target = self.target # 子コントロールの描画先は親の親
      super
    end
    
    def render
      @childlen.each do |s|
        s.render if s.visible
      end
    end
    
    def draw
      self.target.ox -= self.x
      self.target.oy -= self.y
      
      @childlen.each do |s|
        if s.visible
          s.draw
        end
      end
      
      self.target.ox += self.x
      self.target.oy += self.y
    end
    
    # 自身のtargetに枠を描画する
    def draw_border(flag)
      sx = @width
      sy = @height
      basex = self.x
      basey = self.y
      if flag
        self.target.draw_line(basex,basey,basex+sx-1,basey,COLOR[:highlight])
        self.target.draw_line(basex,basey,basex,basey+sy-1,COLOR[:highlight])
        self.target.draw_line(basex+1,basey+1,basex+sx-1,basey+1,COLOR[:light])
        self.target.draw_line(basex+1,basey+1,basex+1,basey+sy-1,COLOR[:light])
        self.target.draw_line(basex+sx-1,basey,basex+sx-1,basey+sy-1,COLOR[:darkshadow])
        self.target.draw_line(basex,basey+sy-1,basex+sx-1,basey+sy-1,COLOR[:darkshadow])
        self.target.draw_line(basex+sx-2,basey+1,basex+sx-2,basey+sy-2,COLOR[:shadow])
        self.target.draw_line(basex+1,basey+sy-2,basex+sx-2,basey+sy-2,COLOR[:shadow])
      else
        self.target.draw_line(basex,basey,basex+sx-1,basey,COLOR[:darkshadow])
        self.target.draw_line(basex,basey,basex,basey+sy-1,COLOR[:darkshadow])
        self.target.draw_line(basex+1,basey+1,basex+sx-1,basey+1,COLOR[:shadow])
        self.target.draw_line(basex+1,basey+1,basex+1,basey+sy-1,COLOR[:shadow])
        self.target.draw_line(basex+sx-1,basey,basex+sx-1,basey+sy-1,COLOR[:highlight])
        self.target.draw_line(basex,basey+sy-1,basex+sx-1,basey+sy-1,COLOR[:highlight])
        self.target.draw_line(basex+sx-2,basey+1,basex+sx-2,basey+sy-2,COLOR[:light])
        self.target.draw_line(basex+1,basey+sy-2,basex+sx-2,basey+sy-2,COLOR[:light])
      end
    end
  end
  
  # self.imageにRenderTargetを持つコンテナ。
  # 配下のオブジェクトのtargetはそれが設定される。
  # したがって、配下のオブジェクトの座標は親になるWSContainerの左上隅が0,0となる。
  class WSContainer < WSContainerBase
    attr_accessor :childlen
    
    def initialize(tx=nil, ty=nil, width=nil, height=nil)
      super
      width ||= 16 # サイズ省略時は適当なサイズにしておく
      height ||=16
      self.image = RenderTarget.new(width, height) # ContainerはRenderTargetを持つ
    end
    
    # 自身の配下にコントロールを追加する
    # nameでシンボルを渡されるとその名前でgetterメソッドを追加する
    def add_control(obj, name=nil)
      obj.target = self.image # 子コントロールの描画先は親のRenderTargetである
      super
    end
    
    # 配下のオブジェクトをすべて自身に描画する
    # self.imageに描画する処理はすべてrenderをオーバーライドして書くこと。
    # self.targetに対する描画はdrawをオーバーライドして書くこと。
    # renderをsuperするタイミングによって描画順が変わる。先にsuperすると自分の描画が上になるるし、
    # 後でsuperすると配下のオブジェクトによって上書きされる。
    def render
      @childlen.each do |s|
        if s.visible
          s.render
          s.draw
        end
      end
    end
    
    # サイズの変更でRenderTargetをresizeし、オートレイアウトを起動する
    def resize(width, height)
      self.image.resize(width, height) if width != @width or height != @height
      super
    end
    
    # 自身のimgaeに枠を描画する
    def render_border(flag)
      sx = @width
      sy = @height
      if flag
        self.image.draw_line(0,0,sx-1,0,COLOR[:highlight])
        self.image.draw_line(0,0,0,sy-1,COLOR[:highlight])
        self.image.draw_line(1,1,sx-1,1,COLOR[:light])
        self.image.draw_line(1,1,1,sy-1,COLOR[:light])
        self.image.draw_line(sx-1,0,sx-1,sy-1,COLOR[:darkshadow])
        self.image.draw_line(0,sy-1,sx-1,sy-1,COLOR[:darkshadow])
        self.image.draw_line(sx-2,1,sx-2,sy-2,COLOR[:shadow])
        self.image.draw_line(1,sy-2,sx-2,sy-2,COLOR[:shadow])
      else
        self.image.draw_line(0,0,sx-1,0,COLOR[:darkshadow])
        self.image.draw_line(0,0,0,sy-1,COLOR[:darkshadow])
        self.image.draw_line(1,1,sx-1,1,COLOR[:shadow])
        self.image.draw_line(1,1,1,sy-1,COLOR[:shadow])
        self.image.draw_line(sx-1,0,sx-1,sy-1,COLOR[:highlight])
        self.image.draw_line(0,sy-1,sx-1,sy-1,COLOR[:highlight])
        self.image.draw_line(sx-2,1,sx-2,sy-2,COLOR[:light])
        self.image.draw_line(1,sy-2,sx-2,sy-2,COLOR[:light])
      end
    end
  end
  
  # オートレイアウト
  class WSLayout
    attr_accessor :type, :x, :y, :width, :height, :resizable_width, :resizable_height, :obj, :parent
    attr_accessor :margin_left, :margin_right, :margin_top, :margin_bottom
    attr_accessor :min_width, :min_height, :space
    
    def initialize(type, obj, parent, &b)
      @type, @obj = type, obj
      @width, @height = parent.width, parent.height
      @min_width = @min_height = 0
      @x = @y = 0
      @space = 0
      @margin_left = @margin_right = @margin_top = @margin_bottom = 0
      @resizable_width = @resizable_height = true
      @data = []
      self.instance_eval &b if b
    end
    
    def set_margin(top, bottom, left, right)
      @margin_top, @margin_bottom, @margin_left, @margin_right = top, bottom, left, right
    end
    
    def layout(type=nil, &b)
      @data << WSLayout.new(type, @obj, self, &b)
      self
    end
    
    def add(o, rsw=nil, rsh=nil)
      @data << o
      o.resizable_width = rsw if rsw != nil
      o.resizable_height = rsh if rsh != nil
      
      case @type
      when :hbox
        @min_width += (o.resizable_width ? o.min_width : o.width)
        @min_height = [@min_height, (o.resizable_height ? o.min_height : o.height)].max
      when :vbox
        @min_height += (o.resizable_height ? o.min_height : o.height)
        @min_width = [@min_width, (o.resizable_width ? o.min_width : o.width)].max
      end
    end
    
    def adjust_x
      @data.each do |o|
        @new_x, @new_y = o.x, o.y
        @new_width, @new_height = o.width, o.height
        @new_min_width, @new_min_height = o.min_width, o.min_height
        
        yield o
        
        # 直交位置サイズ調整
        if o.resizable_height
          # いっぱいに広げる
          @new_y = self.y + @margin_top
          @new_height = self.height - @margin_top - @margin_bottom
        else
          # 真ん中にする
          @new_y = (self.height - @margin_top - @margin_bottom) / 2 - @new_height / 2 + self.y + @margin_top
        end
        
        # 変わってたらmoveを呼び出す
        if @new_x != o.x or @new_y != o.y
          o.move(@new_x, @new_y)
        end
        
        # 変わってたらresizeを呼び出す
        if @new_width != o.width or @new_height != o.height
          o.resize(@new_width, @new_height)
        end
      end
    end
    
    def adjust_y
      @data.each do |o|
        @new_x, @new_y = o.x, o.y
        @new_width, @new_height = o.width, o.height
        @new_min_width, @new_min_height = o.min_width, o.min_height
        
        yield o
        
        # 直交位置サイズ調整
        if o.resizable_width
          # いっぱいに広げる
          @new_x = self.x + @margin_left
          @new_width = self.width - @margin_left - @margin_right
        else
          # 真ん中にする
          @new_x = (self.width - @margin_left - @margin_right) / 2 - @new_width / 2 + self.x + @margin_left
        end
        
        # 変わってたらmoveを呼び出す
        if @new_x != o.x or @new_y != o.y
          o.move(@new_x, @new_y)
        end
        
        # 変わってたらresizeを呼び出す
        if @new_width != o.width or @new_height != o.height
          o.resize(@new_width, @new_height)
        end
      end
    end
    
    def auto_layout
      case @type
      when :hbox # 水平に並べる
        # サイズ未定のものをカウント
        undef_size_count = @data.count{|o| o.resizable_width}
        
        # サイズ確定オブジェクトのサイズ合計
        total = @data.inject(0){|t, o| t += (o.resizable_width ? 0 : o.width + self.space)}
        
        # サイズが確定されていないオブジェクトの配列作成
        undef_size_ctl = @data.select{|o| o.resizable_width}.sort_by{|o|o.min_width}.reverse
        
        width = 0
        rest = (self.width - @margin_left - @margin_right - total).to_f
        count = undef_size_ctl.size
        
        # サイズの大きいほうから残りのすべてをmin_widthにできるかどうかを確認する
        undef_size_ctl.each do |o|
          if rest < (count * o.min_width) # 入りきらない
            rest -= o.min_width # このぶんは確定とする
            count -= 1
          else
            width = (rest - self.space * (count -1)) / count
            break
          end
        end
        
        # 座標開始位置
        point = self.x + @margin_left
        
        case undef_size_count
        when 0 # 均等
          # 座標調整
          adjust_x do |o|
            tmp = (self.width - @margin_left - @margin_right - total - self.space) / (@data.size + 1) # オブジェクトの間隔を足す
            point += (tmp > 0 ? tmp  + self.space: 0)
            @new_x = point
            point += @new_width
          end
          
        else # 最大化するものを含む
          # 座標調整
          adjust_x do |o|
            @new_x = point
            if o.resizable_width # 最大化するオブジェクトを最大化
              @new_width = (width < @new_min_width ? @new_min_width : width)
            end
            point += @new_width + self.space
          end
        end
        
      when :vbox # 垂直に並べる
        # サイズ未定のものをカウント
        undef_size_count = @data.count{|o| o.resizable_height}
        
        # サイズ確定オブジェクトのサイズ合計
        total = @data.inject(0){|t, o| t += (o.resizable_height ? 0 : o.height + self.space)}
        
        # サイズが確定されていないオブジェクトの配列作成
        undef_size_ctl = @data.select{|o| o.resizable_height}.sort_by{|o|o.min_height}.reverse
        
        height = 0
        rest = (self.height - @margin_top - @margin_bottom - total).to_f
        count = undef_size_ctl.size
        
        # サイズの大きいほうから残りのすべてをmin_heightにできるかどうかを確認する
        undef_size_ctl.each do |o|
          if rest < (count * o.min_height) # 入りきらない
            rest -= o.min_height # このぶんは確定とする
            count -= 1
          else
            height = (rest - self.space * (count - 1)) / count
            break
          end
        end
        
        # 座標開始位置
        point = self.y + @margin_top
        
        case undef_size_count
        when 0 # 均等
          # 座標調整
          adjust_y do |o|
            tmp = (self.height - @margin_top - @margin_bottom - total - self.space) / (@data.size + 1) # オブジェクトの間隔を足す
            point += (tmp > 0 ? tmp + self.space : 0)
            @new_y = point
            point += @new_height
          end
          
        else # 最大化するものを含む
          # 座標調整
          adjust_y do |o|
            @new_y = point
            if o.resizable_height # 最大化するオブジェクトを最大化
              @new_height = (height < @new_min_height ? @new_min_height : height)
            end
            point += @new_height + self.space
          end
        end
      end
      
      @data.each do |o|
        o.auto_layout if WSLayout === o
      end
    end
    
    def move(tx, ty)
      @x, @y = tx, ty
    end
    
    def resize(width, height)
      @width, @height = width, height
    end
    
    def inspect
      "#<" + self.class.name + ">"
    end
  end
end

class Numeric
  def clamp(min, max)
    if self < min
      min
    elsif self > max
      max
    else
      self
    end
  end
end

module Input
  def self.shift?
    Input.key_down?(K_LSHIFT) or Input.key_down?(K_RSHIFT)
  end
end
