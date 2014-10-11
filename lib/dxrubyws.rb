# coding: utf-8
require 'dxruby'
require_relative './core'
require_relative './module'
require_relative './fontcache'

# ウィンドウシステム
module WS
  class WSDesktop < WSLightContainer
    attr_accessor :capture_object, :system_focus, :capture_notify, :capture_target, :capture_target_notify

    def initialize
      @childlen = []
      @signal_handler = {}
      @key_handler = {}
      @hit_cursor = Sprite.new
      @hit_cursor.collision = [0,0]
      @font = @@default_font
      @mouse_l_flag = false
      @mouse_m_flag = false
      @mouse_r_flag = false
      @capture_object = nil
      @system_focus = nil
      @over_object = nil
      @cursor_x, @cursor_y = Input.mouse_pos_x, Input.mouse_pos_y
      @mouse_wheel = Input.mouse_wheel_pos
      @old_keys = nil
      self.collision = [0, 0, Window.width-1, Window.height-1]
      @width = Window.width
      @height = Window.height
      @enabled = true
      self.target = Window
    end

    def add_control(obj, name=nil)
      super
      obj.z = WS.default_z
      obj.target = Window
      obj.activate
    end

    def update
      # キーイベント
      push_keys = Input::IME.push_keys
      release_keys = Input::IME.release_keys

      sys_focus = @system_focus || self
      push_keys.each do |key|
        sys_focus.on_key_push(key)
      end
      release_keys.each do |key|
        sys_focus.on_key_release(key)
      end

      # 文字列イベント
      str = Input::IME.get_string.encode("UTF-8")
      if str.length > 0
        sys_focus.on_string(str)
      end

      oldx, oldy = @cursor_x, @cursor_y
      @cursor_x, @cursor_y = Input.mouse_pos_x, Input.mouse_pos_y
      @cursor_x = (@cursor_x / Window.scale).to_i #Window.scale対策
      @cursor_y = (@cursor_y / Window.scale).to_i

      # キャプチャされてた場合にはそのコントロールに直接イベントを送る
      # そうじゃない場合はデスクトップから辿って検索する
      # ための下準備
      if @capture_object
        tx, ty = @capture_object.get_global_vertex
        tx, ty = @cursor_x - tx, @cursor_y - ty
        tmp = @capture_object
      else
        tx, ty = @cursor_x, @cursor_y
        tmp = self
      end

      # ボタン押した
      if Input.mouse_down?(M_LBUTTON) and @mouse_l_flag == false
        @mouse_l_flag = true
        tmp.mouse_event_dispatch(:mouse_push, tx, ty)
      end
  
      # ボタン離した
      if !Input.mouse_down?(M_LBUTTON) and @mouse_l_flag == true
        @mouse_l_flag = false
        tmp.mouse_event_dispatch(:mouse_release, tx, ty)
      end

      # 中ボタン押した
      if Input.mouse_down?(M_MBUTTON) and @mouse_m_flag == false
        @mouse_m_flag = true
        tmp.mouse_event_dispatch(:mouse_m_push, tx, ty)
      end
  
      # 中ボタン離した
      if !Input.mouse_down?(M_MBUTTON) and @mouse_m_flag == true
        @mouse_m_flag = false
        tmp.mouse_event_dispatch(:mouse_m_release, tx, ty)
      end

      # 右ボタン押した
      if Input.mouse_down?(M_RBUTTON) and @mouse_r_flag == false
        @mouse_r_flag = true
        tmp.mouse_event_dispatch(:mouse_r_push, tx, ty)
      end
  
      # 右ボタン離した
      if !Input.mouse_down?(M_RBUTTON) and @mouse_r_flag == true
        @mouse_r_flag = false
        tmp.mouse_event_dispatch(:mouse_r_release, tx, ty)
      end

      # マウスホイール処理
      wpos = Input.mouse_wheel_pos
      if wpos > @mouse_wheel
        tmp.mouse_event_dispatch(:mouse_wheel_up, tx, ty)
      elsif wpos < @mouse_wheel
        tmp.mouse_event_dispatch(:mouse_wheel_down, tx, ty)
      end
      @mouse_wheel = wpos

      # マウスカーソルの移動処理
      if oldx != @cursor_x or oldy != @cursor_y
        # キャプチャされていたら@captureのメソッドを呼ぶ
        old_over_object = @over_object
        @over_object = tmp.mouse_event_dispatch(:mouse_move, tx, ty)

        if old_over_object != @over_object
          old_over_object.on_mouse_out if old_over_object
          @over_object.on_mouse_over
        end
      end

      super
    end

    # システムフォーカスをセットする。
    def set_focus(obj)
      return obj if @system_focus == obj
      return nil if obj != nil and @childlen.index(obj) == nil
  
      @system_focus.on_leave if @system_focus
      @system_focus = obj
      obj.on_enter if obj
      @childlen.push(@childlen.delete(obj)) if obj
      obj
    end

    # デスクトップをアクティブにする
    def activate
      self.set_focus(nil)
    end

    def mouse_event_dispatch(event, tx, ty)
      # フォーカスを取得できるコントロールだった場合にフォーカスを設定する
      if !@capture_object and (event == :mouse_push or event == :mouse_r_push or event == :mouse_m_push)
        focus_control = get_focusable_control(tx, ty)
        if focus_control
          focus_control.activate
        else
          self.activate
        end
      end
      super
    end
  
  end

  @@desktop = WSDesktop.new

  # ウィンドウシステムのメイン処理
  def self.update
    @@desktop.update
    @@desktop.render
    @@desktop.draw
  end

  # マウスキャプチャする
  # notifyをtrueにするとコンテナをキャプチャした際に配下にイベントが流れる
  # lockをtrueにするとobjがnilの場合キャプチャ先を@@capture_targetに差し替える
  # release_captrurでlockされた状態を解除する
  def self.capture(obj, notify=false, lock=false)
    # フォーカスをロックする場合フォーカス情報を記憶する
    if lock
      @@desktop.capture_target = obj
      @@desktop.capture_target_notify = notify
    end
    @@desktop.capture_object = obj || @@desktop.capture_target
    @@desktop.capture_notify = @@desktop.capture_target ? @@desktop.capture_target_notify : notify
  end
  
  # マウスキャプチャを解除する
  def self.release_capture
    @@desktop.capture_object = nil
    @@desktop.capture_target = nil
    @@desktop.capture_notify = false
    @@desktop.capture_target_notify = false
  end

  # 配下にイベントを流すかどうかを返す。
  def self.capture_notify
    @@desktop.capture_notify
  end

  # デスクトップオブジェクトを返す。
  def self.desktop
    @@desktop
  end

  # マウスキャプチャされているかどうかを返す。
  def self.captured?(obj)
    @@desktop.capture_object == obj
  end

  @@default_z = 10000
  def self.default_z;@@default_z;end
  def self.default_z=(v);@@default_z=v;end
  
  def self.set_theme(v)
    Dir[File.dirname(__FILE__) + '/theme/' + v + "/**/*.rb"].each do |path|
      require path
    end
    v
  end
end

# デスクトップのサイズ＆衝突判定範囲はWindow.width=/height=で書き換える
class << Window
  alias :old_width= :width=
  def width=(v)
    self.old_width=v
    WS.desktop.width = v
    WS.desktop.collision = [0, 0, v, WS.desktop.height]
  end

  alias :old_height= :height=
  def height=(v)
    self.old_height=v
    WS.desktop.height = v
    WS.desktop.collision = [0, 0, WS.desktop.width, v]
  end
end
