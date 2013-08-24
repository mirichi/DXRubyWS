# coding: utf-8

# ウィンドウシステム
module WS
  # すべての基本、コントロールのクラス
  class WSControl < Sprite
    attr_accessor :parent, :font, :width, :height, :resizable_width, :resizable_height
    @@default_font = Font.new(16)

    def initialize(tx, ty, width, height)
      super(tx, ty)
      @width, @height = width, height
      self.collision = [0, 0, width - 1, height - 1]
      @signal = {}             # シグナルデータ
      @hit_cursor = Sprite.new # 衝突判定用スプライト
      @hit_cursor.collision = [0,0]
      @font ||= @@default_font
      @resizable_width = false  # オートレイアウト用設定
      @resizable_height = false # オートレイアウト用設定
    end

    # マウスイベント
    # ユーザはこれをオーバーライドして使う。
    # ありがちな処理なら自分で書かなくてもmodule.rbのモジュールをincludeすれば、
    # これらをオーバーライドして判定してシグナルを発行してくれるので、
    # シグナルを受けるだけでよくなる。

    # マウスの左ボタンを押したときに呼ばれる
    def on_mouse_down(tx, ty)
    end

    # マウスの左ボタンを離したときに呼ばれる
    def on_mouse_up(tx, ty)
    end

    # マウスの右ボタンを押したときに呼ばれる
    def on_mouse_r_down(tx, ty)
    end

    # マウスの右ボタンを離したときに呼ばれる
    def on_mouse_r_up(tx, ty)
    end

    # マウスカーソルを動かしたときに呼ばれる
    def on_mouse_move(tx, ty)
      return self
    end

    # コントロールにマウスカーソルが乗ったときに呼ばれる
    def on_mouse_over
    end

    # コントロールからマウスカーソルが離れたときに呼ばれる
    def on_mouse_out
    end

    # マウスイベント用の内部処理
    # WSContainerとの協調に必要。特殊なパターンでない限り、ユーザが意識する必要はない。

    # マウスの左ボタンを押したときに呼ばれる内部処理
    def on_mouse_down_internal(tx, ty)
      self.on_mouse_down(tx, ty)
      return self
    end

    # マウスの左ボタンを離したときに呼ばれる内部処理
    def on_mouse_up_internal(tx, ty)
      self.on_mouse_up(tx, ty)
      return self
    end

    # マウスの右ボタンを押したときに呼ばれる内部処理
    def on_mouse_r_down_internal(tx, ty)
      self.on_mouse_r_down(tx, ty)
      return self
    end

    # マウスの右ボタンを離したときに呼ばれる内部処理
    def on_mouse_r_up_internal(tx, ty)
      self.on_mouse_r_up(tx, ty)
      return self
    end

    # マウスカーソルを動かしたときに呼ばれる内部処理
    def on_mouse_move_internal(tx, ty)
      self.on_mouse_move(tx, ty)
    end

    # シグナル処理
    # add_handlerで登録しておいたMethodオブジェクトもしくはブロックを、signal実行時に呼び出す
    # 一応、1つのシグナルに複数のハンドラを設定することができるようになっている。はず。
    # callを呼ぶのでcallを持っていればそれが呼ばれる。

    # シグナルハンドラの登録
    def add_handler(signal, obj=nil, &block)
      if obj
        if @signal.has_key?(signal)
          @signal[signal] << obj
        else
          @signal[signal] = [obj]
        end
      end
      if block
        if @signal.has_key?(signal)
          @signal[signal] << block
        else
          @signal[signal] = [block]
        end
      end
    end

    # シグナルの発行(=ハンドラの呼び出し)
    def signal(s, *args)
      if @signal.has_key?(s)
        @signal[s].each do |obj|
          obj.call(self, *args)
        end
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
    end

    # コントロールのリサイズ
    def resize(width, height)
      @width, @height = width, height
      self.collision = [0, 0, width - 1, height - 1]
      signal(:resize)
    end
  end

  # 配下にコントロールを保持する機能を追加したコントロール
  # ウィンドウやリストボックスなど、自身の内部にコントロールを配置するものはWSContainerを使う。
  # マウスイベントやdraw/updateの伝播をしてくれる。
  # imageにRenderTargetを持ち、配下のオブジェクトのtargetはそれが設定される。
  # したがって、配下のオブジェクトの座標は親になるWSContainerの左上隅が0,0となる。
  class WSContainer < WSControl
    attr_accessor :childlen

    def initialize(tx, ty, width, height)
      super(tx, ty, width, height)
      self.image = RenderTarget.new(width, height) # ContainerはRenderTargetを持つ
      @childlen = []
      @layout = nil
    end

    # 自身の配下にコントロールを追加する
    # nameでシンボルを渡されるとその名前でgetterメソッドを追加する
    def add_control(obj, name=nil)
      obj.target = self.image # 子コントロールの描画先は親のRenderTargetである
      obj.parent = self
      @childlen << obj
      if name.class == Symbol
        tmp = class << self;self;end
        tmp.class_eval do
          define_method(name) do
            obj
          end
        end
      end
    end

    # コントロールの削除
    def remove_control(obj)
      @childlen.delete(obj)
    end

    # Sprite#update時に配下のコントロールにもupdateを投げる
    def update
      Sprite.update(@childlen)
      super
    end

    # Sprite#draw時に配下のコントロールにもupdateを投げる
    def draw
      Sprite.draw(@childlen)
      super
    end

    # 引数の座標に存在する配下のコントロールを返す。無ければnil
    def find_hit_object(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx, ty
      @hit_cursor.check(@childlen.reverse)[0]
    end

    # マウスの左ボタンが押されたイベントを配下のコントロールに伝播させる
    def on_mouse_down_internal(tx, ty)
      if !WS.captured?(self) 
        ctl = find_hit_object(tx, ty)
        return ctl.on_mouse_down_internal(tx - ctl.x, ty - ctl.y) if ctl
      end
      super
    end

    # マウスの左ボタンが離されたイベントを配下のコントロールに伝播させる
    def on_mouse_up_internal(tx, ty)
      if !WS.captured?(self) 
        ctl = find_hit_object(tx, ty)
        return ctl.on_mouse_up_internal(tx - ctl.x, ty - ctl.y) if ctl
      end
      super
    end

    # マウスの右ボタンが押されたイベントを配下のコントロールに伝播させる
    def on_mouse_r_down_internal(tx, ty)
      if !WS.captured?(self) 
        ctl = find_hit_object(tx, ty)
        return ctl.on_mouse_r_down_internal(tx - ctl.x, ty - ctl.y) if ctl
      end
      super
    end

    # マウスの右ボタンが離されたイベントを配下のコントロールに伝播させる
    def on_mouse_r_up_internal(tx, ty)
      if !WS.captured?(self) 
        ctl = find_hit_object(tx, ty)
        return ctl.on_mouse_r_up_internal(tx - ctl.x, ty - ctl.y) if ctl
      end
      super
    end

    # マウスカーソルが動いたイベントを配下のコントロールに伝播させる
    def on_mouse_move_internal(tx, ty)
      if !WS.captured?(self) 
        ctl = find_hit_object(tx, ty)
        return ctl.on_mouse_move_internal(tx - ctl.x, ty - ctl.y) if ctl
      end
      super
    end

    # オートレイアウト設定開始
    def layout(type=nil, &b)
      @layout = Layout.new(type, self, &b)
      @layout.auto_layout
    end

    # サイズの変更でRenderTargetをresizeし、オートレイアウトを起動する
    def resize(width, height)
      self.image.resize(width, height)
      super
      if @layout
        @layout.width, @layout.height = width, height
        @layout.auto_layout
      end
    end
  end

  # オートレイアウト
  class Layout
    attr_accessor :type, :x, :y, :width, :height, :resizable_width, :resizable_height, :obj
    attr_accessor :margin_left, :margin_right, :margin_top, :margin_bottom

    def initialize(type, obj, &b)
      @type, @obj = type, obj
      @width, @height = obj.width, obj.height
      @x = @y = 0
      @margin_left = @margin_right = @margin_top = @margin_bottom = 0
      @resizable_width = @resizable_height = true
      @data = []
      self.instance_eval &b if b
    end

    def layout(type=nil, &b)
      @data << Layout.new(type, self, &b)
      self
    end
    
    def add(o, rsw=nil, rsh=nil)
      @data << o
      o.resizable_width = rsw if rsw != nil
      o.resizable_height = rsh if rsh != nil
    end

    def adjust_x
      @data.each do |o|
        @new_x, @new_y = o.x, o.y
        @new_width, @new_height = o.width, o.height

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
        undef_size_count = @data.count {|o| o.resizable_width }

        # サイズ確定オブジェクトのサイズ合計
        total = @data.inject(0) {|t, o| t += (o.resizable_width ? 0 : o.width)}

        # 座標開始位置
        point = self.x + @margin_left

        case undef_size_count
        when 0 # 均等
          # 座標調整
          adjust_x do |o|
            point += (self.width - @margin_left - @margin_right - total) / (@data.size + 1) # オブジェクトの間隔を足す
            @new_x = point
            point += @new_width
          end

        else # 最大化するものを含む
          # 座標調整
          adjust_x do |o|
            @new_x = point
            @new_width = (self.width - @margin_left - @margin_right - total) / undef_size_count if o.resizable_width # 最大化するオブジェクトを最大化
            point += @new_width
          end
        end

      when :vbox # 垂直に並べる
        # サイズ未定のものをカウント
        undef_size_count = @data.count {|o| o.resizable_height }

        # サイズ確定オブジェクトのサイズ合計
        total = @data.inject(0) {|t, o| t += (o.resizable_height ? 0 : o.height)}

        # 座標開始位置
        point = self.y + @margin_top

        case undef_size_count
        when 0 # 均等
          # 座標調整
          adjust_y do |o|
            point += (self.height - @margin_top - @margin_bottom - total) / (@data.size + 1) # オブジェクトの間隔を足す
            @new_y = point
            point += @new_height
          end

        else # 最大化するものを含む
          # 座標調整
          adjust_y do |o|
            @new_y = point
            @new_height = (self.height - @margin_top - @margin_bottom - total) / undef_size_count if o.resizable_height # 最大化するオブジェクトを最大化
            point += @new_height
          end
        end
      end

      @data.each do |o|
        o.auto_layout if Layout === o
      end
    end

    def move(tx, ty)
      @x, @y = tx, ty
    end

    def resize(width, height)
      @width, @height = width, height
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
