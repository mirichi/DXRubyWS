# coding: utf-8
require 'dxruby'
require_relative './core'
require_relative './module'

# ウィンドウシステム
module WS
  class WSDesktop < WSContainer
    attr_accessor :capture_object
    def initialize
      self.collision = [0, 0, Window.width - 1, Window.height - 1]
      @childlen = []
      @signal = {}
      @hit_cursor = Sprite.new
      @hit_cursor.collision = [0,0]
      @font = @@default_font
      @mouse_l_flag = false
      @mouse_r_flag = false
      @capture_object = nil
      @over_object = nil
    end

    def add_control(obj, name=nil)
      super
      obj.z = WS.default_z
      obj.target = Window
    end

    def update
      oldx, oldy = @hit_cursor.x, @hit_cursor.y
      @hit_cursor.x, @hit_cursor.y = Input.mouse_pos_x, Input.mouse_pos_y

      if @capture_object
        tx, ty = @capture_object.get_global_vertex
        tmp = @capture_object
      else
        tx = ty = 0
        tmp = self
      end
  
      # マウスカーソルの移動処理
      if oldx != @hit_cursor.x or oldy != @hit_cursor.y
        # キャプチャされていたら@captureのメソッドを呼ぶ
        old_over_object = @over_object
        @over_object = tmp.on_mouse_move_internal(@hit_cursor.x - tx, @hit_cursor.y - ty)

        if old_over_object != @over_object
          old_over_object.on_mouse_out if old_over_object
          @over_object.on_mouse_over
        end
      end
  
      # ボタン押した
      if Input.mouse_down?(M_LBUTTON) and @mouse_l_flag == false
        @mouse_l_flag = true
        tmp.on_mouse_down_internal(@hit_cursor.x - tx, @hit_cursor.y - ty)
      end
  
      # ボタン離した
      if !Input.mouse_down?(M_LBUTTON) and @mouse_l_flag == true
        @mouse_l_flag = false
        tmp.on_mouse_up_internal(@hit_cursor.x - tx, @hit_cursor.y - ty)
      end

      # 右ボタン押した
      if Input.mouse_down?(M_RBUTTON) and @mouse_r_flag == false
        @mouse_r_flag = true
        tmp.on_mouse_r_down_internal(@hit_cursor.x - tx, @hit_cursor.y - ty)
      end
  
      # 右ボタン離した
      if !Input.mouse_down?(M_RBUTTON) and @mouse_r_flag == true
        @mouse_r_flag = false
        tmp.on_mouse_r_up_internal(@hit_cursor.x - tx, @hit_cursor.y - ty)
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

  def self.desktop
    @@desktop
  end

  def self.captured?(obj)
    @@desktop.capture_object == obj
  end

  @@default_z = 10000
  def self.default_z;@@default_z;end
  def self.default_z=(v);@@default_z=v;end
end
