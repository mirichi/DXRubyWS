# coding: utf-8
require 'dxruby'
require_relative './core'
require_relative './module'

# ウィンドウシステム
module WS
  class WSDesktop < WSContainer
    attr_accessor :capture_object, :system_focus

    def initialize
      self.collision = [0, 0, Window.width - 1, Window.height - 1]
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
    end

    def add_control(obj, name=nil)
      super
      obj.z = WS.default_z
      obj.target = Window
    end

    def update
      # キーイベント
      push_keys = Input::IME.push_keys
      release_keys = Input::IME.release_keys
      if @system_focus # システムフォーカスにキーイベントを送信
        push_keys.each do |key| # 押した
          @system_focus.on_key_push(key)
        end
        release_keys.each do |key| # 離した
          @system_focus.on_key_release(key)
        end
      else # システムフォーカスが無い場合はデスクトップに送っとく
        push_keys.each do |key|
          self.on_key_push(key)
        end
        release_keys.each do |key|
          self.on_key_release(key)
        end
      end

      # 文字列イベント
      str = Input::IME.get_string.encode("UTF-8")
      if str.length > 0
        @system_focus.on_string(str)
      end

      oldx, oldy = @cursor_x, @cursor_y
      @cursor_x, @cursor_y = Input.mouse_pos_x, Input.mouse_pos_y

      if @capture_object
        tx, ty = @capture_object.get_global_vertex
        tx, ty = @cursor_x - tx, @cursor_y - ty
        tmp = @capture_object
      else
        tx, ty = @cursor_x, @cursor_y
        tmp = self

        # フォーカスを取得できるコントロールだった場合にフォーカスを設定する
        if (Input.mouse_down?(M_LBUTTON) and @mouse_l_flag == false) or
           (Input.mouse_down?(M_RBUTTON) and @mouse_r_flag == false)
          ctl = get_focusable_control(tx, ty)
          if ctl
            @system_focus.on_leave if @system_focus
            @system_focus = ctl
            ctl.on_enter
            @childlen.push(@childlen.delete(ctl))
          end
        end
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
  end

  @@desktop = WSDesktop.new

  # ウィンドウシステムのメイン処理
  def self.update
    @@desktop.update
    @@desktop.draw
  end

  def self.capture(obj)
    @@desktop.capture_object = obj
  end

  def self.focus(obj)
    return obj if @@desktop.system_focus == obj
    @@desktop.system_focus.on_leave if @@desktop.system_focus and @@desktop.system_focus != obj
    @@desktop.system_focus = obj
    obj.on_enter if obj
    obj
  end

  def self.desktop
    @@desktop
  end

  def self.captured?(obj)
    @@desktop.capture_object == obj
  end

  def self.focused?(obj)
    @@desktop.system_focus == obj
  end
    
  def self.focused_object
    @@desktop.system_focus
  end
    
  @@default_z = 10000
  def self.default_z;@@default_z;end
  def self.default_z=(v);@@default_z=v;end
end
